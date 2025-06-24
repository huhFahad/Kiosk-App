// lib/map_page.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/product_model.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:kiosk_app/services/data_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TransformationController _transformationController = TransformationController();
  final DataService _dataService = DataService();
  
  bool _isLoading = true;
  ui.Image? _mapUiImage;

  final String _defaultMapPath = 'assets/images/placeholder_map.png';

  // We'll store the pin's position here after calculating it
  Offset? _productPinPosition;

  Offset? _kioskPinPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndCalculatePositions();
    });
  }
  
  Future<void> _loadDataAndCalculatePositions() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    // --- Step 1: Determine which map path to use ---
    final customPath = await _dataService.getStoreMapPath();
    final bool useCustomMap = customPath != null && customPath.isNotEmpty;
    final imagePath = useCustomMap ? customPath : _defaultMapPath;

    // --- Step 2: Load that image data and get its dimensions ---
    final imageCompleter = Completer<ui.Image>();
    late ImageStreamListener listener;
    
    ImageStream stream = useCustomMap
      ? FileImage(File(imagePath)).resolve(const ImageConfiguration())
      : AssetImage(imagePath).resolve(const ImageConfiguration());

    listener = ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      // Once the image is decoded, complete the future and clean up the listener
      imageCompleter.complete(imageInfo.image);
      stream.removeListener(listener);
    });
    
    stream.addListener(listener);
    final loadedImage = await imageCompleter.future;

    // --- Step 3: Now that we have the image size, calculate pin positions ---
    final Product? product = ModalRoute.of(context)?.settings.arguments as Product?;
    final kioskLocation = await _dataService.getKioskLocation();
    
    final imageSize = Size(loadedImage.width.toDouble(), loadedImage.height.toDouble());

    Offset? productPinPos;
    if (product != null && product.mapX >= 0 && product.mapY >= 0) {
      productPinPos = Offset(imageSize.width * product.mapX, imageSize.height * product.mapY);
    }
    
    Offset? kioskPinPos;
    if (kioskLocation != null) {
      kioskPinPos = Offset(imageSize.width * kioskLocation.dx, imageSize.height * kioskLocation.dy);
    }

    // --- Step 4: Update state with all new data to trigger a final rebuild ---
    if(mounted) {
      setState(() {
        _mapUiImage = loadedImage;
        _productPinPosition = productPinPos;
        _kioskPinPosition = kioskPinPos;
        _isLoading = false; // Turn off the loading indicator
      });
    }
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
    
    return Scaffold(
      appBar: CommonAppBar(context: context, title: product != null ? 'Location for ${product.name}' : 'Store Map'),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Stack(
                children: [
                  // Layer 1: The map image, now drawn efficiently with RawImage
                  if (_mapUiImage != null)
                    RawImage(image: _mapUiImage),
                  
                  // Layer 2: The "You Are Here" pin (BLUE)
                  if (_kioskPinPosition != null)
                    Positioned(
                      left: _kioskPinPosition!.dx,
                      top: _kioskPinPosition!.dy,
                      child: Transform.translate(
                        offset: const Offset(-24, -24),
                        child: const Tooltip(
                          message: 'You Are Here',
                          child: Icon(Icons.my_location, color: Colors.blue, size: 48),
                        ),
                      ),
                    ),

                  // Layer 3: The Product pin (RED)
                  if (_productPinPosition != null)
                    Positioned(
                      left: _productPinPosition!.dx,
                      top: _productPinPosition!.dy,
                      child: Transform.translate(
                        offset: const Offset(-24, -48),
                        child: Tooltip(
                          message: product?.name ?? 'Product Location',
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48,
                            shadows: [Shadow(color: const ui.Color.fromARGB(255, 255, 255, 255).withOpacity(1.0), blurRadius: 10)],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetView,
        tooltip: 'Reset View',
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}