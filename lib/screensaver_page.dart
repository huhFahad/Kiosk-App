// lib/screensaver_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';

class ScreensaverPage extends StatefulWidget {
  const ScreensaverPage({Key? key}) : super(key: key);

  @override
  _ScreensaverPageState createState() => _ScreensaverPageState();
}

class _ScreensaverPageState extends State<ScreensaverPage> {
  final DataService _dataService = DataService();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final path = await _dataService.getScreensaverImagePath();
    if (mounted) {
      setState(() {
        _imagePath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildScreensaverContent(),
      ),
    );
  }
  
  Widget _buildScreensaverContent() {
    // If a custom image path exists AND it's not empty, display it.
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      );
    }
    
    // Otherwise, show the default content.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/urban_rain_logo.png",
            width: 700,
            // height: 500,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome! Touch to Begin',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}