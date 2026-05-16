import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors from Spec
  static const primaryColor = Color(0xFF20878E); // Teal
  static const secondaryColor = Color(0xFFF59E0B); // Amber

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0F172A),
        onSurfaceVariant: const Color(0xFF475569),
        error: const Color(0xFFEF4444),
        outline: const Color(0xFFE2E8F0),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      dividerColor: const Color(0xFFE2E8F0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFF1E293B),
        onSurface: const Color(0xFFF8FAFC),
        onSurfaceVariant: const Color(0xFF94A3B8),
        error: const Color(0xFFF87171),
        outline: const Color(0xFF334155),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      dividerColor: const Color(0xFF334155),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
      ),
    );
  }
}
