import 'package:flutter/material.dart';

class AppTheme {
  static const _gold = Color(0xFFCBA135);
  static const _platinum = Color(0xFFE5E4E2);
  static const _darkBg = Color(0xFF0B0B0C);
  static const _darkSurface = Color(0xFF1A1A1C);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _gold,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _gold,
          secondary: _platinum,
          background: _darkBg,
          surface: _darkSurface,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: _darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: _darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
        ),
        cardTheme: CardTheme(
          color: _darkSurface,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
        ),
        dividerColor: Colors.white24,
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _gold,
          brightness: Brightness.light,
        ).copyWith(
          primary: _gold,
          secondary: _platinum,
          background: Colors.white,
          surface: _platinum,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          headlineMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        cardTheme: CardTheme(
          color: _platinum,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
        ),
        dividerColor: Colors.grey.shade300,
      );
}
