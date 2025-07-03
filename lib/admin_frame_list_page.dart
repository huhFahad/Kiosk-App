// lib/admin_frame_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/common_app_bar.dart'; 
import 'models/frame_model.dart';
import 'services/data_service.dart';
import 'admin_frame_edit_page.dart';

class AdminFrameListPage extends StatefulWidget {
  @override
  _AdminFrameListPageState createState() => _AdminFrameListPageState();
}

class _AdminFrameListPageState extends State<AdminFrameListPage> {
  final DataService _dataService = DataService();
  late Future<List<Frame>> _framesFuture;

  @override
  void initState() {
    super.initState();
    _framesFuture = _dataService.readFrames();
  }

  void _refreshFrames() {
    setState(() {
      _framesFuture = _dataService.readFrames();
    });
  }

  void _navigateAndRefresh({Frame? frame}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AdminFrameEditPage(frame: frame),
      ),
    ).then((didSaveChanges) {
      // If the edit page pops with 'true', it means we should refresh.
      if (didSaveChanges == true) {
        _refreshFrames();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context, 
        title: 'Manage Photo Frames', 
        showCartButton: false,
        showHomeButton: false,
      ),  
      body: FutureBuilder<List<Frame>>(
        future: _framesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No frames found. Tap + to add one.'));
          }

          final frames = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 frames per row
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.6, // Adjust to make cards taller or shorter
            ),
            itemCount: frames.length,
            itemBuilder: (context, index) {
              final frame = frames[index];
              // --- EACH ITEM IS A CUSTOM CARD WIDGET ---
              return Card(
                clipBehavior: Clip.antiAlias, // Ensures the image respects the card's rounded corners
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- THE PREVIEW ---
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade200, // A background for the transparent parts
                        child: _buildFrameThumbnail(frame.imagePath),
                      ),
                    ),
                    // --- FRAME NAME ---
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        frame.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // --- ACTION BUTTONS ---
                    Container(
                      color: Colors.black.withOpacity(0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue.shade700),
                            onPressed: () {
                              _navigateAndRefresh(frame: frame);
                              // print('Editing ${frame.name}');
                            },
                            tooltip: 'Edit Frame',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade700),
                            onPressed: () {
                              // TODO: Implement delete with confirmation
                              print('Deleting ${frame.name}');
                            },
                            tooltip: 'Delete Frame',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateAndRefresh();
          print('Adding new frame');
        },
        child: Icon(Icons.add_photo_alternate_outlined),
        tooltip: 'Add Frame',
      ),
    );
  }

  Widget _buildFrameThumbnail(String imagePath) {
    final isAsset = imagePath.startsWith('assets/');
    return isAsset
      ? Image.asset(
          imagePath,
          fit: BoxFit.contain, // Use contain to see the whole frame
          errorBuilder: (c,e,s) => Icon(Icons.error, color: Colors.red))
      : Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (c,e,s) => Icon(Icons.error, color: Colors.red));
  }

}