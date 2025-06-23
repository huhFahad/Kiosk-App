// lib/notifiers/settings_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:kiosk_app/services/data_service.dart';

class SettingsNotifier extends ChangeNotifier {
  final DataService _dataService = DataService();

  // --- State variables ---
  bool _isScreensaverEnabled = true;
  int _timeoutDurationSeconds = 90;
  
  // --- Public getters ---
  bool get isScreensaverEnabled => _isScreensaverEnabled;
  int get timeoutDurationSeconds => _timeoutDurationSeconds;

  SettingsNotifier() {
    // When the app starts, load all settings
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isScreensaverEnabled = await _dataService.getScreensaverEnabled();
    _timeoutDurationSeconds = await _dataService.getTimeoutDuration();
    // Notify listeners after loading initial settings
    notifyListeners();
  }

  // --- Methods to update settings ---

  Future<void> updateScreensaverEnabled(bool isEnabled) async {
    _isScreensaverEnabled = isEnabled;
    await _dataService.saveScreensaverEnabled(isEnabled);
    // Notify all listeners that this value has changed
    notifyListeners();
  }

  Future<void> updateTimeoutDuration(int seconds) async {
    _timeoutDurationSeconds = seconds;
    await _dataService.saveTimeoutDuration(seconds);
    // Notify all listeners that this value has changed
    notifyListeners();
  }
}