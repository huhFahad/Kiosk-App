// lib/search_results_page.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/product_model.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:kiosk_app/widgets/product_list_item.dart';
import 'package:kiosk_app/widgets/proceed_to_cart_widget.dart';

class SearchResultsPage extends StatefulWidget {
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // --- STATE VARIABLES ---
  final _searchController = TextEditingController();
  String _currentSearchQuery = '';
  late List<Product> _allProducts; // To hold the initial full list
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This check ensures we only initialize from the arguments once.
    if (!_isInitialized) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      // Set the initial search query from the home page
      _currentSearchQuery = arguments['query'];
      _allProducts = arguments['products'];
      _searchController.text = _currentSearchQuery;
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to update the search results in real-time as the user types
    _searchController.addListener(() {
      setState(() {
        _currentSearchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- FILTERING LOGIC ---
    // The filtering logic now uses the state variable `_currentSearchQuery`
    final String query = _currentSearchQuery.toLowerCase();
    final List<Product> searchResults = _currentSearchQuery.isEmpty
        ? [] // Show nothing if the search bar is empty
        : _allProducts.where((product) {
            final nameMatch = product.name.toLowerCase().contains(query);
            final categoryMatch = product.category.toLowerCase().contains(query);
            final subcategoryMatch = product.subcategory.toLowerCase().contains(query);
            final tagsMatch = product.tags.any((tag) => tag.toLowerCase().contains(query));
            return nameMatch || categoryMatch || subcategoryMatch || tagsMatch;
          }).toList();
    
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Search Results'),
      body: Stack(
        children: [
          Column(
            children: [
              // --- THE NEW SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: false, // Don't autofocus on page load
                  decoration: InputDecoration(
                    hintText: 'Search any products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),

              // --- RESULTS AREA ---
              Expanded(
                child: searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _currentSearchQuery.isEmpty
                              ? 'Please enter a search term above.'
                              : 'No products found matching "$_currentSearchQuery".',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final product = searchResults[index];
                          return ProductListItem(product: product);
                        },
                      ),
              ),
            ],
          ),
          
          // The floating cart widget
          const ProceedToCartWidget(),
        ],
      ),
    );
  }
}