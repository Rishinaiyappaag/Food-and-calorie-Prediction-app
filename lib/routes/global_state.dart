import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  String _userPreference = "Balanced Diet";
  List<Map<String, dynamic>> meals = [];

  String get userPreference => _userPreference;

  void setUserPreference(String preference) {
    _userPreference = preference;
    notifyListeners();
  }

  void addMeal(String name, double calories) {
    meals.add({
      "name": name,
      "calories": calories,
      "date": DateTime.now(),
    });
    notifyListeners();
  }

  double getTodayCalories() {
    final today = DateTime.now();

    return meals
        .where((m) =>
            m["date"].day == today.day &&
            m["date"].month == today.month &&
            m["date"].year == today.year)
        .fold(0.0, (sum, m) => sum + m["calories"]);
  }
}
