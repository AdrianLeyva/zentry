import 'package:flutter/material.dart';

class AppTheme {
  static const _gold = Color(0xFFCBA135);
  static const _softBlack = Color(0xFF1A1A1A);
  static const _platinum = Color(0xFFE2E2DF);
  static const _grayText = Color(0xFFB0B0AA);

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: _gold,
      onPrimary: _softBlack,
      secondary: _platinum,
      onSecondary: _softBlack,
      surface: _softBlack,
      onSurface: _platinum,
      error: Colors.red.shade700,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _softBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: _softBlack,
      foregroundColor: _platinum,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: _platinum),
      headlineMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: _platinum),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: _platinum),
      bodyLarge: TextStyle(fontSize: 16, color: _platinum),
      bodyMedium: TextStyle(fontSize: 14, color: _grayText),
    ),
    cardTheme: CardTheme(
      color: _softBlack.withAlpha((0.85 * 255).round()),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _gold,
        foregroundColor: _softBlack,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 8,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _gold,
      foregroundColor: _softBlack,
    ),
    dividerColor: _platinum.withAlpha((0.3 * 255).round()),
  );
}
