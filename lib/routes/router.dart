import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/meal_analysis.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';

import '../screens/history/history.dart';
import '../screens/history/meal analysis/meal_detail_page.dart';
import '../screens/history/meal analysis/meal_analysis_history.dart';
import '../screens/history/nutrition tracking/nutrition_tracking.dart';
import '../screens/history/nutrition tracking/Nutrition_detail_page.dart';
import '../screens/history/Progress_vis.dart';

final router = GoRouter(
  initialLocation: '/analysis',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _getIndex(state.uri.toString()),
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/analysis');
                  break;
                case 1:
                  context.go('/history');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: "Analysis",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: "History",
              ),
            ],
          ),
        );
      },
      routes: [

        // ------------------------------
        // MAIN TABS
        // ------------------------------
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AnalysisScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),

        // ------------------------------
        // NEW SCREENS (MUST BE REGISTERED)
        // ------------------------------
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),

        GoRoute(
          path: '/meal-detail',
          builder: (context, state) {
            final result = state.extra as Map<String, dynamic>;
            return MealDetailPage(
              result: result["result"],
              imagePath: result["image"],
            );
          },
        ),

        GoRoute(
          path: '/meal-analysis-history',
          builder: (context, state) => const MealDetailedHistory(),
        ),

        GoRoute(
          path: '/nutrition-tracking',
          builder: (context, state) => const NutritionSummaryScreen(),
        ),

        GoRoute(
          path: '/nutrition-detail',
          builder: (context, state) {
            final plan = state.extra as Map<String, dynamic>;
            return NutritionDetailPage(plan: plan);
          },
        ),

        GoRoute(
          path: '/progress-vis',
          builder: (context, state) => const ProgressVisualisation(),
        ),

      ],
    ),
  ],
);

int _getIndex(String location) {
  if (location.startsWith('/history')) return 1;
  return 0;
}
