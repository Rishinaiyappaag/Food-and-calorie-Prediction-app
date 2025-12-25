import 'package:flutter/material.dart';
import './Progress_vis.dart';
import './nutrition tracking/nutrition_tracking.dart';
import './meal analysis/meal_analysis_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal History"),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRichButton(
              context,
              icon: Icons.fastfood,
              label: "Meal Analysis History",
              color: Theme.of(context).colorScheme.primary, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MealDetailedHistory(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRichButton(
              context,
              icon: Icons.health_and_safety,
              label: "Nutrition Tracking",
              color: Theme.of(context).colorScheme.primary, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NutritionSummaryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRichButton(
              context,
              icon: Icons.bar_chart, // ✅ better suited for "Progress Visualization"
              label: "Progress Visualization",
              color: Theme.of(context).colorScheme.primary, 
              // ✅ tertiaryContainer for variety across themes
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProgressVisualisation(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Custom button widget styled consistently with theme
  Widget _buildRichButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // ✅ Subtle shadow that works for both themes
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.onPrimary, 
              // ✅ ensures correct text/icon contrast against `color`
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary, 
                      // ✅ automatically white in dark, black in light
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              // ✅ slightly transparent for a less intrusive look
            ),
          ],
        ),
      ),
    );
  }
}
