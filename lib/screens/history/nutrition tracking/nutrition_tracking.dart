import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/db_service.dart';
import './nutrition_detail_page.dart';

class NutritionSummaryScreen extends StatefulWidget {
  const NutritionSummaryScreen({super.key});

  @override
  State<NutritionSummaryScreen> createState() => _NutritionSummaryScreenState();
}

class _NutritionSummaryScreenState extends State<NutritionSummaryScreen> {
  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await DBService().getMealAnalyses();
    setState(() {
      _meals = meals;
      _isLoading = false;
    });
  }

  Map<String, dynamic> _calculateTotals(List<Map<String, dynamic>> meals) {
    num calories = 0;
    num protein = 0;
    num carbs = 0;
    num fat = 0;
    num fiber = 0;
    num sugars = 0;
    num sodium = 0;

    for (var meal in meals) {
      final nutrition = meal['nutrition'] ?? {};
      calories += nutrition['calories'] ?? 0;
      protein += nutrition['protein'] ?? 0;
      carbs += nutrition['carbohydrates'] ?? 0;
      fat += nutrition['fat'] ?? 0;
      fiber += nutrition['fiber'] ?? 0;
      sugars += nutrition['sugars'] ?? 0;
      sodium += nutrition['sodium'] ?? 0;
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugars': sugars,
      'sodium': sodium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Summary"),
        backgroundColor: colors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meals.isEmpty
              ? Center(
                  child: Text(
                    "No meals analyzed yet 🍽️",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Meals",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // 🍱 Meal Cards
                      ..._meals.map((meal) {
                        final nutrition = meal['nutrition'] ?? {};
                        final imagePath = meal['imagePath'];
                        final confidence = meal['confidence'] ?? 0.0;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NutritionDetailPage(plan: meal),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (imagePath != null &&
                                          File(imagePath).existsSync())
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            File(imagePath),
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.fastfood, size: 50),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          meal['food_name'] ?? "Unknown Food",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Confidence: ${confidence.toStringAsFixed(1)}%",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey[700]),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 4,
                                          children: [
                                            _nutrientChip("Calories",
                                                "${nutrition['calories'] ?? '-'} kcal"),
                                            _nutrientChip("Protein",
                                                "${nutrition['protein'] ?? '-'} g"),
                                            _nutrientChip("Carbs",
                                                "${nutrition['carbohydrates'] ?? '-'} g"),
                                            _nutrientChip("Fats",
                                                "${nutrition['fat'] ?? '-'} g"),
                                            _nutrientChip("Fiber",
                                                "${nutrition['fiber'] ?? '-'} g"),
                                            _nutrientChip("Sugars",
                                                "${nutrition['sugars'] ?? '-'} g"),
                                            _nutrientChip("Sodium",
                                                "${nutrition['sodium'] ?? '-'} mg"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),

                      // 📊 Weekly Summary
                      Text(
                        "Weekly Summary",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Builder(builder: (_) {
                        final totals = _calculateTotals(_meals);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Overall Weekly Intake",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                _summaryRow("Total Calories",
                                    "${totals['calories'].toStringAsFixed(1)} kcal"),
                                const Divider(),
                                _summaryRow("Protein",
                                    "${totals['protein'].toStringAsFixed(1)} g"),
                                _summaryRow("Carbs",
                                    "${totals['carbs'].toStringAsFixed(1)} g"),
                                _summaryRow("Fats",
                                    "${totals['fat'].toStringAsFixed(1)} g"),
                                _summaryRow("Fiber",
                                    "${totals['fiber'].toStringAsFixed(1)} g"),
                                _summaryRow("Sugars",
                                    "${totals['sugars'].toStringAsFixed(1)} g"),
                                _summaryRow("Sodium",
                                    "${totals['sodium'].toStringAsFixed(1)} mg"),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _nutrientChip(String label, String value) {
    return Chip(
      label: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 13),
      ),
      side: BorderSide(color: const Color.fromARGB(255, 137, 133, 133)),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 15)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
