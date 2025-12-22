
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sal7nyTheme {
  static const Color primaryColor = Color(0xFF1565C0); // Deep Blue
  static const Color secondaryColor = Color(0xFFFFB300); // Amber/Gold accent
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Text Theme
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: const TextStyle(color: Colors.black87),
        bodyMedium: const TextStyle(color: Colors.black54),
      ),
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo', // Fallback or if using GoogleFonts.cairo().fontFamily
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      /*
      // Card Theme - Commented out due to type conflict in environment
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      */
    );
  }
}
