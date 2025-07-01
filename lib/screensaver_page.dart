// lib/screensaver_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
      
      final playlist = Playlist([
        Media('asset://assets/videos/decor_ad_1.mp4'),
        Media('asset://assets/videos/decor_ad_2.mp4'),
        // Media('asset://assets/videos/ad_3.mp4'),
      ]);

      await _player.open(playlist);
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
    // return Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Image.asset("assets/images/urban_rain_logo.png", width: 700, fit: BoxFit.contain),
    //       const SizedBox(height: 32),
    //       Container(
    //         padding: const EdgeInsets.all(16.0),
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(32.0),
    //           color: Colors.white
    //         ),
    //         child: Shimmer.fromColors(
    //           highlightColor: const Color.fromARGB(255, 255, 250, 155),
    //           baseColor: const Color.fromARGB(150, 205, 200, 105),
    //           child: Text(
    //             'Welcome! Touch to Begin',
    //             style: Theme.of(context).textTheme.displayLarge,
    //             textAlign: TextAlign.center,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    return Center(
      child: Stack(
        children: [
          Positioned(
            bottom: 10,
            child: Shimmer.fromColors(
              highlightColor: Colors.blueAccent,
              baseColor: const Color.fromARGB(255, 255, 0, 0),
              period: Duration(seconds: 3),
              child: Text(
                'Welcome!\nTouch to Begin',
                style: TextStyle(
                  fontFamily: 'HighMount',
                  fontSize: 40,
                  color:Colors.white.withAlpha(230),
                ),
              )
              // child: Image.asset("assets/icons/Welcome!_Touch_to_begin.png", width: 300, fit: BoxFit.contain)
            )
          ),
        ],
      ),
    );
  }
}
