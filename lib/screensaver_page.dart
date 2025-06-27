// lib/screensaver_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:kiosk_app/services/data_service.dart';

class ScreensaverPage extends StatefulWidget {
  const ScreensaverPage({Key? key}) : super(key: key);

  @override
  State<ScreensaverPage> createState() => _ScreensaverPageState();
}

class _ScreensaverPageState extends State<ScreensaverPage> {
  final DataService _dataService = DataService();
  String? _imagePath;

  late final Player _player;
  late final VideoController _controller;
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
      _player = Player();
      _controller = VideoController(
        _player,
        configuration: const VideoControllerConfiguration(
          hwdec: 'no', 
        ),
      );

      await _player.open(
        Media('asset://assets/videos/screensaver_bg.mp4'),
      );
      await _player.setVolume(0.0);
      await _player.setPlaylistMode(PlaylistMode.loop);

      setState(() {
        _videoInitialized = true;
      });
    } catch (e) {
      print("Video initialization error: $e");
      setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
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

    if (_videoInitialized && !_videoError) {
      return Stack(
        children: [
          SizedBox(
            width: _player.state.width?.toDouble() ?? double.maxFinite,
            height: _player.state.height?.toDouble() ?? double.maxFinite,
            child: IgnorePointer(  
              child: Video(
                fit: BoxFit.cover,
                controller: _controller
              ),
            ),
          ),
          _buildOverlayContent(),
        ],
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/screensaver_fallback.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          _buildOverlayContent(),
        ],
      ),
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
