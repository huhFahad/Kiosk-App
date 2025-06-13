// lib/search_results_page.dart

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'models/product_model.dart';
// import 'models/cart_model.dart';
import 'admin_product_list_page.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/quantity_control_widget.dart';
import 'widgets/product_list_item.dart';

class SearchResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // --- STEP 1: Get arguments from the route FIRST ---
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String searchQuery = arguments['query'];
    final List<Product> allProducts = arguments['products'];

    // --- STEP 2: NOW, perform the filtering and search logic ---
    final String query = searchQuery.toLowerCase(); // Search query in lowercase once
    
    final List<Product> searchResults = allProducts.where((product) {
      // Check against name, category, and subcategory
      final nameMatch = product.name.toLowerCase().contains(query);
      final categoryMatch = product.category.toLowerCase().contains(query);
      final subcategoryMatch = product.subcategory.toLowerCase().contains(query);
      final tagsMatch = product.tags.any((tag) => tag.toLowerCase().contains(query));

      // Return true if any of the matches are found
      return nameMatch || categoryMatch || subcategoryMatch || tagsMatch; // <-- Make sure tagsMatch is used here
    }).toList();

    // --- STEP 3: Build the UI with the results ---
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Search Results for "$searchQuery"'),
      body: searchResults.isEmpty
          ? Center(
              child: Text(
                'No products found matching your search.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final product = searchResults[index];
                return ProductListItem(product: product);
              },
            ),
    );
  }
}