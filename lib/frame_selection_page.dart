// lib/frame_selection_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/frame_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class FrameSelectionPage extends StatefulWidget {
  @override
  _FrameSelectionPageState createState() => _FrameSelectionPageState();
}

class _FrameSelectionPageState extends State<FrameSelectionPage> {
  final DataService _dataService = DataService();
  late Future<List<Frame>> _framesFuture;
  late File _customerImageFile; // This page now holds the customer's image

  @override
  void initState() {
    super.initState();
    _framesFuture = _dataService.readFrames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // It now receives the image file from the PhotoUploadPage
    _customerImageFile = ModalRoute.of(context)!.settings.arguments as File;
  }

  // This method now proceeds to the final editor page
  void _proceedToEditor(Frame selectedFrame) {
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/photo_editor',
        arguments: {
          'frame': selectedFrame,
          'customerImageFile': _customerImageFile,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Choose Your Frame'),
      body: FutureBuilder<List<Frame>>(
        future: _framesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final frames = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0, childAspectRatio: 0.75),
            itemCount: frames.length,
            itemBuilder: (context, index) {
              final frame = frames[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: InkWell(
                  onTap: () => _proceedToEditor(frame), // Call the new navigation method
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade200,
                          child: _buildFrameThumbnail(frame),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(frame.name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFrameThumbnail(Frame frame) {
    final isAsset = frame.imagePath.startsWith('assets/');
    return isAsset ? Image.asset(frame.imagePath, fit: BoxFit.contain) : Image.file(File(frame.imagePath), fit: BoxFit.contain);
  }
}