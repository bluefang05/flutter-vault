import 'package:flutter/material.dart';

abstract final class NbndTheme {
  static const Color background = Color(0xFF090A12);
  static const Color surface = Color(0xFF151727);
  static const Color primary = Color(0xFFB58CFF);
  static const Color secondary = Color(0xFF55E6C1);
  static const Color accent = Color(0xFFFF9B62);

  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardTheme: const CardThemeData(color: surface, margin: EdgeInsets.zero),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
