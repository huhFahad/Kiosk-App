// lib/map_page.dart
import 'dart:io';
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
  
  String? _customMapPath;
  final String _defaultMapPath = 'assets/images/placeholder_map.png';

  // We use a GlobalKey to find the map Image widget in the tree
  final GlobalKey _imageKey = GlobalKey();

  // We'll store the pin's position here after calculating it
  Offset? _pinPosition;

  Offset? _kioskPinPosition;

  @override
  void initState() {
    super.initState();
    _loadMapPath();
    // After the first frame is drawn, we run our calculation
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
  }

  // When the page is rebuilt with new arguments, we also need to recalculate
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePinPositions());
  }
  
  Future<void> _loadMapPath() async {
    final path = await _dataService.getStoreMapPath();
    if (mounted) {
      setState(() {
        _customMapPath = path;
      });
    }
  }

  void _calculatePinPositions() async {
    final Product? product = ModalRoute.of(context)?.settings.arguments as Product?;
    
    final kioskLocation = await _dataService.getKioskLocation();
    
    final RenderBox? imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null || !imageBox.hasSize) return;
    final imageSize = imageBox.size;
    
    // Calculate position for the product pin (if it exists)
    Offset? productPinPos;
    if (product != null && product.mapX >= 0 && product.mapY >= 0) {
      productPinPos = Offset(imageSize.width * product.mapX, imageSize.height * product.mapY);
    }
    
    // Calculate position for the kiosk pin (if it exists)
    Offset? kioskPinPos;
    if (kioskLocation != null) {
      kioskPinPos = Offset(imageSize.width * kioskLocation.dx, imageSize.height * kioskLocation.dy);
    }

    setState(() {
      _pinPosition = productPinPos; 
      _kioskPinPosition = kioskPinPos; 
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
        boundaryMargin: const EdgeInsets.all(double.infinity), // Allow free panning
        minScale: 0.5,
        maxScale: 4.0,
        child: Center( // Use Center to keep the map in the middle
          child: Stack(
            children: [
              // --- The Map Image ---
              // We assign the GlobalKey here
              if (useCustomMap)
                Image.file(File(_customMapPath!), key: _imageKey, errorBuilder: (c,e,s) => Image.asset(_defaultMapPath, key: _imageKey))
              else
                Image.asset(_defaultMapPath, key: _imageKey),

              // --- The Pin ---
              // We only show the pin if its position has been calculated
              if (_pinPosition != null)
                Positioned(
                  left: _pinPosition!.dx,
                  top: _pinPosition!.dy,
                  child: Transform.translate(
                    offset: const Offset(-24, -48), // Offset for the pin's tip
                    child: Tooltip(
                      message: product?.name ?? 'Location',
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 48,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5)],
                      ),
                    ),
                  ),
                ),
              if (_kioskPinPosition != null)
                Positioned(
                  left: _kioskPinPosition!.dx,
                  top: _kioskPinPosition!.dy,
                  child: Transform.translate(
                    offset: const Offset(-24, -48),
                    child: Tooltip(
                      message: 'You Are Here',
                      child: Icon(Icons.my_location, color: Colors.blue, size: 48),
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