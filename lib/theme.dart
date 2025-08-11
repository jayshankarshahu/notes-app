import 'package:flutter/material.dart';

/// ===== Light Theme Colors =====
const Color lightBackground = Color(0xFFFAFAFA);
const Color lightSurface = Color(0xFFFFFFFF);
const Color lightPrimaryText = Color(0xFF1A1A1A);
const Color lightSecondaryText = Color(0xFF5C5C5C);
const Color lightPrimaryAccent = Color(0xFF3B82F6);
const Color lightSecondaryAccent = Color(0xFFF59E0B);
const Color lightBorder = Color(0xFFE5E5E5);
const Color lightSuccess = Color(0xFF10B981);
const Color lightWarning = Color(0xFFF59E0B);
const Color lightError = Color(0xFFEF4444);

/// ===== Dark Theme Colors =====
const Color darkBackground = Color(0xFF121212);
const Color darkSurface = Color(0xFF1E1E1E);
const Color darkPrimaryText = Color(0xFFF5F5F5);
const Color darkSecondaryText = Color(0xFFA1A1A1);
const Color darkPrimaryAccent = Color(0xFF60A5FA);
const Color darkSecondaryAccent = Color(0xFFFBBF24);
const Color darkBorder = Color(0xFF2D2D2D);
const Color darkSuccess = Color(0xFF34D399);
const Color darkWarning = Color(0xFFFBBF24);
const Color darkError = Color(0xFFF87171);

/// ===== ThemeData Config =====
class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: lightPrimaryAccent,
    colorScheme: ColorScheme.light(
      primary: lightPrimaryAccent,
      secondary: lightSecondaryAccent,
      surface: lightBackground,
      onSurface: lightSurface,
      error: lightError,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightPrimaryText),
      bodyMedium: TextStyle(color: lightSecondaryText),
      titleLarge: TextStyle(
        color: lightPrimaryText,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightPrimaryText,
      elevation: 0,
    ),
    dividerColor: lightBorder,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: lightBorder),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      // elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: lightBorder, width: 1),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: darkPrimaryAccent,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryAccent,
      secondary: darkSecondaryAccent,
      surface: darkBackground,
      onSurface: darkSurface,
      error: darkError,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkPrimaryText),
      bodyMedium: TextStyle(color: darkSecondaryText),
      titleLarge: TextStyle(
        color: darkPrimaryText,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkPrimaryText,
      elevation: 0,
    ),
    dividerColor: darkBorder,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: darkBorder),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A1A), // Slightly lighter than background
      // elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
  );
}
