// lib/photo_upload_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk_app/models/template_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class PhotoUploadPage extends StatefulWidget {
  @override
  _PhotoUploadPageState createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final DataService _dataService = DataService();
  late Future<List<Template>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = _dataService.readTemplates();
  }

  // This page no longer needs didChangeDependencies to get a frame.

  // This method now navigates to the FRAME selection page.
  void _proceedToFrameSelection(File imageFile) {
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/frame_selection',
        arguments: imageFile, // Pass ONLY the selected image file
      );
    }
  }

  // This method is for when the user uploads their own photo.
  Future<void> _pickUserImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      _proceedToFrameSelection(File(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Step 1: Choose an Image'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Select a template...", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            flex: 3,
            child: FutureBuilder<List<Template>>(
              future: _templatesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final templates = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0, childAspectRatio: 0.75),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          // When a template is tapped, pass its file to the next step
                          _proceedToFrameSelection(File(template.imagePath));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey.shade200,
                                // Admin-uploaded templates will always be files
                                child: Image.file(
                                  File(template.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                template.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(thickness: 2, height: 24),
          // --- Button to upload their own ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "...or upload your own photo",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file, size: 30,),
            label: const Text('Upload My Photo', style: TextStyle(fontSize: 28), ),
            onPressed: _pickUserImage,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}