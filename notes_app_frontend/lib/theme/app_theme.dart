import 'package:flutter/material.dart';

class AppTheme {
  /// PUBLIC_INTERFACE
  /// Returns the app's primary light theme.
  static ThemeData get lightTheme {
    const primary = Color(0xFF1976D2);
    const accent = Color(0xFFFFEB3B);
    const secondary = Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: accent,
        background: secondary,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: secondary,
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: Color(0xFF1976D2),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      cardTheme: CardTheme(
        color: secondary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
