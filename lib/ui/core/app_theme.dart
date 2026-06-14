import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color neonPurple = Color(0xFF6366F1);
  static const Color frostIndigo = Color(0xFF4F46E5);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: frostIndigo,
        brightness: Brightness.light,
        surface: Colors.white,
        onSurface: const Color(0xFF1E293B), // Slate 800
      ),
      textTheme: baseTextTheme,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
      primaryColor: frostIndigo,
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: frostIndigo),
        unselectedIconTheme: IconThemeData(color: Colors.black54),
        selectedLabelTextStyle: TextStyle(
          color: frostIndigo,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        color: Colors.white.withValues(alpha: 0.7), // For glass effect
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? frostIndigo : null,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: neonPurple,
        brightness: Brightness.dark,
        surface: const Color(0xFF131A2C), // Cards
        onSurface: Colors.white,
      ),
      textTheme: baseTextTheme,
      scaffoldBackgroundColor: const Color(0xFF0B1120), // Deep navy background
      primaryColor: neonPurple,
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: neonPurple),
        unselectedIconTheme: IconThemeData(color: Colors.white54),
        selectedLabelTextStyle: TextStyle(
          color: neonPurple,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        color: const Color(
          0xFF131A2C,
        ).withValues(alpha: 0.6), // For glass effect
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? neonPurple : null,
        ),
      ),
    );
  }
}
