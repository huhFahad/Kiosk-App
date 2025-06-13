// lib/admin_product_list_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'services/data_service.dart';
import 'admin_product_edit_page.dart';
// import 'package:image_picker/image_picker.dart';
import '../widgets/edit_category_dialog.dart';

class AdminProductListPage extends StatefulWidget {
  @override
  _AdminProductListPageState createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  final DataService _dataService = DataService();
  late Future<List<Product>> _productsFuture;

  void _editCategory(BuildContext context, String categoryName) async {
    // First, get the category data to pass to the dialog
    final allCategories = await _dataService.readCategories();
    Category categoryToEdit = allCategories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => Category(name: categoryName, imagePath: ''),
    );

    // Show our new custom dialog and wait for the result
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => EditCategoryDialog(category: categoryToEdit),
    );

    // If the user saved the dialog, result will not be null
    if (result != null) {
      try {
        // Show a loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updating category and products...'))
        );
        
        // Call our new, powerful service method
        await _dataService.updateCategory(
          oldName: result['oldName']!,
          newName: result['newName']!,
          newImagePath: result['newImagePath']!,
        );
        
        // Refresh the entire product list to see the changes
        _refreshProducts();

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating category: $e'), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  // State for Search Functionality ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _dataService.readProducts();

    // Add a listener to the search controller to update the UI on text change
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  // Remember to dispose of the controller!
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
      // Clear search when refreshing
      _searchController.clear();
      _productsFuture = _dataService.readProducts();
    });
  }

  void _navigateAndRefresh(BuildContext context, List<Product> allProducts, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AdminProductEditPage(allProducts: allProducts, product: product),
      ),
    ).then((_) => _refreshProducts());
  }
  
  void _showDeleteDialog(BuildContext context, Product product, List<Product> allProducts) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to permanently delete "${product.name}"?'),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Yes, Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _dataService.deleteProduct(product.id);
                _refreshProducts();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Manage Products'),
          ),
          body: _buildBody(snapshot),
          floatingActionButton: snapshot.hasData
              ? FloatingActionButton(
                  onPressed: () => _navigateAndRefresh(context, snapshot.data!),
                  child: Icon(Icons.add),
                  tooltip: 'Add Product',
                )
              : null,
        );
      },
    );
  }

  // --- THE NEW, ORGANIZED BODY ---
  Widget _buildBody(AsyncSnapshot<List<Product>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No products found. Tap + to add one.'));
    }

    final allProducts = snapshot.data!;

    // --- 1. FILTERING LOGIC ---
    final filteredProducts = allProducts.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // --- 2. GROUPING LOGIC ---
    final Map<String, List<Product>> groupedProducts = {};
    for (var product in filteredProducts) {
      if (groupedProducts[product.category] == null) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }
    // Sort categories alphabetically
    final sortedCategories = groupedProducts.keys.toList()..sort();

    return Column(
      children: [
        // --- THE SEARCH BAR ---
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Products',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        // --- THE EXPANDABLE LIST ---
        Expanded(
          child: ListView.builder(
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              final productsInCategory = groupedProducts[category]!;
              // Sort products within the category alphabetically
              productsInCategory.sort((a, b) => a.name.compareTo(b.name));

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$category (${productsInCategory.length})',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_note, color: Colors.grey.shade700),
                        tooltip: 'Edit Category Image',
                        onPressed: () {
                          _editCategory(context, category);
                        },
                      ),
                    ],
                  ),
                  children: productsInCategory.map((product) {
                    return ListTile(
                      leading: ProductImageView(imagePath: product.image),
                      title: Text(product.name),
                      subtitle: Text('Price: ₹${product.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateAndRefresh(context, allProducts, product: product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(context, product, allProducts),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// You should already have this helper widget from the previous step.
// If not, add it here.
class ProductImageView extends StatelessWidget {
  final String imagePath;
  const ProductImageView({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');
    return SizedBox(
      width: 50,
      height: 50,
      child: isAsset
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Icon(Icons.image_not_supported),
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Icon(Icons.image_not_supported),
            ),
    );
  }
}