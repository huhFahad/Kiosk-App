// lib/photo_upload_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk_app/models/frame_model.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class PhotoUploadPage extends StatefulWidget {
  @override
  _PhotoUploadPageState createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  late Frame _selectedFrame;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedFrame = ModalRoute.of(context)!.settings.arguments as Frame;
  }

  Future<void> _pickAndProceed() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) return;
    
    if (mounted) {
      // Navigate to the editor, passing BOTH the frame and the new photo file.
      Navigator.pushNamed(
        context,
        '/photo_editor',
        arguments: {
          'frame': _selectedFrame,
          'customerImageFile': File(file.path),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Step 2: Add Your Photo'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You've selected the '${_selectedFrame.name}' frame.", style: TextStyle(fontSize: 30)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file, size: 40),
              label: Text('Upload Photo', style: TextStyle(fontSize: 40)),
              onPressed: _pickAndProceed,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}