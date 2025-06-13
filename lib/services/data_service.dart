// lib/services/data_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class DataService {
  static const _uuid = Uuid();

  // --- File Path Helpers ---

  Future<String> saveImage(File imageFile) async {
    // Get the path to the app's documents directory
    final appDir = await getApplicationDocumentsDirectory();
    
    // Create an 'images' subdirectory if it doesn't exist
    final imagesDir = Directory(p.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Get the original filename
    final fileName = p.basename(imageFile.path);
    
    // Create the destination path in our new 'images' directory
    final newPath = p.join(imagesDir.path, fileName);
    
    // Copy the file from the original location to the new location
    final savedImageFile = await imageFile.copy(newPath);

    // Return the new, permanent path to be saved in products.json
    return savedImageFile.path;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/products.json');
  }

  // --- Core Read Method ---
  Future<List<Product>> readProducts() async {
    try {
      final file = await _localFile;
      
      // If a local (editable) file exists, read from it.
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error reading from local file: $e");
      // If there's an error, we can try to recover by using the asset file.
    }

    // If local file doesn't exist or fails, fall back to the initial asset file.
    try {
      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print("Error reading from asset file: $e");
      return []; // Return empty list as a last resort.
    }
  }

  // --- Core Write Method ---
  Future<File> writeProducts(List<Product> products) async {
    final file = await _localFile;
    final jsonList = products.map((p) => p.toJson()).toList();
    return file.writeAsString(jsonEncode(jsonList));
  }

  // --- High-Level Save/Delete Methods ---

  Future<void> saveProduct(Product productToSave) async {
    final allProducts = await readProducts();
    
    // Check if it's a new product or an update to an existing one.
    final int index = allProducts.indexWhere((p) => p.id == productToSave.id);

    if (index >= 0) {
      // It's an existing product, so we replace it in the list.
      allProducts[index] = productToSave;
    } else {
      // It's a new product. We need to assign it a unique ID.
      // We will create a new product object with the generated ID.
      final newProductWithId = Product(
        id: _uuid.v4(), // Generate a unique ID
        name: productToSave.name,
        category: productToSave.category,
        subcategory: productToSave.subcategory,
        price: productToSave.price,
        unit: productToSave.unit,
        image: productToSave.image,
        mapX: productToSave.mapX,
        mapY: productToSave.mapY,
      );
      allProducts.add(newProductWithId);
    }

    // Write the entire updated list back to the file.
    await writeProducts(allProducts);
  }

  Future<void> deleteProduct(String productId) async {
    final allProducts = await readProducts();
    allProducts.removeWhere((p) => p.id == productId);
    await writeProducts(allProducts);
  }

  Future<File> get _localCategoriesFile async {
    final path = await _localPath;
    return File('$path/categories.json');
  }

  Future<List<Category>> readCategories() async {
    try {
      final file = await _localCategoriesFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((e) => Category.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error reading categories from local file: $e");
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print("Error reading categories from asset file: $e");
      return [];
    }
  }

  Future<void> saveCategories(List<Category> categories) async {
    final file = await _localCategoriesFile;
    final jsonList = categories.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> updateCategory({
    required String oldName,
    required String newName,
    required String newImagePath,
  }) async {
    final allCategories = await readCategories();
    int categoryIndex = allCategories.indexWhere((c) => c.name == oldName);

    if (categoryIndex != -1) {
      allCategories[categoryIndex] = allCategories[categoryIndex].copyWith(
        name: newName,
        imagePath: newImagePath,
      );
    } else {
      // This case handles creating a new category entry.
      allCategories.add(Category(name: newName, imagePath: newImagePath));
    }
    
    await saveCategories(allCategories);
    
    if (oldName != newName) {
      final allProducts = await readProducts();
      
      // Create a new list of updated products.
      final updatedProducts = allProducts.map((product) {
        if (product.category == oldName) {
          // If the category matches, return a new Product instance
          // with the category updated.
          return product.copyWith(category: newName);
        } else {
          // Otherwise, return the original, unchanged product.
          return product;
        }
      }).toList();
      
      // Save the new list of products.
      await writeProducts(updatedProducts);
    }
  }

}