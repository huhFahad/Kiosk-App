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
  final GlobalKey _mapKey = GlobalKey();

  String? _customMapPath;
  final String _defaultMapPath = 'assets/images/placeholder_map.png';

  // State to hold the temporary pin location
  Offset? _tappedPosition;

  @override
  void initState() {
    super.initState();
    _loadMapPath();
  }
  
  Future<void> _loadMapPath() async {
    final path = await _dataService.getStoreMapPath();
    if (mounted) {
      setState(() {
        _customMapPath = path;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails details) {
    // Get the position of the tap within the GestureDetector
    final tapPosition = details.localPosition;
    
    // We also need the current transformation (zoom/pan) of the InteractiveViewer
    // to correctly map the screen tap to a point on the image.
    // This requires converting from screen coordinates to scene (image) coordinates.
    final scenePos = _transformationController.toScene(tapPosition);

    setState(() {
      _tappedPosition = scenePos;
    });
  }

  void _confirmLocation() {
    if (_tappedPosition == null) return;
    
    // Get the total size of the map image widget
    final RenderBox? renderBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final imageSize = renderBox.size;

    // Calculate the relative coordinates (0.0 to 1.0)
    final double relativeX = _tappedPosition!.dx / imageSize.width;
    final double relativeY = _tappedPosition!.dy / imageSize.height;

    // Pop the page and return the coordinates as a result
    Navigator.of(context).pop({'x': relativeX, 'y': relativeY});
  }

  @override
  Widget build(BuildContext context) {
    final bool useCustomMap = _customMapPath != null && _customMapPath!.isNotEmpty;
    
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Tap to Set Product Location', showCartButton: false, showHomeButton: false),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.2,
            maxScale: 5.0,
            // The child is our map inside a GestureDetector
            child: GestureDetector(
              onTapUp: _onTapUp,
              child: Stack(
                children: [
                  // The map image with our GlobalKey
                  if (useCustomMap)
                    Image.file(File(_customMapPath!), key: _mapKey)
                  else
                    Image.asset(_defaultMapPath, key: _mapKey),

                  // Show a pin at the tapped location
                  if (_tappedPosition != null)
                    Positioned(
                      left: _tappedPosition!.dx - 24, // Center the pin
                      top: _tappedPosition!.dy - 48, // Offset for the pin's tip
                      child: Icon(Icons.location_on, color: Colors.blue, size: 48),
                    )
                ],
              ),
            ),
          ),
          
          // "Confirm" button at the bottom
          if (_tappedPosition != null)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.check_circle),
                  label: Text('Confirm This Location'),
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}