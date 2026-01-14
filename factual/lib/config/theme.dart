import 'package:flutter/material.dart';

class FactualTheme {
  // 1. Color Palette (Extracted from Figma)
  static const Color _brandBlack = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFF1D1B20); // Dark surface
  static const Color _onSurface = Color(0xFF2F2F2F); // Primary Text
  static const Color _primaryGreen = Color(0xFF18C07A); // Positive/Action
  static const Color _errorRed = Color(0xFFB3261E); // Negative/Error
  static const Color _border = Color(0xFFE8ECF4); // Dividers
  static const Color _accessory = Color(0xFFB7B7B7); // Disabled/Subtle
  static const Color _filler = Color(0xFF8391A1); // Neutral/Placeholders

  // 2. Text Styles (Extracted from Figma)
  static const TextStyle _brandLogo = TextStyle(
    fontFamily: 'Roboto Condensed',
    fontWeight: FontWeight.w500,
    fontSize: 32,
    height: 28 / 32, // 0.875
    color: _brandBlack,
  );

  static const TextStyle _header1 = TextStyle(
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.3,
    color: _onSurface,
  );

  static const TextStyle _header2 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 24,
    height: 1.0,
    color: _onSurface,
  );

  static const TextStyle _header3 = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 24 / 20, // 1.2
    color: _onSurface,
  );

  static const TextStyle _bodyLarge = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.0,
    color: _onSurface,
  );

  static const TextStyle _bodyMedium = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.0,
    color: _onSurface,
  );

  static const TextStyle _labelLarge = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14, // 1.42
    letterSpacing: 0.1,
    color: _onSurface,
  );

  static const TextStyle _small = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.0,
    letterSpacing: 0.15,
    color: _accessory,
  );

  // 3. ThemeData Construction
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primaryGreen,
        onPrimary: _white,
        secondary: _brandBlack,
        onSecondary: _white,
        error: _errorRed,
        onError: _white,
        surface: _white,
        onSurface: _onSurface,
        outline: _border,
        outlineVariant: _accessory,
        surfaceContainerHighest: _filler,
      ),

      // Typography
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: _header1,
        headlineMedium: _header2,
        titleLarge: _header3,
        bodyLarge: _bodyLarge,
        bodyMedium: _bodyMedium,
        labelLarge: _labelLarge,
        labelSmall: _small,
        // Custom text style for Logo usage
        displayLarge: _brandLogo,
      ),

      // Component Themes
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: _white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _brandLogo,
        iconTheme: IconThemeData(color: _brandBlack, size: 24),
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: _border, width: 1)),
      ),

      // Cards
      // Cards
      cardTheme: CardThemeData(
        color: _white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: _border, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input Decoration (Search Bar)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: _bodyLarge.copyWith(color: _accessory),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryGreen, width: 2),
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: _brandBlack,
        size: 24,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: _border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
