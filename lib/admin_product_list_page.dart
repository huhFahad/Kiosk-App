// lib/admin_product_list_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'services/data_service.dart';
import 'admin_product_edit_page.dart';
import 'widgets/common_app_bar.dart';
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
    final allCategories = await _dataService.readCategories();
    Category categoryToEdit = allCategories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => Category(name: categoryName, imagePath: ''),
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => EditCategoryDialog(category: categoryToEdit),
    );

    if (result != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updating category and products...'))
        );
        
        await _dataService.updateCategory(
          oldName: result['oldName']!,
          newName: result['newName']!,
          newImagePath: result['newImagePath']!,
        );
        
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

  void _editSubCategory(BuildContext context, String categoryName, String oldSubCategoryName) async {
    final nameController = TextEditingController(text: oldSubCategoryName);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rename Sub-category'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(labelText: 'New sub-category name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(nameController.text), child: Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != oldSubCategoryName) {
      try {
        await _dataService.updateSubCategory(
          categoryName: categoryName,
          oldSubCategoryName: oldSubCategoryName,
          newSubCategoryName: newName,
        );
        _refreshProducts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating sub-category: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productsFuture = _dataService.readProducts();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
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
          appBar: CommonAppBar(
            context: context, 
            title: 'Manage Products',
            showCartButton: false,
            showHomeButton: false,
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

    // --- FILTERING LOGIC ---
    final filteredProducts = allProducts.where((product) {
      final nameMatch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final subcategoryMatch = product.subcategory.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || subcategoryMatch;
    }).toList();

    // --- NESTED GROUPING LOGIC ---
    final Map<String, Map<String, List<Product>>> groupedProducts = {};
    for (var product in filteredProducts) {
      // Ensure the outer category map exists
      if (groupedProducts[product.category] == null) {
        groupedProducts[product.category] = {};
      }
      // Ensure the inner sub-category list exists
      if (groupedProducts[product.category]![product.subcategory] == null) {
        groupedProducts[product.category]![product.subcategory] = [];
      }
      // Add the product to the correct nested list
      groupedProducts[product.category]![product.subcategory]!.add(product);
    }
    
    final sortedCategories = groupedProducts.keys.toList()..sort();

    return Column(
      children: [
        // --- THE SEARCH BAR ---
        Padding(
          padding: const EdgeInsets.all(16.0),
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
                borderRadius: BorderRadius.circular(60.0),
              ),
            ),
          ),
        ),
                
        // --- NESTED EXPANDABLE LIST ---
        Expanded(
          child: ListView.builder(
            itemCount: sortedCategories.length,
            itemBuilder: (context, categoryIndex) {
              final categoryName = sortedCategories[categoryIndex];
              final subCategoryMap = groupedProducts[categoryName]!;
              final sortedSubCategories = subCategoryMap.keys.toList()..sort();
              final int totalProductsInCategory = subCategoryMap.values.fold(0, (sum, productList) => sum + productList.length);

              // --- OUTER EXPANSION TILE (FOR CATEGORY) ---
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                elevation: 4,
                child: ExpansionTile(
                  key: Key('$categoryName$_searchQuery'), 
                  initiallyExpanded: _searchQuery.isNotEmpty,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$categoryName ($totalProductsInCategory)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_note, color: Colors.grey.shade700),
                        tooltip: 'Edit Category',
                        onPressed: () => _editCategory(context, categoryName),
                      ),
                    ],
                  ),
                  children: sortedSubCategories.map((subCategoryName) {
                    final productsInSubCategory = subCategoryMap[subCategoryName]!;
                    productsInSubCategory.sort((a,b) => a.name.compareTo(b.name));

                    // --- INNER EXPANSION TILE (FOR SUB-CATEGORY) ---
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                      child: ExpansionTile(
                        key: Key('$categoryName$subCategoryName$_searchQuery'),
                        initiallyExpanded: _searchQuery.isNotEmpty,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$subCategoryName (${productsInSubCategory.length})',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.grey.shade600, size: 20),
                              tooltip: 'Rename Sub-category',
                              onPressed: () => _editSubCategory(context, categoryName, subCategoryName),
                            ),
                          ],
                        ),
                        children: productsInSubCategory.map((product) {
                          return ListTile(
                            leading: ProductImageView(imagePath: product.image),
                            title: Text(product.name,
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                            subtitle: 
                              Text(
                                'Price: ₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
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


class ProductImageView extends StatelessWidget {
  final String imagePath;

  final double width;
  final double height;

  const ProductImageView({
    Key? key, required this.imagePath,
    this.width = 60, 
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),   
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
      )
    );
  }
}