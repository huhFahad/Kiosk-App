// lib/admin_product_edit_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
import 'models/product_model.dart';
import 'services/data_service.dart';
import 'widgets/common_app_bar.dart';
import 'admin_map_picker_page.dart';

class AdminProductEditPage extends StatefulWidget {
  final Product? product;
  final List<Product> allProducts;

  AdminProductEditPage({required this.allProducts, this.product});

  @override
  _AdminProductEditPageState createState() => _AdminProductEditPageState();
}

class _AdminProductEditPageState extends State<AdminProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _dataService = DataService();
  final scale = KioskTheme.scale;
  
  // Form field values
  String? _id;
  String? _name;
  String? _category;
  String? _subcategory;
  double? _price;
  String? _unit;
  String? _imagePath;
  double? _mapX;
  double? _mapY;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  List<String> _existingCategories = [];
  List<String> _existingSubcategories = [];
  List<String> _existingUnits = [];

  bool get _isEditing => widget.product != null;

  static const String _addNewValue = '++ADD_NEW++';

  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();

     _tagsController = TextEditingController(text: widget.product?.tags.join(', ') ?? '');

    if (_isEditing) {
      _id = widget.product!.id;
      _name = widget.product!.name;
      _category = widget.product!.category;
      _subcategory = widget.product!.subcategory;
      _price = widget.product!.price;
      _unit = widget.product!.unit;
      _imagePath = widget.product!.image;
      _mapX = widget.product!.mapX;
      _mapY = widget.product!.mapY;
      }

    _existingCategories = widget.allProducts.map((p) => p.category).toSet().toList();
    // _existingSubcategories = widget.allProducts.map((p) => p.subcategory).toSet().toList();
    _existingUnits = widget.allProducts.map((p) => p.unit).where((u) => u.isNotEmpty).toSet().toList();
    
    if (_category != null) {
      _existingSubcategories = widget.allProducts
          .where((p) => p.category == _category)
          .map((p) => p.subcategory)
          .toSet()
          .toList();
    }

    if (_isEditing) {
      if (!_existingCategories.contains(_category)) {
        _existingCategories.add(_category!);
      }
      if (!_existingSubcategories.contains(_subcategory)) {
        _existingSubcategories.add(_subcategory!);
      }
      if (_unit != null && !_existingUnits.contains(_unit)) {
        _existingUnits.add(_unit!);
      }
    }
  }

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

   void _openMapPicker() async {
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(builder: (ctx) => const AdminMapPickerPage()),
    );

    if (result != null && result.containsKey('x') && result.containsKey('y')) {
      setState(() {
        _mapX = result['x'];
        _mapY = result['y'];
      });
    }
  }

  void _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    
    _formKey.currentState?.save();

    final List<String> tags = _tagsController.text
      .split(',') 
      .map((tag) => tag.trim()) 
      .where((tag) => tag.isNotEmpty)
      .toList();
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saving...')));

    String finalImagePath = _imagePath ?? 'assets/images/placeholder.jpeg';

    if (_imageFile != null) {
      try {
        finalImagePath = await _dataService.saveImage(_imageFile!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving image: $e'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }

    final productToSave = Product(
      id: _id ?? '',
      name: _name!,
      category: _category!,
      subcategory: _subcategory!,
      price: _price!,
      unit: _unit ?? '',
      image: finalImagePath,
      mapX: _mapX ?? -1.0,
      mapY: _mapY ?? -1.0,
      tags: tags,
    );

    try {
      await _dataService.saveProduct(productToSave);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }



  Widget _buildNameField() {
    return TextFormField(
      initialValue: _name,
      decoration: InputDecoration(labelText: 'Product Name', enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey,), borderRadius: BorderRadius.circular(15)),),
      validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
      onSaved: (value) => _name = value,
    );
  }

  Widget _buildDropdown(
    String label,
    String? currentValue,
    List<String> items,
    Function(String?) onSaved,
    Function(String?) onChanged,
  ) {

    final dropdownItems = List<String>.from(items)..add(_addNewValue);

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(labelText: label, enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey,), borderRadius: BorderRadius.circular(15)),),
      items: dropdownItems.map((item) {
        if (item == _addNewValue) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              'Add New...',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          );
        }
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (value) {
        if (value == _addNewValue) {
          _showAddNewDialog(label).then((newValue) {
            if (newValue != null && newValue.isNotEmpty) {
              setState(() {
                if (label == 'Category') {
                  _existingCategories.add(newValue);
                } else if (label == 'Sub-category') {
                  _existingSubcategories.add(newValue);
                } else if (label == 'Unit') {
                  _existingUnits.add(newValue);
                }
                onChanged(newValue);
              });
            }
          });
        } else {
          onChanged(value);
        }
      },
      onSaved: onSaved,
      validator: (value) {
        if (label != 'Unit' && (value == null || value.isEmpty)) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }
  
  Future<String?> _showAddNewDialog(String label) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New $label'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter new $label name', enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey,), borderRadius: BorderRadius.circular(15)),),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      initialValue: _price?.toString(),
      decoration: InputDecoration(labelText: 'Price', enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey,), borderRadius: BorderRadius.circular(15)),),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) => (value!.isEmpty || double.tryParse(value) == null) ? 'Please enter a valid price' : null,
      onSaved: (value) => _price = double.tryParse(value!),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Image', style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 8 * scale),
        Container(
          height: 150 * scale,
          width: 150 * scale,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: _buildImagePreview(),
        ),
        SizedBox(height: 8 * scale),
        TextButton.icon(
          icon: Icon(Icons.image),
          label: Text('Select Image'),
          onPressed: () async {
            final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setState(() {
                _imageFile = File(pickedFile.path);
              });
            }
          },
        ),
        if (_isEditing && _imagePath != null)
          Text('Current Path: $_imagePath', style: TextStyle(fontSize: 12 * scale, color: Colors.grey)),
      ],
    );
  }

  Widget _buildImagePreview() {
    // Priority 1: A new file has been picked by the user.
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity);
    }
    
    // Priority 2: An existing path is available.
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      // Check if it's an asset or a file path.
      final isAsset = _imagePath!.startsWith('assets/');
      if (isAsset) {
        return Image.asset(
          _imagePath!, 
          fit: BoxFit.cover, 
          width: double.infinity,
          errorBuilder: (ctx, err, st) => Icon(Icons.error, color: Colors.red)
        );
      } else {
        // It's a file path from our documents directory.
        return Image.file(
          File(_imagePath!), 
          fit: BoxFit.cover, 
          width: double.infinity,
          errorBuilder: (ctx, err, st) => Icon(Icons.error, color: Colors.red)
        );
      }
    }
    
    // Priority 3: No image available.
    return Center(child: Text('No Image'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context, 
        title: _isEditing ? 'Edit Product' : 'Add Product',
        showCartButton: false,
        showHomeButton: false,
        showSaveButton: true,
        onSavePressed: _saveForm,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0 * scale),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12 * scale),
                _buildNameField(),
                SizedBox(height: 12 * scale),
                _buildDropdown(
                  'Category',
                  _category,
                  _existingCategories,
                  (value) => _category = value,
                  (value) { // This is the onChanged callback
                    setState(() {
                      _category = value;
                      // 1. When the category changes, reset the sub-category
                      _subcategory = null; 
                      // 2. Update the list of available sub-categories
                      _existingSubcategories = widget.allProducts
                          .where((p) => p.category == value)
                          .map((p) => p.subcategory)
                          .toSet()
                          .toList();
                    });
                  },
                ),
                SizedBox(height: 12 * scale),
                _buildDropdown(
                  'Sub-category',
                  _subcategory,
                  _existingSubcategories,
                  (value) => _subcategory = value,
                  (value) => setState(() => _subcategory = value),
                ),
                SizedBox(height: 12 * scale),
                _buildPriceField(),
                SizedBox(height: 12 * scale),
                _buildDropdown('Unit', _unit, _existingUnits, (value) => _unit = value, (value) => setState(() => _unit = value)),
                SizedBox(height: 24 * scale),
                _buildImagePicker(),
                SizedBox(height: 24 * scale),
                Text('Product Location on Map', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8 * scale),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.map),
                      label: Text('Set Location'),
                      onPressed: _openMapPicker,
                    ),
                    SizedBox(width: 16 * scale),
                    // Display the current coordinates
                    if (_mapX != null && _mapY != null)
                      Text(
                        'X: ${(_mapX! * 100).toStringAsFixed(1)}%, Y: ${(_mapY! * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else
                      const Text('No location set.', style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),                
                SizedBox(height: 20 * scale),
                Divider(),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey,), borderRadius: BorderRadius.circular(15)),
                    labelText: 'Search Tags',
                    hintText: 'e.g., morning, breakfast, healthy, snack',
                    helperText: 'Enter tags separated by commas',
                  ),
                ),
                SizedBox(height: 20 * scale),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50 * scale), foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),  
                  child: Padding(padding: EdgeInsets.symmetric(vertical: 16.0 * scale), child: Text('Save Product', style: TextStyle(fontSize: 20 * scale),)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}