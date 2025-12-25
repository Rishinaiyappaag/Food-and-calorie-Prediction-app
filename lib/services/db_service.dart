import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'meals.db');

    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meal_analysis (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT,
            result TEXT,
            createdAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE nutrition_plan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            result TEXT,
            createdAt TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  // Insert meal analysis from model
  Future<void> insertFoodPrediction(String imagePath, Map<String, dynamic> result) async {
    final db = await database;

    await db.insert(
      'meal_analysis',
      {
        'imagePath': imagePath,
        'result': jsonEncode(result),
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert nutrition plan
  Future<void> insertNutritionPlan(Map<String, dynamic> result) async {
    final db = await database;

    await db.insert(
      'nutrition_plan',
      {
        'result': jsonEncode(result),
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all meal analyses
  Future<List<Map<String, dynamic>>> getMealAnalyses() async {
    final db = await database;

    final meals = await db.query(
      'meal_analysis',
      orderBy: 'createdAt DESC',
    );

    return meals.map((meal) {
      final decoded = jsonDecode(meal['result'] as String);

      // Extract nutrition section
      final nutrition = decoded['nutrition_per_100g'] ?? {};

      return {
        'id': meal['id'],
        'imagePath': meal['imagePath'],

        // Main info
        'food_name': decoded['food_name'],
        'confidence': decoded['confidence'],

        // Flatten nutrition fields so UI can read them directly
        'calories': nutrition['calories'],
        'carbs': nutrition['carbs'],
        'fats': nutrition['fats'],
        'fiber': nutrition['fiber'],
        'protein': nutrition['protein'],
        'sodium': nutrition['sodium'],
        'sugar': nutrition['sugar'],

        // Date
        'createdAt': meal['createdAt'],
      };
    }).toList();
  }

  // Fetch nutrition plans
  Future<List<Map<String, dynamic>>> getNutritionPlans() async {
    final db = await database;

    final plans = await db.query(
      'nutrition_plan',
      orderBy: 'createdAt DESC',
    );

    return plans.map((plan) {
      return {
        'id': plan['id'],
        'result': jsonDecode(plan['result'] as String),
        'createdAt': plan['createdAt'],
      };
    }).toList();
  }

  // Delete meal by ID
  Future<void> deleteMeal(int id) async {
    final db = await database;

    await db.delete(
      'meal_analysis',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
