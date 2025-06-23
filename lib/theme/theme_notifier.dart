// lib/theme/theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  final DataService _dataService = DataService();
  
  ThemeData _currentTheme = KioskTheme.themeData; // Start with default theme
  ThemeData get currentTheme => _currentTheme;

  ThemeNotifier() {
    // When the app starts, load the saved theme color
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final colorValue = await _dataService.getThemeColorValue();
    final color = Color(colorValue);
    _setTheme(color);
  }

  void _setTheme(Color primaryColor) {
    // We get a copy of our base theme and just override the color scheme
    _currentTheme = KioskTheme.themeData.copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(primaryColor),
      ).copyWith(
        secondary: primaryColor, // Often you want the accent color to match
      ),
      iconTheme: KioskTheme.iconTheme.copyWith(color: primaryColor),
      listTileTheme: KioskTheme.listTileTheme.copyWith(iconColor: primaryColor),
    );
    notifyListeners();
  }

  Future<void> updateThemeColor(Color newColor) async {
    // Save the new color value persistently
    await _dataService.saveThemeColorValue(newColor.value);
    // Update the current theme in the app
    _setTheme(newColor);
  }
  
  // Helper function to create a MaterialColor from a single Color.
  // This is needed for ThemeData's primarySwatch.
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}