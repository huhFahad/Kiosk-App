// lib/thank_you_page.dart
import 'dart:async';
import 'package:flutter/material.dart';

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({Key? key}) : super(key: key);

  @override
  _ThankYouPageState createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // After 10 seconds, automatically go back to the home screen.
    _timer = Timer(const Duration(seconds: 10), _goHome);
  }

  @override
  void dispose() {
    // IMPORTANT: Cancel the timer to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  void _goHome() {
    // Ensure the widget is still mounted before navigating
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 150),
              const SizedBox(height: 32),
              const Text(
                'Thank You!',
                style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your print job has been sent. Please proceed to the counter for payment and collection.',
                style: TextStyle(fontSize: 24, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // A single, clear button to finish the transaction
              SizedBox(
                width: 400,
                child: ElevatedButton(
                  onPressed: _goHome, // The button also goes home
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: const Text('Finish & Return Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}