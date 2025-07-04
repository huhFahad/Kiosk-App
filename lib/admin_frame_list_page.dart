// lib/admin_frame_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
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
      if (didSaveChanges == true) {
        _refreshFrames();
      }
    });
  }

  void _showDeleteConfirmation(Frame frame) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Frame?'),
        content: Text('Are you sure you want to permanently delete the "${frame.name}" frame? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await _dataService.deleteFrame(frame.id);
              _refreshFrames(); // Refresh the list to show the change
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = KioskTheme.scale; 
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 8.0 * scale,
              mainAxisSpacing: 8.0  * scale,
              childAspectRatio: 0.6, 
            ),
            itemCount: frames.length,
            itemBuilder: (context, index) {
              final frame = frames[index];
              // --- EACH ITEM IS A CUSTOM CARD WIDGET ---
              return Card(
                clipBehavior: Clip.antiAlias, 
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- THE PREVIEW ---
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: _buildFrameThumbnail(frame.imagePath),
                      ),
                    ),
                    // --- FRAME NAME ---
                    Padding(
                      padding: EdgeInsets.all(8.0 * scale),
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
                              _showDeleteConfirmation(frame);
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