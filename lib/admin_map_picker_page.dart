// lib/admin_map_picker_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class AdminMapPickerPage extends StatefulWidget {
  const AdminMapPickerPage({Key? key}) : super(key: key);

  @override
  _AdminMapPickerPageState createState() => _AdminMapPickerPageState();
}

class _AdminMapPickerPageState extends State<AdminMapPickerPage> {
  final DataService _dataService = DataService();
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _imageKey = GlobalKey(); // The key for the image itself

  String? _customMapPath;
  final String _defaultMapPath = 'assets/images/placeholder_map.png';

  // This will store the tap position relative to the IMAGE WIDGET, in pixels.
  Offset? _pinPositionOnImage;

  @override
  void initState() {
    super.initState();
    _loadMapPath();
  }

  Future<void> _loadMapPath() async {
    final path = await _dataService.getStoreMapPath();
    if (mounted) setState(() => _customMapPath = path);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details) {
    // Get the RenderBox of the image itself using our key
    final imageContext = _imageKey.currentContext;
    if (imageContext == null) return;
    final imageBox = imageContext.findRenderObject() as RenderBox;

    // `details.globalPosition` is the tap position on the entire screen.
    // `globalToLocal` converts this screen coordinate into a coordinate
    // that is relative to the top-left corner of our Image widget.
    final localPosition = imageBox.globalToLocal(details.globalPosition);

    // Now we have the exact (x, y) tap position on the image itself.
    setState(() {
      _pinPositionOnImage = localPosition;
    });
  }

  void _confirmLocation() {
    if (_pinPositionOnImage == null) return;
    
    // Get the actual pixel size of the rendered image widget.
    final imageContext = _imageKey.currentContext;
    if (imageContext == null) return;
    final imageBox = imageContext.findRenderObject() as RenderBox;
    final imageSize = imageBox.size;

    // The pin position is already in the image's local coordinate system,
    // so the calculation is now direct and accurate.
    final double relativeX = _pinPositionOnImage!.dx / imageSize.width;
    final double relativeY = _pinPositionOnImage!.dy / imageSize.height;

    // Check if the tap was within the image bounds before returning.
    if (relativeX >= 0 && relativeX <= 1 && relativeY >= 0 && relativeY <= 1) {
      Navigator.of(context).pop({'x': relativeX, 'y': relativeY});
    } else {
      // This should rarely happen now, but it's a good safety check.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap directly on the map.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useCustomMap = _customMapPath != null && _customMapPath!.isNotEmpty;

    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Tap to Set Location'),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade800,
              // We use a GestureDetector on the whole area to capture taps
              child: GestureDetector(
                onTapUp: _handleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.2,
                  maxScale: 5.0,
                  boundaryMargin: const EdgeInsets.all(200.0),
                  child: Center(
                    // The Stack allows us to layer the pin on the image
                    child: Stack(
                      children: [
                        // The map image with the all-important GlobalKey
                        if (useCustomMap)
                          Image.file(File(_customMapPath!), key: _imageKey)
                        else
                          Image.asset(_defaultMapPath, key: _imageKey),

                        // The pin is positioned relative to the Stack (which is the image size)
                        if (_pinPositionOnImage != null)
                          Positioned(
                            left: _pinPositionOnImage!.dx,
                            top: _pinPositionOnImage!.dy,
                            child: Transform.translate(
                              offset: const Offset(-24, -43),
                              child: const IgnorePointer(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // The confirm button appears only after a tap
          if (_pinPositionOnImage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm This Location'),
                onPressed: _confirmLocation,
              ),
            )
        ],
      ),
    );
  }
}