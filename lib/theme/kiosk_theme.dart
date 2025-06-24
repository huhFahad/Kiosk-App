// lib/theme/kiosk_theme.dart

import 'package:flutter/material.dart';

class KioskTheme {
  // --- BASE SIZES ---
  // We can tweak these base values to scale the whole app up or down.
  static const double _baseFontSize = 18.0;
  static const double _scale = 1.4; // A multiplier to make everything bigger

  // --- TEXT THEME ---
  static TextTheme get textTheme {
    return const TextTheme(
      // For large titles like "Welcome to Our Store"
      displayLarge: TextStyle(fontSize: _baseFontSize * 2.2 * _scale, fontWeight: FontWeight.bold),
      // For page titles in AppBars
      titleLarge: TextStyle(fontSize: _baseFontSize * 1.2 * _scale, fontWeight: FontWeight.w600),
      // For regular text, list tile titles
      bodyLarge: TextStyle(fontSize: _baseFontSize * _scale, color: Colors.black87),
      // For subtitles, helper text
      bodyMedium: TextStyle(fontSize: _baseFontSize * 0.75 * _scale, color: Colors.black54),
      // For button text
      labelLarge: TextStyle(fontSize: _baseFontSize * 1.1 * _scale, fontWeight: FontWeight.bold),
    );
  }

  // --- ELEVATED BUTTON THEME ---
  static ElevatedButtonThemeData get elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge,
      ),
    );
  }
  
  // --- CARD THEME ---
  static CardTheme get cardTheme {
    return CardTheme(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
  
  // --- LIST TILE THEME ---
  static ListTileThemeData get listTileTheme {
    return ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodyMedium,
    );
  }

  // --- INPUT DECORATION THEME (for TextFields) ---
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
    );
  }

  static IconThemeData get iconTheme {
    return IconThemeData(
      size: 28.0 * _scale, // Set a larger default icon size
    );
  }

  static AppBarTheme get appBarTheme {
    return AppBarTheme(
      toolbarHeight: 100.0 * _scale, 
      centerTitle: true,
      elevation: 4.0,
      titleTextStyle: (
        textTheme.titleLarge?.copyWith(
          color: Colors.black,
          fontSize: 50.0
          )      
      ),
      iconTheme: IconThemeData(
        size: 80,
      ),
    );
  }

  // --- THE MASTER THEME ---
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      appBarTheme: appBarTheme,
      textTheme: textTheme,
      iconTheme: IconThemeData(
        size: 28.0 * _scale,
        color: Colors.grey.shade800,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12.0 * _scale),
        ),
      ),
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: cardTheme,
      listTileTheme: listTileTheme,
      inputDecorationTheme: inputDecorationTheme,

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}