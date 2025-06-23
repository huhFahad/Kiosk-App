// lib/widgets/inactivity_detector.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kiosk_app/models/cart_model.dart';
import 'package:kiosk_app/notifiers/settings_notifier.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class InactivityDetector extends StatefulWidget {
  final Widget child;
  const InactivityDetector({Key? key, required this.child}) : super(key: key);

  @override
  _InactivityDetectorState createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  Timer? _inactivityTimer;
  late SettingsNotifier _settingsNotifier;

  @override
  void initState() {
    super.initState();
    // We get the notifier instance once, but we don't listen here.
    _settingsNotifier = Provider.of<SettingsNotifier>(context, listen: false);
    // Add a listener to it. This is the key.
    _settingsNotifier.addListener(_onSettingsChanged);
    
    // Start the timer with the initial settings
    _resetTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    // IMPORTANT: Always remove listeners in dispose
    _settingsNotifier.removeListener(_onSettingsChanged);
    super.dispose();
  }

  // This function will be called by the notifier WHENEVER a setting changes.
  void _onSettingsChanged() {
    print("Settings changed! Resetting timer with new values.");
    // When settings change, simply reset the timer.
    // The reset function will automatically use the new values from the notifier.
    _resetTimer();
  }

  void _resetTimer() {
    // Always cancel the old timer before starting a new one.
    _inactivityTimer?.cancel();
    
    // Read the LATEST values directly from the notifier instance.
    if (_settingsNotifier.isScreensaverEnabled) {
      _inactivityTimer = Timer(
        Duration(seconds: _settingsNotifier.timeoutDurationSeconds),
        _handleTimeout,
      );
    }
  }

  void _handleTimeout() {
    print('User has been inactive. Showing screensaver...');
    
    // This logic is correct.
    _inactivityTimer?.cancel();
    navigatorKey.currentState?.pushNamed('/screensaver').then((_) {
      _resetTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Listener just resets the currently running timer.
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}