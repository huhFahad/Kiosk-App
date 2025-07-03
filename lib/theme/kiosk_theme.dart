// lib/theme/kiosk_theme.dart

import 'package:flutter/material.dart';

class KioskTheme {
  static const double _baseFontSize = 20.0;
  static double _scale = 1.0;
  static double get scale => _scale;

  static void setScaleFromWidth(double width) {
    if (width < 600) {
      _scale = 0.8;
    } else if (width < 900) {
      _scale = 1.1;
    } else if (width < 1200) {
      _scale = 1.3;
    } else {
      _scale = 1.5;
    }
  }

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: TextStyle(fontSize: _baseFontSize * 2.2 * _scale, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: _baseFontSize * 1.2 * _scale, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: _baseFontSize * _scale, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: _baseFontSize * 0.75 * _scale, color: Colors.black54),
      labelLarge: TextStyle(fontSize: _baseFontSize * 1.1 * _scale, fontWeight: FontWeight.bold),
    );
  }

  static ElevatedButtonThemeData get elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24 * _scale, vertical: 20 * _scale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * _scale),
        ),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static CardTheme get cardTheme {
    return CardTheme(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12 * _scale, vertical: 8 * _scale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * _scale),
      ),
    );
  }

  static ListTileThemeData get listTileTheme {
    return ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 24 * _scale, vertical: 16 * _scale),
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodyMedium,
    );
  }

  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * _scale),
        borderSide: const BorderSide(width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20 * _scale, vertical: 22 * _scale),
    );
  }

  static IconThemeData get iconTheme {
    return IconThemeData(
      size: 28.0 * _scale,
    );
  }

  static AppBarTheme get appBarTheme {
    return AppBarTheme(
      toolbarHeight: 100.0 * _scale,
      centerTitle: true,
      elevation: 4.0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.black,
        fontSize: 50.0 * _scale,
      ),
      iconTheme: IconThemeData(
        size: 80 * _scale,
      ),
    );
  }

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Lorin',
      appBarTheme: appBarTheme,
      textTheme: textTheme,
      iconTheme: iconTheme,
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          padding: EdgeInsets.all(12.0 * _scale),
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
