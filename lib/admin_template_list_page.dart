// lib/admin_template_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk_app/models/template_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:uuid/uuid.dart';

class AdminTemplateListPage extends StatefulWidget {
  @override
  _AdminTemplateListPageState createState() => _AdminTemplateListPageState();
}

class _AdminTemplateListPageState extends State<AdminTemplateListPage> {
  final DataService _dataService = DataService();
  late Future<List<Template>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = _dataService.readTemplates();
  }

  void _refresh() => setState(() { _templatesFuture = _dataService.readTemplates(); });

  // --- ADD NEW TEMPLATE LOGIC ---
  Future<void> _addTemplate() async {
    // 1. Pick an image
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    // 2. Ask for a name in a dialog
    final name = await _showNameDialog();
    if (name == null || name.isEmpty || !mounted) return;

    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // 3. Save the image and create the template object
      final savedImagePath = await _dataService.saveImage(File(file.path));
      final newTemplate = Template(
        id: Uuid().v4(),
        name: name,
        imagePath: savedImagePath,
      );
      await _dataService.addTemplate(newTemplate);
    } catch (e) {
      // Handle potential errors
    } finally {
      if (mounted) Navigator.of(context).pop(); // Close loading dialog
      _refresh(); // Refresh the list
    }
  }
  
  // --- DELETE TEMPLATE LOGIC ---
  void _deleteTemplate(Template template) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dataService.deleteTemplate(template.id);
      _refresh();
    }
  }

  // --- HELPER DIALOG FOR GETTING THE NAME ---
  Future<String?> _showNameDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enter Template Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'e.g., Birthday Party Fun'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Manage Templates', showHomeButton: false, showCartButton: false),
      body: FutureBuilder<List<Template>>(
        future: _templatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No templates found. Tap + to add one.'));
          }

          final templates = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade200,
                        // Admin-uploaded templates will always be files, not assets
                        child: Image.file(File(template.imagePath), fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Icon(Icons.error, color: Colors.red)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        template.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade700),
                            onPressed: () => _deleteTemplate(template),
                            tooltip: 'Delete Template',
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
        onPressed: _addTemplate,
        child: const Icon(Icons.add),
        tooltip: 'Add New Template',
      ),
    );
  }
}