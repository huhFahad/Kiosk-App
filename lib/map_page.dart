// lib/map_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/product_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TransformationController _transformationController = TransformationController();
  final DataService _dataService = DataService();
  final GlobalKey _imageKey = GlobalKey();

  String? _customMapPath;
  final String _defaultMapPath = 'assets/images/placeholder_map.png';

  Offset? _productPinPosition;
  Offset? _kioskPinPosition;
  bool _arePinsCalculated = false; // A flag to prevent repeated calculations

  @override
  void initState() {
    super.initState();
    // Start the process of loading paths and then calculating positions
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // First, load the path to the map image
    final path = await _dataService.getStoreMapPath();
    if (mounted) {
      setState(() {
        _customMapPath = path;
      });
      // After the state is set and the image widget is in the tree,
      // start trying to calculate the pin positions.
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
    }
  }
  
  // This is the new, robust calculation method
  void _calculatePinPositions() async {
    // If we've already successfully calculated the pins, don't do it again.
    if (_arePinsCalculated || !mounted) return;

    // Find the RenderBox of our Image widget using its key
    final imageContext = _imageKey.currentContext;
    if (imageContext == null) {
      // If the context isn't available yet, the widget hasn't been laid out.
      // We schedule this function to run again on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
      return;
    }

    final imageBox = imageContext.findRenderObject() as RenderBox;
    // Also check if it has a size yet.
    if (!imageBox.hasSize) {
      // If not, try again on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
      return;
    }
    
    // --- If we've reached this point, the image is guaranteed to have a size ---
    final imageSize = imageBox.size;
    
    // Get the data needed for the pins
    final Product? product = ModalRoute.of(context)?.settings.arguments as Product?;
    final kioskLocation = await _dataService.getKioskLocation();

    // Calculate position for the product pin
    Offset? productPinPos;
    if (product != null && product.mapX >= 0 && product.mapY >= 0) {
      productPinPos = Offset(imageSize.width * product.mapX, imageSize.height * product.mapY);
    }
    
    // Calculate position for the kiosk pin
    Offset? kioskPinPos;
    if (kioskLocation != null) {
      kioskPinPos = Offset(imageSize.width * kioskLocation.dx, imageSize.height * kioskLocation.dy);
    }

    // Update the state with the final, correct positions
    setState(() {
      _productPinPosition = productPinPos;
      _kioskPinPosition = kioskPinPos;
      _arePinsCalculated = true; // Mark as done!
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final Product? product = ModalRoute.of(context)?.settings.arguments as Product?;
    final bool useCustomMap = _customMapPath != null && _customMapPath!.isNotEmpty;

    return Scaffold(
      appBar: CommonAppBar(context: context, title: product != null ? 'Location for ${product.name}' : 'Store Map'),
      body: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Stack(
            children: [
              // The Map Image with the key
              if (useCustomMap)
                Image.file(File(_customMapPath!), key: _imageKey, errorBuilder: (c, e, s) => Image.asset(_defaultMapPath, key: _imageKey))
              else
                Image.asset(_defaultMapPath, key: _imageKey),
              
              // Show a loader only while we are waiting for the pins to be calculated
              if (!_arePinsCalculated)
                const Center(child: CircularProgressIndicator()),

              // The You Are Here Pin
              if (_kioskPinPosition != null)
                Positioned(
                  left: _kioskPinPosition!.dx,
                  top: _kioskPinPosition!.dy,
                  child: Transform.translate(
                    offset: const Offset(-24, -24),
                    child: const Tooltip(
                      message: 'You Are Here',
                      child: Icon(Icons.my_location, shadows:[Shadow(color: Colors.white, blurRadius: 10.0)], color: Colors.blue, size: 48),
                    ),
                  ),
                ),

              // The Product Pin
              if (_productPinPosition != null)
                Positioned(
                  left: _productPinPosition!.dx,
                  top: _productPinPosition!.dy,
                  child: Transform.translate(
                    offset: const Offset(-24, -43),
                    child: Tooltip(
                      message: product?.name ?? 'Product Location',
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        shadows: [Shadow(color: Colors.white, blurRadius: 10.0)],
                        size: 48,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _resetView, child: const Icon(Icons.center_focus_strong)),
    );
  }
}