// lib/admin_product_list_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
import 'models/product_model.dart';
import 'models/category_model.dart';
import 'services/data_service.dart';
import 'admin_product_edit_page.dart';
import 'widgets/common_app_bar.dart';
import '../widgets/edit_category_dialog.dart';

class AdminProductListPage extends StatefulWidget {
  @override
  _AdminProductListPageState createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  final scale = KioskTheme.scale;
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
        title: Text('Rename Sub-category', style: TextStyle(fontSize: 24 * scale),),
        content: TextField(
          style: TextStyle(fontSize: 18 * scale),
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'New sub-category name',
            labelStyle: TextStyle(fontSize: 18 * scale), 
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: TextStyle(fontSize: 18 * scale),)),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(nameController.text), child: Text('Save', style: TextStyle(fontSize: 18 * scale),)),
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
        title: Text('Are you sure?', style: TextStyle(fontSize: 24 * scale ),),
        content: Text(
          'Do you want to permanently delete "${product.name}"?',
          style: TextStyle(fontSize: 18 * scale),
        ),
        actions: [
          TextButton(
            child: Text('No', style: TextStyle(fontSize: 18 * scale),),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              foregroundColor: Colors.white
            ),
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
            child: Text('Delete', style: TextStyle(fontSize: 18 * scale),),
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
            ? FloatingActionButton.large(
                onPressed: () => _navigateAndRefresh(context, snapshot.data!),
                tooltip: 'Add Product',
                child: SizedBox(
                  // width: 200 * scale,
                  // height: 200 * scale,
                  child: Icon(Icons.add),)
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
          padding: EdgeInsets.all(16.0 * scale),
          child: TextField(
            style: TextStyle(fontSize: 18 * scale),
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Products',
              labelStyle: TextStyle(fontSize: 18 * scale),
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
            padding: EdgeInsets.only(bottom: 120.0 * scale),
            itemCount: sortedCategories.length,
            itemBuilder: (context, categoryIndex) {
              final categoryName = sortedCategories[categoryIndex];
              final subCategoryMap = groupedProducts[categoryName]!;
              final sortedSubCategories = subCategoryMap.keys.toList()..sort();
              final int totalProductsInCategory = subCategoryMap.values.fold(0, (sum, productList) => sum + productList.length);

              // --- OUTER EXPANSION TILE (FOR CATEGORY) ---
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0 * scale, vertical: 4.0 * scale,),
                elevation: 4,
                child: ExpansionTile(
                  key: Key('$categoryName$_searchQuery'), 
                  initiallyExpanded: _searchQuery.isNotEmpty,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$categoryName ($totalProductsInCategory)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23 * scale),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_note, size: 25 * scale, color: Colors.grey.shade700),
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
                      padding: EdgeInsets.only(left: 16.0 * scale, right: 16.0 * scale, bottom: 4.0 * scale),
                      child: ExpansionTile(
                        key: Key('$categoryName$subCategoryName$_searchQuery'),
                        initiallyExpanded: _searchQuery.isNotEmpty,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$subCategoryName (${productsInSubCategory.length})',
                              style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.grey.shade600, size: 20 * scale),
                              tooltip: 'Rename Sub-category',
                              onPressed: () => _editSubCategory(context, categoryName, subCategoryName),
                            ),
                          ],
                        ),
                        children: productsInSubCategory.map((product) {
                          return ListTile(
                            leading: ProductImageView(imagePath: product.image),
                            title: Text(product.name,
                              style: TextStyle(fontSize: 18 * scale , fontWeight: FontWeight.w500),
                              ),
                            subtitle: 
                              Text(
                                'Price: ₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w500),
                              ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue, size: 23 * scale,),
                                  onPressed: () => _navigateAndRefresh(context, allProducts, product: product),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 23 * scale,),
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
    final scale = KioskTheme.scale;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0 * scale),   
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