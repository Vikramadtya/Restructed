import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class AppTheme {
  static const Color neonPurple = Color(0xFF6366F1);
  static const Color frostIndigo = Color(0xFF4F46E5);

  static MacosThemeData get lightTheme {
    return MacosThemeData.light().copyWith(
      primaryColor: frostIndigo,
      canvasColor: const Color(0xFFF1F5F9), // Slate 100
      typography: MacosTypography(
        color: const Color(0xFF1E293B),
      ),
    );
  }

  static MacosThemeData get darkTheme {
    return MacosThemeData.dark().copyWith(
      primaryColor: neonPurple,
      canvasColor: const Color(0xFF0B1120), // Deep navy background
      typography: MacosTypography(
        color: MacosColors.white,
      ),
    );
  }
}
