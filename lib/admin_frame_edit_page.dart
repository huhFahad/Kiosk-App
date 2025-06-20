// lib/admin_frame_edit_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:uuid/uuid.dart';
import 'models/frame_model.dart';
import 'services/data_service.dart';

class AdminFrameEditPage extends StatefulWidget {
  // If a frame is passed, we are in "edit" mode.
  // If null, we are in "add" mode.
  final Frame? frame;

  const AdminFrameEditPage({Key? key, this.frame}) : super(key: key);

  @override
  _AdminFrameEditPageState createState() => _AdminFrameEditPageState();
}

class _AdminFrameEditPageState extends State<AdminFrameEditPage> {
  final _dataService = DataService();
  final _nameController = TextEditingController();

  // State for the frame image
  File? _frameImageFile; // A new image picked from the gallery
  String? _frameImagePath; // The existing path (from assets or app storage)

  double _windowX = 0.1;
  double _windowY = 0.1;
  double _windowWidth = 0.8;
  double _windowHeight = 0.8;

  // We need the size of the displayed image to calculate relative coordinates
  // Size _displayedImageSize = Size.zero;
  final _imageKey = GlobalKey(); // To get the size of the Image widget

  bool get _isEditing => widget.frame != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      // Pre-fill fields if we are editing
      _nameController.text = widget.frame!.name;
      _frameImagePath = widget.frame!.imagePath;
      // Load the saved relative values
      _windowX = widget.frame!.photoX;
      _windowY = widget.frame!.photoY;
      _windowWidth = widget.frame!.photoWidth;
      _windowHeight = widget.frame!.photoHeight;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFrameImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _frameImageFile = File(pickedFile.path);
        _frameImagePath = null; // Prioritize the newly picked file
      });
    }
  }

  void _saveFrame() async {
    if (_nameController.text.isEmpty) { /* ... error handling ... */ return; }
    if (_frameImageFile == null && _frameImagePath == null) { /* ... error handling ... */ return; }

    String finalImagePath = _frameImagePath ?? '';
    if (_frameImageFile != null) {
      finalImagePath = await _dataService.saveImage(_frameImageFile!);
    }

    final Frame frameToSave = Frame(
      id: widget.frame?.id ?? Uuid().v4(),
      name: _nameController.text,
      imagePath: finalImagePath,
      photoX: _windowX,
      photoY: _windowY,
      photoWidth: _windowWidth,
      photoHeight: _windowHeight,
    );

    await _dataService.saveFrame(frameToSave);
    Navigator.of(context).pop(true); // Pop to signal a refresh
  }
  
  Widget _buildFrameImage() {
    if (_frameImageFile != null) {
      return Image.file(_frameImageFile!, key: _imageKey, fit: BoxFit.contain);
    }
    if (_frameImagePath != null) {
      final isAsset = _frameImagePath!.startsWith('assets/');
      return isAsset
        ? Image.asset(_frameImagePath!, key: _imageKey, fit: BoxFit.contain)
        : Image.file(File(_frameImagePath!), key: _imageKey, fit: BoxFit.contain);
    }
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Center(child: Text('Please select a frame image')),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: 0.0,
            max: 1.0,
            divisions: 100, // Makes the slider "snap" to 100 steps
            label: (value * 100).toStringAsFixed(0) + '%', // Show percentage on hover
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: _isEditing ? 'Edit Frame' : 'Add Frame',
        showSaveButton: true,
        onSavePressed: _saveFrame,
        showCartButton: false,
        showHomeButton: false,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- UI for Name and Image Selection ---
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Frame Name'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Select Frame Image'),
              onPressed: _pickFrameImage,
            ),
            SizedBox(height: 16),
            
            // --- Visual Editor Area ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade300),
                // We use LayoutBuilder to get the size of this container
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerWidth = constraints.maxWidth;
                    final containerHeight = constraints.maxHeight;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Layer 1: The frame image
                        _buildFrameImage(),
                        // Layer 2: The interactive window, positioned using our state variables
                        Positioned(
                          left: _windowX * containerWidth,
                          top: _windowY * containerHeight,
                          width: _windowWidth * containerWidth,
                          height: _windowHeight * containerHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            // You could add gesture detectors here for dragging if desired,
                            // but sliders provide more precise control.
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // --- Slider Controls ---
            // These sliders directly manipulate the state variables for the window
            _buildSlider("Width", _windowWidth, (val) => setState(() => _windowWidth = val)),
            _buildSlider("Height", _windowHeight, (val) => setState(() => _windowHeight = val)),
            _buildSlider("Position X", _windowX, (val) => setState(() => _windowX = val)),
            _buildSlider("Position Y", _windowY, (val) => setState(() => _windowY = val)),
          ],
        ),
      ),
    );
  }
}