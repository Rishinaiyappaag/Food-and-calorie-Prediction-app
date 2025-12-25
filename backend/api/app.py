from flask import Flask, request, jsonify
import torch
from torchvision import models, transforms
from PIL import Image
import json, os, pandas as pd

app = Flask(__name__)

# -------------------------------
# Load Model
# -------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.abspath(os.path.join(BASE_DIR, ".."))

MODEL_PATH = os.path.join(ROOT_DIR, "models", "foodmodel_torch.pth")
CLASS_INDICES_PATH = os.path.join(ROOT_DIR, "models", "class_indices.json")
NUTRITION_CSV = os.path.join(ROOT_DIR, "dataset", "food_nutrition_map.csv")

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load DenseNet201
model = models.densenet201(weights=None)
num_features = model.classifier.in_features
with open(CLASS_INDICES_PATH) as f:
    class_indices = json.load(f)
model.classifier = torch.nn.Sequential(
    torch.nn.Linear(num_features, 1024),
    torch.nn.ReLU(),
    torch.nn.Dropout(0.4),
    torch.nn.Linear(1024, len(class_indices))
)
model.load_state_dict(torch.load(MODEL_PATH, map_location=device))
model.eval().to(device)

# Load nutrition data
nutrition_df = pd.read_csv(NUTRITION_CSV)
nutrition_df['label'] = nutrition_df['label'].str.strip().str.lower()

def get_nutrition_info(label):
    row = nutrition_df[nutrition_df["label"] == label.lower()]
    return row.iloc[0].to_dict() if not row.empty else {}

# Transform for prediction
transform_pred = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406],
                         [0.229, 0.224, 0.225])
])

# -------------------------------
# Prediction Route
# -------------------------------
@app.route("/predict", methods=["POST"])
def predict_food():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image_file = request.files["image"]
    image = Image.open(image_file.stream).convert("RGB")

    img_tensor = transform_pred(image).unsqueeze(0).to(device)
    with torch.no_grad(), torch.amp.autocast("cuda", enabled=(device.type == "cuda")):
        preds = model(img_tensor)
        idx = preds.argmax(1).item()
        confidence = torch.softmax(preds, dim=1)[0, idx].item()

    inv_map = {v: k for k, v in class_indices.items()}
    label = inv_map[idx]
    display_name = label.replace("_", " ").title()

    nutrition = get_nutrition_info(label)

    return jsonify({
        "food_name": display_name,
        "confidence": round(confidence * 100, 2),
        "nutrition_per_100g": nutrition
    })

@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "Food Classification API is running 🚀"})

# -------------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)
