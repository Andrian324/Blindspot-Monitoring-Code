import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardAlt = Color(0xFF1A2236);
  static const Color accentBlue = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentRed = Color(0xFFFF3B5C);
  static const Color accentYellow = Color(0xFFFFD60A);
  static const Color textPrimary = Color(0xFFECF0F1);
  static const Color textSecondary = Color(0xFF8B9AB7);
  static const Color borderColor = Color(0xFF1E2D45);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentGreen,
        surface: bgCard,
        error: accentRed,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
        titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: accentBlue,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}