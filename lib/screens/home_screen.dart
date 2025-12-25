import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../routes/global_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalState>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gradient Top
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Today's calories box
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Calories",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),

                  /// GET calories from global state
                  Text(
                    "${state.getTodayCalories()} kcal",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Camera button
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                context.push("/meal-analysis");
              },
              child: Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blueAccent],
                  ),
                ),
                child: const Icon(Icons.camera_alt,
                    size: 50, color: Colors.white),
              ),
            ),
          ),

          // Bottom FAB buttons
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.deepPurple,
                  onPressed: () => context.push("/history"),
                  child: const Icon(Icons.history),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.deepPurple,
                  onPressed: () => context.push("/calendar"),
                  child: const Icon(Icons.calendar_month),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
