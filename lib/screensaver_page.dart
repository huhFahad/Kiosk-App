import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class ScreensaverPage extends StatefulWidget {
  const ScreensaverPage({super.key});

  @override
  State<ScreensaverPage> createState() => _ScreensaverPageState();
}

class _ScreensaverPageState extends State<ScreensaverPage> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media('asset://assets/videos/screensaver_bg.mp4'));
    _player.setVolume(0);
    _player.setPlaylistMode(PlaylistMode.loop);
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
        body: Stack(
          children: [
            Video(controller: _controller),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/urban_rain_logo.png", width: 700, fit: BoxFit.contain),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome! Touch to Begin',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
