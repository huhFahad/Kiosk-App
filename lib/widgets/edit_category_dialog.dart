// lib/widgets/edit_category_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import '../services/data_service.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({Key? key, required this.category}) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _nameController;
  File? _imageFile;
  String? _imagePath;
  final _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _imagePath = widget.category.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _onSave() async {
    String finalImagePath = _imagePath ?? '';
    if (_imageFile != null) {
      // If a new image was picked, copy it to the app's directory
      try {
        finalImagePath = await _dataService.saveImage(_imageFile!);
      } catch (e) {
        // Handle error if needed, maybe show a snackbar
        print("Error saving image: $e");
        return;
      }
    }
    
    // Return the result to the calling page
    Navigator.of(context).pop({
      'oldName': widget.category.name,
      'newName': _nameController.text,
      'newImagePath': finalImagePath,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            Text('Category Name', style: Theme.of(context).textTheme.labelLarge),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter category name',
              ),
            ),
            SizedBox(height: 20),
            // Image picker
            Text('Category Image', style: Theme.of(context).textTheme.labelLarge),
            SizedBox(height: 8),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : (_imagePath != null && _imagePath!.isNotEmpty)
                      ? (_imagePath!.startsWith('assets/')
                          ? Image.asset(_imagePath!, fit: BoxFit.cover)
                          : Image.file(File(_imagePath!), fit: BoxFit.cover))
                      : Center(child: Icon(Icons.image_not_supported)),
            ),
            SizedBox(height: 8),
            TextButton.icon(
              icon: Icon(Icons.image),
              label: Text('Select New Image'),
              onPressed: _pickImage,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: Text('Save'),
        ),
      ],
    );
  }
}