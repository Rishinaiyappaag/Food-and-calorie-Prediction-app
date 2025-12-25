import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:food_pred/services/food_predict_service.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_service.dart';
import '../services/gemini_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController; // Controller for device camera
  bool _isLoading = false; // Indicates loading state for analysis or camera
  String? _error; // Error message to display if any
  Map<String, dynamic>? _analysisResult; // Parsed analysis result
  File? _selectedImage; // Image selected from camera/gallery
  bool _isCameraMode = true; // Toggle between camera and gallery mode

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize camera immediately if camera mode is enabled
    if (_isCameraMode) _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  /// Handles app lifecycle to pause/resume camera appropriately
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed && _isCameraMode) {
      _initCamera();
    }
  }

  /// Initialize device camera and handle permissions
  Future<void> _initCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    // Handle denied permissions
    if (cameraStatus.isDenied || micStatus.isDenied) {
      _showError("Camera or microphone access denied.");
      return;
    }

    // Handle permanently denied permissions
    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      _showError(
        "Camera or microphone permission permanently denied. Please enable it in settings.",
      );
      await openAppSettings();
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError("No camera found on this device");
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();

      if (mounted) setState(() {});
    } catch (e) {
      _showError("Camera error: $e");
    }
  }

  /// Dispose camera controller safely
  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  /// Capture photo from camera
  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError("Camera not ready");
      return;
    }

    try {
      final file = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(file.path);
        _isCameraMode = false;
      });

      await _disposeCamera();
      await _analyzeImage(_selectedImage!);
    } catch (e) {
      _showError("Failed to capture photo: $e");
    }
  }

  /// Pick image from gallery
  Future<void> _pickFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected.")),
      );
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
      _isCameraMode = false;
      _error = null;
      _analysisResult = null;
    });

    // Run analysis immediately after selecting image
    await _analyzeImage(_selectedImage!);
  }

  /// Analyze selected image using Gemini service
Future<void> _analyzeImage(File image) async {
  setState(() {
    _isLoading = true;
    _error = null;
    _analysisResult = null;
  });

  try {
    final result = await FoodPredictService().predictFood(image);
    setState(() => _analysisResult = result);

    final foodName = result['food_name'] ?? "Unknown";
    final confidenceValue = result['confidence'];
    final confidence = (confidenceValue is num) ? confidenceValue.toDouble() : 0.0;

    // ✅ Only save if food is recognized AND confidence is above threshold
    if (foodName != "Unknown" && confidence >= 15.0) {
      await DBService().insertFoodPrediction(image.path, result);
    } else {
      _showError(
        "Food not recognized or Confidence too low (${confidence.toStringAsFixed(1)}%).\n"
        "Image not Saved",
      );
    }
  } catch (e) {
    _showError("Error analyzing image: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}


  /// Show error message in snackbar
  void _showError(String message) {
    setState(() => _error = message);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $message")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Centralized theme access

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // =========================
            // Camera Preview or Selected Image
            // =========================
            Positioned.fill(
              child: _isCameraMode &&
                      _cameraController != null &&
                      _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : (_selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Container(color: theme.colorScheme.background)),
            ),

            // =========================
            // Loading Overlay
            // =========================
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: theme.colorScheme.secondary,
                ),
              ),

            // =========================
            // Analysis Result Panel
            // =========================
            if (_analysisResult != null && !_isCameraMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: _buildResultView(context),
                ),
              ),

            // =========================
            // Bottom Controls (Camera / Gallery)
            // =========================
            // Bottom controls
if (_isCameraMode)
  Positioned(
    bottom: 30,
    left: 0,
    right: 0,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // 🎯 Center Camera Button
        _cameraButton(theme),

        // 🖼️ Gallery Button - slightly to the right
        Positioned(
          right: MediaQuery.of(context).size.width * 0.15, // adjust distance
          child: _galleryButton(theme),
        ),
      ],
    ),
  )
else
  Positioned(
    bottom: 30,
    right: 20,
    child: FloatingActionButton(
      onPressed: () async {
        setState(() {
          _isCameraMode = true;
          _error = null;
          _analysisResult = null;
          _selectedImage = null;
        });
        await _initCamera();
      },
      backgroundColor: theme.colorScheme.primary,
      child: const Icon(Icons.camera_alt),
    ),
  )


          ],
        ),
      ),
    );
    
  }

Widget _cameraButton(ThemeData theme) {
  return GestureDetector(
    onTap: _takePhoto,
    child: Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.dividerColor,
          width: 2,
        ),
      ),
      child: Icon(Icons.camera, size: 32, color: theme.iconTheme.color),
    ),
  );
}

Widget _galleryButton(ThemeData theme) {
  return GestureDetector(
    onTap: () => _pickFromGallery(context),
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.photo_library, color: theme.colorScheme.onPrimary),
    ),
  );
}

/// Build the result panel view dynamically based on Model analysis
Widget _buildResultView(BuildContext context) {
  final theme = Theme.of(context);
  if (_analysisResult == null) return const SizedBox();

  final name = _analysisResult?['food_name'] ?? "Unknown Food";
  final confidenceValue = _analysisResult?['confidence'];
  final confidence = (confidenceValue is num)
      ? confidenceValue.toDouble()
      : 0.0;

  // 🚨 If confidence < 15%, show "Image not recognized"
  if (confidence < 15.0) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              "Image not recognized",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Couldn’t identify this food. Please upload a clearer image or note that the model may not recognize certain items yet.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Normal result view if confidence ≥ 30%
  final nutrition = Map<String, dynamic>.from(
    _analysisResult?['nutrition_per_100g'] ?? {},
  );

  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🍽️ Food name
        Text(
          "$name 🍽️",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        // 💯 Confidence Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Confidence",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                "${confidence.toStringAsFixed(2)}%",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // 🧾 Nutrition section
        Text(
          "Nutrition per 100g",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: nutrition.entries.map((entry) {
            final key = entry.key;
            final value = entry.value.toString();

            return Container(
              width: MediaQuery.of(context).size.width / 2 - 26,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getNutrientIcon(key),
                      size: 22, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key[0].toUpperCase() + key.substring(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}


  /// Return icons for nutrients
IconData _getNutrientIcon(String key) {
  switch (key.toLowerCase()) {
    case "protein":
      return Icons.fitness_center;
    case "carbohydrates":
      return Icons.bakery_dining;
    case "fat":
    case "fats":
      return Icons.opacity;
    case "fiber":
      return Icons.eco;
    case "sugars":
      return Icons.cake;
    case "calories":
      return Icons.local_fire_department;
    case "sodium":
      return Icons.water_drop;
    default:
      return Icons.circle;
  }
}

}
