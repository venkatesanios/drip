import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xff054750),
    primaryColorLight: const Color(0xff1A7785),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff1A7785),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(Colors.white),
      fillColor: WidgetStateProperty.all(const Color(0xff1D808E)),
      overlayColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.2)),
      side: const BorderSide(color: Color(0xff1D808E), width: 2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffB1FFCB),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Add border radius
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      labelStyle: const TextStyle(color: Colors.blue),
    ),
    tabBarTheme: TabBarTheme(
      indicatorColor: const Color(0xffB1FFCB),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey.shade400
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xff054750),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.grey.shade200,
      elevation: 4,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xff054750),
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSurface: Colors.black,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    primaryColorLight: const Color(0xff1D808E),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
      labelStyle: const TextStyle(color: Colors.teal),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.grey.shade900,
      elevation: 4,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.white,
      onSurface: Colors.white70,
    ),
    dialogBackgroundColor: Colors.white
  );
}