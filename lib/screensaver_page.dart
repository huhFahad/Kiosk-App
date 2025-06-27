// lib/screensaver_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:kiosk_app/services/data_service.dart';

class ScreensaverPage extends StatefulWidget {
  const ScreensaverPage({Key? key}) : super(key: key);

  @override
  State<ScreensaverPage> createState() => _ScreensaverPageState();
}

class _ScreensaverPageState extends State<ScreensaverPage> {
  final DataService _dataService = DataService();
  String? _imagePath;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _loadCustomImage();
    _initializeVideo();
  }

  Future<void> _loadCustomImage() async {
    final path = await _dataService.getScreensaverImagePath();
    if (mounted) {
      setState(() => _imagePath = path);
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/videos/screensaver_bg.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true,),
      )..initialize().then((_) {
          _videoController?.setLooping(true);
          _videoController?.setVolume(0.0);
          _videoController?.play();
          if (mounted) {
            setState(() => _videoInitialized = true);
          }
        });
    } catch (e) {
      print("Video init error: $e");
      setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_videoInitialized && _videoController != null && !_videoError) {
      return Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
          _buildOverlayContent(),
        ],
      );
    }

    // fallback: just overlay
    return Container(
      color: Colors.black,
      child: Stack(
        children: [ 
          Image.asset('assets/images/screensaver_fallback.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          _buildOverlayContent(),
        ]
      )
    );
  }

  Widget _buildOverlayContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/urban_rain_logo.png", width: 700, fit: BoxFit.contain),
          const SizedBox(height: 32),
          Text(
            'Welcome! Touch to Begin',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 8),
                  ],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
