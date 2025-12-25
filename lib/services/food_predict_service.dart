import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FoodPredictService {
  static final FoodPredictService _instance = FoodPredictService._internal();
  factory FoodPredictService() => _instance;
  FoodPredictService._internal();

  // 🌍 Change this to your live endpoint
  final String _baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:5000";
  final Dio _dio = Dio();

  /// Send image to backend model and get prediction
  Future<Map<String, dynamic>> predictFood(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        "$_baseUrl/predict",
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      return response.data;
    } on DioError catch (e) {
      final msg = e.response?.data ?? e.message;
      throw Exception("Prediction API Error: $msg");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
