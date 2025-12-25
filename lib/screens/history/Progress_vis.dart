import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../services/db_service.dart';
import 'package:intl/intl.dart';

class ProgressVisualisation extends StatefulWidget {
  const ProgressVisualisation({super.key});

  @override
  State<ProgressVisualisation> createState() => _ProgressVisualisationState();
}

class _ProgressVisualisationState extends State<ProgressVisualisation> {
  List<DailyNutrition> nutritionData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    final meals = await DBService().getMealAnalyses();
    final plans = await DBService().getNutritionPlans();

    final Map<DateTime, DailyNutrition> dailyTotals = {};

    void processEntry(Map<String, dynamic> entry, {required bool isPlan}) {
      final nutrition = entry['nutrition'] ?? {};
      final rawDate = entry['createdAt']?.toString() ?? '';
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) return;

      final dateKey = DateTime(parsed.year, parsed.month, parsed.day);

      final calories = (nutrition['calories'] ?? 0).toDouble();
      final protein  = (nutrition['protein'] ?? 0).toDouble();
      final carbs    = (nutrition['carbohydrates'] ?? 0).toDouble();
      final fat      = (nutrition['fat'] ?? 0).toDouble();
      final fiber    = (nutrition['fiber'] ?? 0).toDouble();
      final sugars   = (nutrition['sugars'] ?? 0).toDouble();
      final sodium   = (nutrition['sodium'] ?? 0).toDouble();

      if (!dailyTotals.containsKey(dateKey)) {
        dailyTotals[dateKey] = DailyNutrition(
          date: dateKey,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
          sugars: sugars,
          sodium: sodium,
        );
      } else {
        final existing = dailyTotals[dateKey]!;
        dailyTotals[dateKey] = DailyNutrition(
          date: existing.date,
          calories: existing.calories + calories,
          protein: existing.protein + protein,
          carbs: existing.carbs + carbs,
          fat: existing.fat + fat,
          fiber: existing.fiber + fiber,
          sugars: existing.sugars + sugars,
          sodium: existing.sodium + sodium,
        );
      }
    }

    // Process all entries
    for (var plan in plans) processEntry(plan, isPlan: true);
    for (var meal in meals) processEntry(meal, isPlan: false);

    final data = dailyTotals.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      nutritionData = data;
      _isLoading = false;
    });
  }

  num get totalCalories => nutritionData.fold(0, (sum, d) => sum + d.calories);
  num get totalProtein  => nutritionData.fold(0, (sum, d) => sum + d.protein);
  num get totalCarbs    => nutritionData.fold(0, (sum, d) => sum + d.carbs);
  num get totalFat      => nutritionData.fold(0, (sum, d) => sum + d.fat);
  num get totalFiber    => nutritionData.fold(0, (sum, d) => sum + d.fiber);
  num get totalSugars   => nutritionData.fold(0, (sum, d) => sum + d.sugars);
  num get totalSodium   => nutritionData.fold(0, (sum, d) => sum + d.sodium);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Visualisation"),
        backgroundColor: colors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : nutritionData.isEmpty
              ? const Center(child: Text("No nutrition data available."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTotalsCard(),
                      const SizedBox(height: 24),
                      const Text(
                        "Macro Distribution (Last Day)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildPieChart(nutritionData.last),
                      const SizedBox(height: 24),
                      const Text(
                        "Calories Trend",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildCaloriesLineChart(),
                      const SizedBox(height: 24),
                      const Text(
                        "Macros & Nutrients Trend",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildMacrosLineChart(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Total Intake",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildTotalItem("Calories", totalCalories.toStringAsFixed(0)),
                _buildTotalItem("Protein", "${totalProtein.toStringAsFixed(0)} g"),
                _buildTotalItem("Carbs", "${totalCarbs.toStringAsFixed(0)} g"),
                _buildTotalItem("Fats", "${totalFat.toStringAsFixed(0)} g"),
                _buildTotalItem("Fiber", "${totalFiber.toStringAsFixed(0)} g"),
                _buildTotalItem("Sugars", "${totalSugars.toStringAsFixed(0)} g"),
                _buildTotalItem("Sodium", "${totalSodium.toStringAsFixed(0)} mg"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPieChart(DailyNutrition day) {
    final macroData = [
      MacroData('Protein', day.protein),
      MacroData('Carbs', day.carbs),
      MacroData('Fats', day.fat),
      MacroData('Fiber', day.fiber),
      MacroData('Sugars', day.sugars),
      MacroData('Sodium', day.sodium),
    ];
    return SfCircularChart(
      legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      series: <PieSeries<MacroData, String>>[
        PieSeries<MacroData, String>(
          dataSource: macroData,
          xValueMapper: (d, _) => d.macro,
          yValueMapper: (d, _) => d.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildCaloriesLineChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        minimum: nutritionData.isNotEmpty ? nutritionData.first.date : null,
        maximum: nutritionData.isNotEmpty ? nutritionData.last.date : null,
      ),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Calories')),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<DailyNutrition, DateTime>>[
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.calories,
          name: 'Calories',
          color: Colors.red,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildMacrosLineChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        minimum: nutritionData.isNotEmpty ? nutritionData.first.date : null,
        maximum: nutritionData.isNotEmpty ? nutritionData.last.date : null,
      ),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Grams / mg')),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true),
      series: <CartesianSeries<DailyNutrition, DateTime>>[
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.protein,
          name: 'Protein',
          color: Colors.blue,
        ),
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.carbs,
          name: 'Carbs',
          color: Colors.orange,
        ),
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.fat,
          name: 'Fats',
          color: Colors.green,
        ),
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.fiber,
          name: 'Fiber',
          color: Colors.purple,
        ),
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.sugars,
          name: 'Sugars',
          color: Colors.pink,
        ),
        LineSeries<DailyNutrition, DateTime>(
          dataSource: nutritionData,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.sodium,
          name: 'Sodium',
          color: Colors.brown,
        ),
      ],
    );
  }
}

// Models
class DailyNutrition {
  final DateTime date;
  final num calories;
  final num protein;
  final num carbs;
  final num fat;
  final num fiber;
  final num sugars;
  final num sodium;

  DailyNutrition({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugars,
    required this.sodium,
  });
}

class MacroData {
  final String macro;
  final num value;
  MacroData(this.macro, this.value);
}
