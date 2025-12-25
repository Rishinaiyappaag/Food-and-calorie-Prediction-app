import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

    final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';   final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://generativelanguage.googleapis.com/v1beta"),
  );

  Future<Map<String, dynamic>> analyzeMeal(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception("🚨 Missing Gemini API key! Start app with: \n"
          "flutter run --dart-define=GEMINI_API_KEY=your_api_key_here");
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _dio.post(
        "/models/gemini-1.5-flash:generateContent?key=$_apiKey",
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Analyze this meal photo. Provide: meal name, description, nutrition breakdown (calories, protein, carbs, fat, fiber), and list of ingredients."
                },
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image,
                  }
                }
              ]
            }
          ]
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception("❌ Gemini API error (status $status): $body");
    } catch (e) {
      throw Exception("❌ Unexpected error: $e");
    }
  }


  
  Future<Map<String, dynamic>> generateMealPlan({
    required String calorieTarget,
    required String proteinTarget,
    required String carbTarget,
    required String fatTarget,
    required String preferences,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception("🚨 Missing Gemini API key!");
    }

    try {
      final response = await _dio.post(
        "/models/gemini-1.5-flash:generateContent?key=$_apiKey",
        data: {
          "contents": [
            {
              "parts": [
                {
                "text": """
                You are a JSON-only generator. 
                Generate a valid JSON object with NO extra text, NO markdown, NO backticks.  

                Task: Create a one-day meal plan with Breakfast, Lunch, Dinner, and Snacks.  

                Structure the JSON like this:
                {
                  "plan": {
                    "breakfast": {
                      "title": "string",
                      "description": "string",
                      "ingredients": ["string", "string"],
                      "calories": number,
                      "protein": number,
                      "carbs": number,
                      "fat": number
                    },
                    "lunch": { ... },
                    "dinner": { ... },
                    "snacks": { ... }
                  },
                  "totals": {
                    "calories": number,
                    "protein": number,
                    "carbs": number,
                    "fat": number
                  }
                }

                User preferences: $preferences.  
                Calorie target: $calorieTarget kcal.  
                Protein $proteinTarget g, 
                Carbs $carbTarget g, 
                Fat $fatTarget g.  
                Return only the JSON object.
                """


                }
              ]
            }
          ]
        },
      );
print("Gemini raw response: ${response.data}");


      return response.data;
    } on DioError catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception("❌ Gemini API error (status $status): $body");
    } catch (e) {
      throw Exception("❌ Unexpected error: $e");
    }
  }
}
