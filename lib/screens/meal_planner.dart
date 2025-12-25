// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../services/gemini_service.dart';
// import '../services/db_service.dart';

// class PlannerScreen extends StatefulWidget {
//   const PlannerScreen({super.key});

//   @override
//   State<PlannerScreen> createState() => _PlannerScreenState();
// }

// class _PlannerScreenState extends State<PlannerScreen> {
//   // Controllers for user input fields
//   final _calorieController = TextEditingController();
//   final _proteinController = TextEditingController();
//   final _carbsController = TextEditingController();
//   final _fatController = TextEditingController();
//   final _dietaryPrefController = TextEditingController();

//   bool _isLoading = false; // Loading state
//   Map<String, dynamic>? _plan; // Generated meal plan

//   // =========================
//   // Function to generate meal plan using Gemini service
//   // =========================
//   Future<void> _generatePlan() async {
//     final calories = _calorieController.text.trim();
//     final protein = _proteinController.text.trim();
//     final carbs = _carbsController.text.trim();
//     final fat = _fatController.text.trim();
//     final prefs = _dietaryPrefController.text.trim();

//     setState(() => _isLoading = true);

//     try {
//       final response = await GeminiService().generateMealPlan(
//         calorieTarget: calories,
//         proteinTarget: protein,
//         carbTarget: carbs,
//         fatTarget: fat,
//         preferences: prefs,
//       );

//       String rawText =
//           response["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
//       if (rawText == null) throw Exception("Gemini returned no text");

//       // Clean JSON text
//       rawText = rawText.trim().replaceAll(RegExp(r"^```json|```$"), "");

//       // Parse JSON
//       Map<String, dynamic> parsed;
//       try {
//         parsed = jsonDecode(rawText);
//       } catch (_) {
//         throw Exception("Gemini response was not valid JSON:\n$rawText");
//       }

//       setState(() => _plan = parsed);

//       // Save plan to DB
//       await DBService().insertNutritionPlan(parsed);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error generating plan: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // =========================
//   // Helper function: Build meal card using theme colors
//   // =========================
//   Widget _buildMealCard(
//       String title, Map<String, dynamic> meal, Color color, IconData icon) {
//     final theme = Theme.of(context); // Access current theme

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 4,
//       color: theme.cardColor, // Use theme's card color
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: color, size: 28),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: theme.textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: color, // Keep meal-specific color
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               meal["title"] ?? "No name",
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             if (meal["description"] != null) ...[
//               const SizedBox(height: 4),
//               Text(
//                 meal["description"],
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.textTheme.bodyLarge!.color?.withOpacity(0.7),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 8),
//             Text(
//               "Calories: ${meal["calories"] ?? '-'} kcal\n"
//               "Protein: ${meal["protein"] ?? '-'} g | "
//               "Carbs: ${meal["carbs"] ?? '-'} g | "
//               "Fat: ${meal["fat"] ?? '-'} g",
//               style: theme.textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =========================
//   // Build full plan view
//   // =========================
//   Widget _buildPlanView(Map<String, dynamic> plan) {
//     final meals = plan["plan"] as Map<String, dynamic>? ?? {};
//     final totals = plan["totals"] as Map<String, dynamic>? ?? {};
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildMealCard(
//             "Breakfast", meals["breakfast"] ?? {}, Colors.orange, Icons.free_breakfast),
//         _buildMealCard("Lunch", meals["lunch"] ?? {}, Colors.green, Icons.lunch_dining),
//         _buildMealCard("Dinner", meals["dinner"] ?? {}, Colors.blue, Icons.dinner_dining),
//         _buildMealCard("Snacks", meals["snacks"] ?? {}, Colors.purple, Icons.fastfood),
//         const SizedBox(height: 20),
//         Card(
//           color: theme.colorScheme.secondary.withOpacity(0.1), // Themed card
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           elevation: 3,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Daily Totals",
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.secondary,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Calories: ${totals["calories"] ?? '-'} kcal\n"
//                   "Protein: ${totals["protein"] ?? '-'} g | "
//                   "Carbs: ${totals["carbs"] ?? '-'} g | "
//                   "Fat: ${totals["fat"] ?? '-'} g",
//                   style: theme.textTheme.bodyLarge,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Meal Planner"),
//         backgroundColor: theme.appBarTheme.backgroundColor, // Themed appbar
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // =========================
//             // Input Fields
//             // =========================
//             TextField(
//               controller: _dietaryPrefController,
//               decoration: InputDecoration(
//                 labelText: "Dietary Preferences (e.g. vegan, no nuts)",
//                 border: const OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _calorieController,
//               decoration: const InputDecoration(
//                 labelText: "Daily Calorie Target",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _proteinController,
//                     decoration: const InputDecoration(
//                       labelText: "Protein (g)",
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: _carbsController,
//                     decoration: const InputDecoration(
//                       labelText: "Carbs (g)",
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: _fatController,
//                     decoration: const InputDecoration(
//                       labelText: "Fat (g)",
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // =========================
//             // Generate Button
//             // =========================
//             ElevatedButton.icon(
//               onPressed: _isLoading ? null : _generatePlan,
//               icon: const Icon(Icons.auto_awesome),
//               label: const Text("Generate Meal Plan"),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // =========================
//             // Loading indicator
//             // =========================
//             if (_isLoading) const CircularProgressIndicator(),

//             // =========================
//             // Display plan
//             // =========================
//             if (_plan != null) ...[
//               const SizedBox(height: 20),
//               _buildPlanView(_plan!),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
