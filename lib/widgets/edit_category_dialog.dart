// lib/widgets/edit_category_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
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
  final scale = KioskTheme.scale;
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
      try {
        finalImagePath = await _dataService.saveImage(_imageFile!);
      } catch (e) {
        print("Error saving image: $e");
        return;
      }
    }

    Navigator.of(context).pop({
      'oldName': widget.category.name,
      'newName': _nameController.text,
      'newImagePath': finalImagePath,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      actionsAlignment: MainAxisAlignment.center,
      title: Text(
        'EDIT CATEGORY', 
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 18 * scale,
          fontWeight: FontWeight.bold,
        ), 
        textAlign: TextAlign.center ,),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center ,
          children: [
            Divider(color: Colors.black,),
            SizedBox(height: 8 * scale),
            Text(
              'Category Name', 
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )
            ),
            SizedBox(height: 8 * scale),
            TextField(
              style: TextStyle(fontSize: 18 * scale),
              controller: _nameController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey,), borderRadius: BorderRadius.circular(15)),
                hintText: 'Enter category name',
                hintStyle: TextStyle(fontSize: 18 * scale,)
              ),
            ),
            SizedBox(height: 20 * scale),
            // Image picker
            Text(
              'Category Image',
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )
            ),
            SizedBox(height: 8 * scale),
            Container(
              height: 150 * scale,
              width: 150 * scale,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : (_imagePath != null && _imagePath!.isNotEmpty)
                    ? (_imagePath!.startsWith('assets/')
                        ? Image.asset(_imagePath!, fit: BoxFit.cover)
                        : Image.file(File(_imagePath!), fit: BoxFit.cover))
                    : Center(child: Icon(Icons.image_not_supported)),
            ),
            SizedBox(height: 8 * scale),
            TextButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor.withAlpha(30)),
              ),
              icon: Icon(Icons.image),
              label: Text(
                'Select New Image',
                style: TextStyle(fontSize: 16 * scale), 
              ),
              onPressed: _pickImage,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(fontSize: 18 * scale), ),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: Text('Save', style: TextStyle(fontSize: 18 * scale), ),
        ),
      ],
    );
  }
}