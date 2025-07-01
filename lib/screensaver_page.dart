// // lib/screensaver_page.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:kiosk_app/services/data_service.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class ScreensaverPage extends StatefulWidget {
//   const ScreensaverPage({Key? key}) : super(key: key);

//   @override
//   State<ScreensaverPage> createState() => _ScreensaverPageState();
// }

// class _ScreensaverPageState extends State<ScreensaverPage> {
//   final DataService _dataService = DataService();
//   String? _imagePath;

//   late final Player _player;
//   late final VideoController _controller;

//   bool _videoInitialized = false;
//   bool _videoError = false;

//   @override
//   void initState() {
//     super.initState();
//     _player = Player();
//     _controller = VideoController(_player);
//     _initializeVideo();
//     _loadCustomImage();
//   }

//   bool _isProbablyEmulator() {
//     if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
//       return true;
//     }
//     return false;
//   }

//   Future<void> _loadCustomImage() async {
//     final path = await _dataService.getScreensaverImagePath();
//     if (mounted) setState(() => _imagePath = path);
//   }

//   Future<void> _initializeVideo() async {
//     if (_isProbablyEmulator()) {
//       print("Emulator detected. Skipping video initialization.");
//       setState(() => _videoError = true);
//       return;
//     }

//     try {
//       await _player.open(
//         Playlist([
//           Media('asset://assets/videos/decor_ad_1.mp4'),
//           Media('asset://assets/videos/decor_ad_2.mp4'),
//         ]),
//         play: true,
//       );
//       await _player.setVolume(0.0);
//       await _player.setPlaylistMode(PlaylistMode.loop);

//       if (mounted) setState(() => _videoInitialized = true);
//     } catch (e) {
//       print("Video initialization error: $e");
//       if (mounted) setState(() => _videoError = true);
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.of(context).pop(),
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: _buildScreensaverContent(),
//       ),
//     );
//   }

//   Widget _buildScreensaverContent() {
//     if (_imagePath != null && _imagePath!.isNotEmpty) {
//       return Image.file(
//         File(_imagePath!),
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//       );
//     }

//     if (_videoInitialized && !_videoError) {
//       return Stack(
//         children: [
//           Positioned.fill(
//             child: IgnorePointer(
//               child: Video(
//                 controller: _controller,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           _buildOverlayContent(),
//         ],
//       );
//     }

//     // Fallback image when video fails or not initialized
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: Image.asset(
//             'assets/images/screensaver_fallback.jpg',
//             fit: BoxFit.cover,
//           ),
//         ),
//         _buildOverlayContent(),
//       ],
//     );
//   }

//   Widget _buildOverlayContent() {
//     return Center(
//       child: Stack(
//         children: [
//           Positioned(
//             bottom: 10,
//             right: 10,
//             child: Shimmer.fromColors(
//               highlightColor: Colors.blueAccent,
//               baseColor: const Color.fromARGB(255, 255, 0, 0),
//               period: const Duration(seconds: 3),
//               child: Text(
//                 'Welcome!\nTouch to Begin',
//                 style: TextStyle(
//                   fontFamily: 'HighMount',
//                   fontSize: 40,
//                   color: Colors.white.withAlpha(230),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// lib/screensaver_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shimmer/shimmer.dart';

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

@override
void initState() {
super.initState();
_player = Player();
_controller = VideoController(_player);
// Kick off both async operations at the same time
_initializePlayer();
_loadCustomImage();
}

Future<void> _loadCustomImage() async {
final path = await _dataService.getScreensaverImagePath();
if (mounted) setState(() => _imagePath = path);
}

Future<void> _initializePlayer() async {
try {
await _player.open(
Playlist([
Media('asset://assets/videos/decor_ad_1.mp4'),
Media('asset://assets/videos/decor_ad_2.mp4'),
]),
play: true, // Start playing immediately
);
await _player.setVolume(0.0);
await _player.setPlaylistMode(PlaylistMode.loop);
} catch (e) {
print("Video initialization error: $e");
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
// Priority 1: Admin's custom image. If it exists, show it and nothing else.
if (_imagePath != null && _imagePath!.isNotEmpty) {
return Image.file(
File(_imagePath!),
fit: BoxFit.cover,
width: double.infinity,
height: double.infinity,
);
}

      
return Stack(
  children: [
    Positioned.fill(
      child: IgnorePointer(
        child: Video(
          controller: _controller,
          fit: BoxFit.cover,
        ),
      ),
    ),
    _buildOverlayContent(),
  ],
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
        right: 10,
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