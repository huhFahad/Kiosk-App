// lib/categories_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'models/category_model.dart'; // Import Category model
import 'services/data_service.dart';
import '../widgets/common_app_bar.dart'; 

class CategoriesPage extends StatelessWidget {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'All Categories'
        ),
      body: FutureBuilder<Map<String, dynamic>>(
        // Use a Future.wait to load both products and categories at once
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No categories found.'));
          }

          final List<Product> allProducts = snapshot.data!['products'];
          final List<Category> allCategories = snapshot.data!['categories'];
          final categories = allProducts.map((p) => p.category).toSet().toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.9, // Adjust for image
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryName = categories[index];
                final categoryData = allCategories.firstWhere(
                  (c) => c.name == categoryName,
                  orElse: () => Category(name: categoryName, imagePath: ''),
                );

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context, '/products',
                      arguments: {'category': categoryName, 'products': allProducts},
                    );
                  },
                  child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias, // Important for rounded corners on image
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildCategoryImage(categoryData.imagePath),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            categoryName,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper to load both sets of data
  Future<Map<String, dynamic>> _loadData() async {
    final products = await _dataService.readProducts();
    final categories = await _dataService.readCategories();
    return {'products': products, 'categories': categories};
  }

  // Helper to display the image (asset or file)
  Widget _buildCategoryImage(String imagePath) {
    if (imagePath.isEmpty) {
      return Icon(Icons.category, size: 80, color: Colors.grey);
    }
    final isAsset = imagePath.startsWith('assets/');
    return isAsset
        ? Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.error))
        : Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.error));
  }
}