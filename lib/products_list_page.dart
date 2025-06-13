// lib/products_list_page.dart

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'models/product_model.dart';
// import 'models/cart_model.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/quantity_control_widget.dart';
import 'admin_product_list_page.dart'; // For ProductImageView

// An enum to define our sorting options cleanly
enum ProductSortOption { Default, PriceHighToLow, PriceLowToHigh }

class ProductsListPage extends StatefulWidget {
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  // State variables for filters and sorting
  String selectedSubcategory = 'All';
  ProductSortOption _sortOption = ProductSortOption.Default;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String categoryName = arguments['category'];
    final List<Product> allProducts = arguments['products'];

    final productsInMainCategory = allProducts.where((p) => p.category == categoryName).toList();
    final subcategories = ['All', ...productsInMainCategory.map((p) => p.subcategory).toSet().toList()];

    // --- 1. FILTERING LOGIC ---
    final filteredProducts = selectedSubcategory == 'All'
        ? productsInMainCategory
        : productsInMainCategory.where((p) => p.subcategory == selectedSubcategory).toList();

    // --- 2. SORTING LOGIC ---
    // Create a mutable copy to sort
    List<Product> sortedProducts = List.from(filteredProducts);
    switch (_sortOption) {
      case ProductSortOption.PriceHighToLow:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.PriceLowToHigh:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.Default:
        // Do nothing, keep original order
        break;
    }

    return Scaffold(
      appBar: CommonAppBar(title: categoryName),
      body: Column(
        children: [
          // --- Sub-category Filter Bar ---
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            child: SizedBox(
              height: 40.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(subcategory),
                      selected: selectedSubcategory == subcategory,
                      onSelected: (isSelected) {
                        if (isSelected) {
                          setState(() {
                            selectedSubcategory = subcategory;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          // --- NEW: Sort Options Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Sort by:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Price: High-Low'),
                  selected: _sortOption == ProductSortOption.PriceHighToLow,
                  onSelected: (_) => setState(() => _sortOption = ProductSortOption.PriceHighToLow),
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Price: Low-High'),
                  selected: _sortOption == ProductSortOption.PriceLowToHigh,
                  onSelected: (_) => setState(() => _sortOption = ProductSortOption.PriceLowToHigh),
                ),
              ],
            ),
          ),
          Divider(),
          // --- Product List ---
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: sortedProducts.length, // Use the sorted list
              itemBuilder: (context, index) {
                final product = sortedProducts[index]; // Use the sorted list
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: ProductImageView(imagePath: product.image),
                    title: Text(product.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text('₹${product.price.toStringAsFixed(2)} ${product.unit}', style: TextStyle(fontSize: 16)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.map_outlined),
                          tooltip: 'Find on Map',
                          onPressed: () { /* Map navigation */ },
                        ),
SizedBox(width: 8),
                        QuantityControlWidget(product: product),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}