// lib/loading_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:io';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    // Start the initialization process as soon as the page is created
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now(); // Mark the start

    try {
      MediaKit.ensureInitialized();
      await dotenv.load(fileName: ".env");

      if (Platform.isLinux) {
        final String encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? 'd3v3l0pm3ntK3y16';
        if (encryptionKey.length != 16) {
          throw Exception('Encryption key must be 16 characters long.');
        }
      }

      final elapsed = DateTime.now().difference(startTime);
      final delay = Duration(seconds: 5) - elapsed;

      if (delay > Duration.zero) {
        await Future.delayed(delay); // Ensure at least 2 seconds
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your store logo or a Flutter logo
            // const FlutterLogo(size: 100),
            Image.asset("assets/icons/loading.gif", width: 200, height: 200),
            // const SizedBox(height: 32),
            // const CircularProgressIndicator(),
            // const SizedBox(height: 16),
            // const Text('Initializing...'),
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Error: $_errorMessage', 
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}