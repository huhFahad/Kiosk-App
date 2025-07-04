// lib/services/data_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/frame_model.dart';
import '../models/template_model.dart';
import '../models/order_model.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class DataService {
  static const _uuid = Uuid();
  static const _adminPinKey = 'admin_pin';
  static const _themeColorKey = 'theme_primary_color'; 
  static const _timeoutKey = 'inactivity_timeout_seconds';
  static const _screensaverImagePathKey = 'screensaver_image_path';
  static const _screensaverEnabledKey = 'screensaver_enabled';
  static const _storeMapPathKey = 'store_map_image_path';
  static const _kioskLocationXKey = 'kiosk_location_x';
  static const _kioskLocationYKey = 'kiosk_location_y';
  static const _printerNameKey = 'printer_name';

  final _secureStorage = const FlutterSecureStorage();

  // --- INACTIVITY & SCREENSAVER SETTINGS ---

  Future<void> saveTimeoutDuration(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, seconds);
  }

  Future<int> getTimeoutDuration() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 90 seconds if nothing is set
    return prefs.getInt(_timeoutKey) ?? 90;
  }

  Future<void> saveScreensaverImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_screensaverImagePathKey, path);
  }

  Future<String?> getScreensaverImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_screensaverImagePathKey);
  }

   Future<void> saveScreensaverEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_screensaverEnabledKey, isEnabled);
  }

  Future<bool> getScreensaverEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 'true' (enabled) if the setting has never been touched.
    return prefs.getBool(_screensaverEnabledKey) ?? true;
  }
  
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
    // final int index = allProducts.indexWhere((p) => p.id == productToSave.id);
    final int index = productToSave.id.isEmpty 
      ? -1 
      : allProducts.indexWhere((p) => p.id == productToSave.id);

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
      allCategories.add(Category(name: newName, imagePath: newImagePath));
    }
    
    await saveCategories(allCategories);
    
    if (oldName != newName) {
      final allProducts = await readProducts();
      
      final updatedProducts = allProducts.map((product) {
        if (product.category == oldName) {
          return product.copyWith(category: newName);
        } else {
          return product;
        }
      }).toList();
      
      await writeProducts(updatedProducts);
    }
  }

  Future<void> updateSubCategory({
    required String categoryName, 
    required String oldSubCategoryName,
    required String newSubCategoryName,
    }) async {
    if (oldSubCategoryName == newSubCategoryName) return;

    final allProducts = await readProducts();

    final updatedProducts = allProducts.map((product) {
      if (product.category == categoryName && product.subcategory == oldSubCategoryName) {
        return product.copyWith(subcategory: newSubCategoryName);
      } else {
        return product;
      }
    }).toList();

    await writeProducts(updatedProducts);
  }

  // --- FRAME DATA HANDLING ---

  Future<void> deleteFrame(String frameId) async {
    final allFrames = await readFrames();
    final frameToDelete = allFrames.firstWhere((f) => f.id == frameId, orElse: () => Frame(id: '', name: '', imagePath: ''));
    if (frameToDelete.imagePath.isNotEmpty && !frameToDelete.imagePath.startsWith('assets/')) {
      try {
        final imageFile = File(frameToDelete.imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          print('Deleted frame image file: ${frameToDelete.imagePath}');
        }
      } catch (e) {
        print('Error deleting frame image file: $e');
      }
    }

    allFrames.removeWhere((f) => f.id == frameId);
    await saveFrames(allFrames);
  }

  Future<File> get _localFramesFile async {
    final path = await _localPath;
    return File('$path/frames.json');
  }

  Future<List<Frame>> readFrames() async {
    try {
      final file = await _localFramesFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((e) => Frame.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error reading frames from local file: $e");
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/frames.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Frame.fromJson(e)).toList();
    } catch (e) {
      print("Error reading frames from asset file: $e");
      return [];
    }
  }

  Future<void> saveFrames(List<Frame> frames) async {
    final file = await _localFramesFile;
    final jsonList = frames.map((f) => f.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> saveFrame(Frame frameToSave) async {
    final allFrames = await readFrames();
    final index = allFrames.indexWhere((f) => f.id == frameToSave.id);

    if (index >= 0) {
      // Update existing
      allFrames[index] = frameToSave;
    } else {
      // Add new
      allFrames.add(frameToSave);
    }
    await saveFrames(allFrames);
  }

  // --- TEMPLATE DATA HANDLING ---

  Future<File> get _localTemplatesFile async {
    final path = await _localPath;
    return File('$path/templates.json');
  }

  Future<List<Template>> readTemplates() async {
    try {
      final file = await _localTemplatesFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return (jsonDecode(contents) as List).map((e) => Template.fromJson(e)).toList();
      }
    } catch (e) { /* ... */ }
    try {
      final jsonString = await rootBundle.loadString('assets/data/templates.json');
      return (jsonDecode(jsonString) as List).map((e) => Template.fromJson(e)).toList();
    } catch (e) { /* ... */ }
    return [];
  }

  Future<void> saveTemplates(List<Template> templates) async {
    final file = await _localTemplatesFile;
    await file.writeAsString(jsonEncode(templates.map((t) => t.toJson()).toList()));
  }

  Future<void> addTemplate(Template template) async {
    final templates = await readTemplates();
    templates.add(template);
    await saveTemplates(templates);
  }

  Future<void> deleteTemplate(String templateId) async {
    final templates = await readTemplates();
    templates.removeWhere((t) => t.id == templateId);
    await saveTemplates(templates);
  }

  // --- ORDER DATA HANDLING ---

  Future<File> get _localOrdersFile async {
    final path = await _localPath;
    return File('$path/orders.json');
  }

  Future<List<Order>> readOrders() async {
    try {
      final file = await _localOrdersFile;
      if (!await file.exists()) {
        return []; // No orders saved yet
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      print("Error reading orders: $e");
      return [];
    }
  }

  Future<void> saveOrder(Order newOrder) async {
    final allOrders = await readOrders();
    allOrders.insert(0, newOrder); // Insert new orders at the top of the list
    final file = await _localOrdersFile;
    await file.writeAsString(jsonEncode(allOrders.map((o) => o.toJson()).toList()));
  }

  // ----- Admin Pin ----

  Future<String> getAdminPin() async {
    return await _secureStorage.read(key: _adminPinKey) ?? '1234';
  }

  Future<void> saveAdminPin(String newPin) async {
    await _secureStorage.write(key: _adminPinKey, value: newPin);
  }

  // ----- Theme Colors ------

  Future<int> getThemeColorValue() async {
    final prefs = await SharedPreferences.getInstance();
    // Read the color value. If it's null (never set), return green's value.
    // 0xFF4CAF50 is the hex value for Colors.green
    return prefs.getInt(_themeColorKey) ?? 0xFF4CAF50;
  }

  Future<void> saveThemeColorValue(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, colorValue);
  }

  // --- STORE MAP SETTINGS ---

  Future<void> saveStoreMapPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeMapPathKey, path);
  }

  Future<String?> getStoreMapPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeMapPathKey);
  }

  Future<void> removeStoreMapPath() async {
    final prefs = await SharedPreferences.getInstance();
    // The .remove() method deletes the key from storage.
    await prefs.remove(_storeMapPathKey);
  }

  // --- KIOSK LOCATION SETTINGS ---

  Future<void> saveKioskLocation(double x, double y) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kioskLocationXKey, x);
    await prefs.setDouble(_kioskLocationYKey, y);
  }

  Future<Offset?> getKioskLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_kioskLocationXKey);
    final y = prefs.getDouble(_kioskLocationYKey);

    // Only return an Offset if both X and Y have been saved
    if (x != null && y != null) {
      return Offset(x, y);
    }
    return null;
  }

  // --- MAINTENANCE METHODS ---

  Future<void> clearCache() async {
    // We get the local files we want to delete
    final productsFile = await _localFile; // Already defined for products
    final categoriesFile = await _localCategoriesFile;
    final framesFile = await _localFramesFile;
    final templatesFile = await _localTemplatesFile;
    final ordersFile = await _localOrdersFile;

    // We can add any other files here in the future
    final filesToDelete = [
      productsFile,
      categoriesFile,
      framesFile,
      templatesFile,
      ordersFile,
    ];

    print("Clearing local cache...");
    for (final file in filesToDelete) {
      try {
        if (await file.exists()) {
          await file.delete();
          print("Deleted: ${file.path}");
        }
      } catch (e) {
        print("Error deleting file ${file.path}: $e");
      }
    }
  }

  // --- WIFI PASSWORD HANDLING ---

  // We create a unique key for each SSID
  String _getWifiPasswordKey(String ssid) => 'wifi_password_$ssid';

  Future<void> saveWifiPassword(String ssid, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Save the password with a key specific to the network's name
    await prefs.setString(_getWifiPasswordKey(ssid), password);
  }

  Future<String?> getWifiPassword(String ssid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_getWifiPasswordKey(ssid));
  }

  Future<void> forgetWifiPassword(String ssid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getWifiPasswordKey(ssid));
  }

  // --- PRINTER SETTINGS ---

  Future<void> savePrinterName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerNameKey, name);
  }

  Future<String?> getPrinterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printerNameKey);
  }

}