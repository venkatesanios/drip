import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'oro_theme.dart';

Color primaryDark = const Color(0xFF005C8F);
// Color primary = const Color(0xFF1B8BCB);

class SmartCommTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColorDark: primaryDark,
    primaryColor: primaryDark,
    primaryColorLight: primaryDark,
    scaffoldBackgroundColor:  Colors.blueGrey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
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
    dialogBackgroundColor: Colors.white,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: primary,
      elevation: 0,
      labelType: NavigationRailLabelType.all,
      indicatorColor: primaryDark,
      unselectedIconTheme: IconThemeData(color: Colors.white54),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return lightTheme.primaryColor.withAlpha(7);
          }
          return Colors.grey[300];
        },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
        iconColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.black,
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
              (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? Colors.blueGrey : Colors.grey,
            width: 0.5,
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.roboto(fontSize: 22, color: Colors.black),
      titleMedium: GoogleFonts.roboto(fontSize: 15, color: Colors.black),
      titleSmall: GoogleFonts.roboto(fontSize: 12, color: Colors.black),

      headlineLarge: GoogleFonts.roboto(fontSize: 20, color: Colors.black),

      bodyLarge: GoogleFonts.roboto(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
      bodyMedium: GoogleFonts.roboto(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
      bodySmall: GoogleFonts.roboto(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[100],
      shadowColor: Colors.black,
      surfaceTintColor: Colors.teal[200],
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
      colorScheme: ColorScheme.fromSeed(
        primary: primaryDark,
        secondary: primaryDark,
        surface: Colors.white,
        background: lightThemeBackGroundColor,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
        seedColor: primaryDark,
      )
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColorDark: primaryDark,
    primaryColor: primaryDark,
    primaryColorLight: primaryDark,
    scaffoldBackgroundColor:  darkThemeBackGroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      indicatorColor: Colors.white70,
      labelColor: Colors.white70,
      unselectedLabelColor: Colors.white54,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
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
    dialogBackgroundColor: Colors.white,
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFF036673),
      elevation: 0,
      labelType: NavigationRailLabelType.all,
      indicatorColor: Color(0x6438D3E8),
      unselectedIconTheme: IconThemeData(color: Colors.white54),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return lightTheme.primaryColor.withAlpha(1);
          }
          return Colors.grey[300];
        },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
        iconColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.black,
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
              (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? Colors.blueGrey : Colors.grey,
            width: 0.5,
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.roboto(fontSize: 22, color: Colors.grey),
      titleMedium: GoogleFonts.roboto(fontSize: 15, color: Colors.grey),
      titleSmall: GoogleFonts.roboto(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.roboto(fontSize: 20, color: Colors.grey),

      bodyLarge: GoogleFonts.roboto(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold),
      bodyMedium: GoogleFonts.roboto(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
      bodySmall: GoogleFonts.roboto(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardTheme(
      color: Colors.white24,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.teal[200],
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primaryDark,
      surface: Colors.grey[100]!,
      background: Colors.grey[100]!,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.dark,
    )
  );
}