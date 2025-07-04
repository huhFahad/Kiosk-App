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
  final GlobalKey _imageKey = GlobalKey();

  String? _customMapPath;
  final String _defaultMapPath = 'assets/images/placeholder_map.png';
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
    final imageContext = _imageKey.currentContext;
    if (imageContext == null) return;
    final imageBox = imageContext.findRenderObject() as RenderBox;

    final localPosition = imageBox.globalToLocal(details.globalPosition);

    setState(() {
      _pinPositionOnImage = localPosition;
    });
  }

  void _confirmLocation() {
    if (_pinPositionOnImage == null) return;
    
    final imageContext = _imageKey.currentContext;
    if (imageContext == null) return;
    final imageBox = imageContext.findRenderObject() as RenderBox;
    final imageSize = imageBox.size;

    final double relativeX = _pinPositionOnImage!.dx / imageSize.width;
    final double relativeY = _pinPositionOnImage!.dy / imageSize.height;

    if (relativeX >= 0 && relativeX <= 1 && relativeY >= 0 && relativeY <= 1) {
      Navigator.of(context).pop({'x': relativeX, 'y': relativeY});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap directly on the map.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useCustomMap = _customMapPath != null && _customMapPath!.isNotEmpty;

    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Tap to Set Location', showCartButton: false, showHomeButton: false),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade800,
              child: GestureDetector(
                onTapUp: _handleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.2,
                  maxScale: 5.0,
                  boundaryMargin: const EdgeInsets.all(200.0),
                  child: Center(
                    child: Stack(
                      children: [
                        if (useCustomMap)
                          Image.file(File(_customMapPath!), key: _imageKey)
                        else
                          Image.asset(_defaultMapPath, key: _imageKey),

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