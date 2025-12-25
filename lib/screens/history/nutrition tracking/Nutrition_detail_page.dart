import 'dart:io';
import 'package:flutter/material.dart';

class NutritionDetailPage extends StatelessWidget {
  final Map<String, dynamic> plan;

  const NutritionDetailPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final imagePath = plan['imagePath'];
    final name = plan['food_name'] ?? "Unknown Food";
    final confidence = (plan['confidence'] ?? 0).toDouble();
    final nutrition = Map<String, dynamic>.from(plan['nutrition'] ?? {});

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null && File(imagePath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            // 🍽️ Food name
            Text(
              name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 16),

            // 💯 Confidence
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights, size: 28),
                      SizedBox(width: 10),
                      Text("Confidence", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(
                    "${confidence.toStringAsFixed(1)}%",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: confidence >= 50
                          ? Colors.green
                          : (confidence >= 30 ? Colors.orange : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🍎 Nutrition Info
            Text("Nutrition per 100g",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: nutrition.entries.map((entry) {
                return Container(
                  width: MediaQuery.of(context).size.width / 2 - 26,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.outline.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key[0].toUpperCase() + entry.key.substring(1),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(entry.value.toString(),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colors.secondary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
