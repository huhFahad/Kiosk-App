// lib/products_list_page.dart

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'models/product_model.dart';
// import 'models/cart_model.dart';
import 'widgets/common_app_bar.dart';
// import 'widgets/quantity_control_widget.dart';
// import 'admin_product_list_page.dart'; // For ProductImageView
import 'widgets/product_list_item.dart';
import 'widgets/proceed_to_cart_widget.dart';

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
    
    final double defaultFontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 24.0;

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
      appBar: CommonAppBar(context: context, title: categoryName,),
      body: Stack(
        children: [
          Column(
            children: [
              // --- Sub-category Filter Bar ---
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                child: SizedBox(
                  // height: 40.0,
                  height: defaultFontSize * 2.5,
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
                    return ProductListItem(product: product);
                  },
                ),
              ),
            
            ],
          ),
          const ProceedToCartWidget(),
        ],
      )
    );
  }
}