import 'package:flutter/material.dart';

class AppTheme {
  // ---------------------------
  //    LIGHT COLOR SCHEME
  // ---------------------------
  static final lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF2D6BFF), // Electric blue
    onPrimary: Colors.white,
    secondary: const Color(0xFF6C92FF), // Soft purple-blue gradient tone
    onSecondary: Colors.white,
    surface: const Color(0xFFF7F9FC), // Subtle white-blue surface
    onSurface: const Color(0xFF0D1B2A), // Deep navy text
    error: Colors.red.shade700,
    onError: Colors.white,
    tertiary: const Color(0xFF00C2FF), // Aqua accent
    onTertiary: Colors.black,
    outline: Colors.black26,
    surfaceContainerHighest: Colors.white,
  );

  // ---------------------------
  //    DARK COLOR SCHEME
  // ---------------------------
  static final darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF4F8CFF), // Bright blue
    onPrimary: Colors.white,
    secondary: const Color(0xFF8EA8FF), // bluish-lavender
    onSecondary: Colors.black,
    surface: const Color(0xFF0E1420),
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.black,
    tertiary: const Color(0xFF3BE8FF),
    onTertiary: Colors.black,
    outline: Colors.white24,
    surfaceContainerHighest: const Color(0xFF1A1F2C),
  );

  // ---------------------------
  //        LIGHT THEME
  // ---------------------------
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.surface,

    // APPBAR
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: lightColorScheme.primary,
      elevation: 1,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D6BFF),
      ),
    ),

    // CARDS — Soft shadow + rounded
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: Colors.blue.withAlpha(26),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // TEXT
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: lightColorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: lightColorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: lightColorScheme.onSurface,
        fontSize: 15,
      ),
    ),

    // NAVIGATION BAR (modern flat style)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: lightColorScheme.primary,
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      elevation: 15,
    ),

    // BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        backgroundColor: lightColorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  // ---------------------------
  //        DARK THEME
  // ---------------------------
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,

    // DARK APPBAR
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF101827), // Use a solid color here; apply a gradient directly in AppBar if needed
      foregroundColor: Colors.white,
      elevation: 1,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    // DARK CARDS
    cardTheme: CardThemeData(
      color: darkColorScheme.surfaceContainerHighest,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      shadowColor: Colors.black54,
    ),

    // DARK TEXT
    textTheme: TextTheme(
      headlineMedium: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 15),
    ),

    // DARK NAVBAR — glass effect
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1A2233),
      selectedItemColor: darkColorScheme.primary,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.secondary,
      foregroundColor: Colors.black,
    ),
  );
}
