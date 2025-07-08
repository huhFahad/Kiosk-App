// lib/map_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/product_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
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
  bool _arePinsCalculated = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // First, load the path to the map image
    final path = await _dataService.getStoreMapPath();
    if (mounted) {
      setState(() {
        _customMapPath = path;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
    }
  }
  
  void _calculatePinPositions() async {
    if (_arePinsCalculated || !mounted) return;

    final imageContext = _imageKey.currentContext;
    if (imageContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
      return;
    }

    final imageBox = imageContext.findRenderObject() as RenderBox;
    if (!imageBox.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
      return;
    }
    
    final imageSize = imageBox.size;

    final Product? product = ModalRoute.of(context)?.settings.arguments as Product?;
    final kioskLocation = await _dataService.getKioskLocation();

    Offset? productPinPos;
    if (product != null && product.mapX >= 0 && product.mapY >= 0) {
      productPinPos = Offset(imageSize.width * product.mapX, imageSize.height * product.mapY);
    }

    Offset? kioskPinPos;
    if (kioskLocation != null) {
      kioskPinPos = Offset(imageSize.width * kioskLocation.dx, imageSize.height * kioskLocation.dy);
    }

    setState(() {
      _productPinPosition = productPinPos;
      _kioskPinPosition = kioskPinPos;
      _arePinsCalculated = true;
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
    final scale = KioskTheme.scale;
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
              if (useCustomMap)
                Image.file(File(_customMapPath!), key: _imageKey, errorBuilder: (c, e, s) => Image.asset(_defaultMapPath, key: _imageKey))
              else
                Image.asset(_defaultMapPath, key: _imageKey),
              
              if (!_arePinsCalculated)
                const Center(child: CircularProgressIndicator()),

              if (_kioskPinPosition != null)
                Positioned(
                  left: _kioskPinPosition!.dx,
                  top: _kioskPinPosition!.dy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: Offset(-23 * scale, -23 * scale),
                        child: Tooltip(
                          message: 'You Are Here',
                          child: Icon(Icons.my_location, shadows:[Shadow(color: Colors.white, blurRadius: 10.0)], color: Colors.blue, size: 46 * scale),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-51 * scale, -20 * scale),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              "You are here",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15 * scale,
                                ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ),

              // The Product Pin
              if (_productPinPosition != null)
                Positioned(
                  left: _productPinPosition!.dx,
                  top: _productPinPosition!.dy,
                  child: Transform.translate(
                    offset: Offset(-24 * scale, -43 * scale),
                    child: Tooltip(
                      message: product?.name ?? 'Product Location',
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        shadows: [Shadow(color: Colors.white, blurRadius: 10.0)],
                        size: 48 * scale,
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