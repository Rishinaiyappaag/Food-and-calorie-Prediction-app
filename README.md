# 🍽️ Food-and-calorie-Prediction-app — README

A Flutter app that captures meal photos stores results locally, and provides meal planning, history, analytics, and progress visualization.

Includes secure API-key handling, offline support, and robust parsing/fallbacks for varied Gemini output.



#
## 🚀 Quick Start

```bash
git clone https://github.com/your-username/meal-analyzer-planner.git
cd meal-analyzer-planner
flutter pub get
```

### 🔐 Set Up Your `.env` File

Create a `.env` file in the root of your project and add your Gemini API key:

```
GEMINI_API_KEY=your_gemini_api_key_here
```

---


### Development (hot reload)

```bash
flutter run --dart-define=GEMINI_API_KEY="your_gemini_api_key_here"
```

### Release APK


# Run the app
```bash
flutter run
```
---

## 🛠️ Prerequisites

- Latest stable Flutter SDK (`flutter --version`)
- Android Studio / VS Code + Android SDK
- For iOS builds: Xcode + macOS
- Gemini API account and key (via Google Cloud / Gemini console)
- Optional: `adb` and connected device/emulator

---


## ✨ Features

- Camera capture and gallery pick for meal photos
- Send photo to Gemini AI, parse markdown/JSON output
- Show results: meal name, description, nutrition (calories, protein, carbs, fat, fiber), ingredients
- Save only recognized meals to local DB (`sqflite`)
- Meal planning assistant via Gemini AI
- History screen with image previews and nutrition summary
- Nutrition tracking: daily/weekly totals, charts
- Filters, search, and delete saved meals
- Offline support
- Dark mode and responsive UI
- Error handling and retry logic

---

## 🧠 Architecture & Why We Chose It

### Folder + Services Separation

- `services/` contains side-effectful code (API, DB)
- Keeps UI widgets pure and testable

## 🧭 Navigation: `go_router` + `ShellRoute`

---

### 🚀 Why `go_router`?

- Declarative, URL-based routing (similar to web apps)
- Supports nested navigation and `ShellRoute` for layouts like `BottomNavigationBar` or `TabBar`
- Handles deep linking and redirection with ease
- Simplifies routing logic while keeping it testable and maintainable

---

### 🧱 ShellRoute Usage

- Enables a **persistent layout** (e.g., `BottomNavigationBar`) while switching pages inside the shell
- Each tab can have its own **nested navigator**, preserving state across tabs
- Makes complex multi-tab apps **cleaner and more scalable** than manual `Navigator` stack management

---


## 🤖 How the AI Response Is Handled & Saved

Gemini output formats vary:

- Markdown
- JSON inside triple backticks
- Raw object: `candidates → content → parts → text`

### Parsing Strategy

- Prefer structured JSON if available
- If markdown/text:
  - Remove triple-backtick fences
  - Use regex to extract:
    - `**Meal Name:**`
    - `**Calories:**`, `**Protein:**`, etc.
    - Bullet lists for ingredients
  - Support numeric ranges (e.g., 350–450 → average)

### Stored DB Row Format

```json
{
  "analysis": "<extracted markdown text>",
  "meal": "<extracted meal name>",
  "raw": { /* raw Gemini response */ },
  "totals": { "calories": 350, "protein": 12, "carbs": 70, "fat": 6 }
}
```

> If meal name is missing or marked "Unknown", entry is **not saved** to DB.

---

## 🛡️ Error Handling & Implemented Edge-Cases

### API & Network

- Loading/error states with spinner and retry
- Retry logic for transient failures
- Timeouts for Gemini API calls

### Parsing Variability

- Supports:
  - Markdown with headings and bullets
  - JSON inside backticks
  - Raw Gemini result object
- Handles malformed/truncated output:
  - JSON decode → fallback to regex
  - Ranges → midpoint
  - Formatting issues → sanitize digits/commas

### Permissions & Camera

- Friendly message if camera permission denied
- Fallback to gallery if camera unavailable

### Database & Storage

- All inserts wrapped in `try/catch`
- Safe JSON decode on read
- Migration support via `fixOldMeals()`

### UI Edge-Cases

- Hide nutrition card if values missing
- Show only available macros
- Trim long ingredient lists/descriptions

---

## 🧪 Run / Build / Release

### Local Development

```bash
flutter run
```

### Release Build

```bash
flutter build apk --release
```


> Grant camera & storage permissions when prompted.

---

