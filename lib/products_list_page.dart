// lib/products_list_page.dart

import 'package:flutter/material.dart';
import 'theme/kiosk_theme.dart';
import 'models/product_model.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/product_list_item.dart';
import 'widgets/proceed_to_cart_widget.dart';

enum ProductSortOption { Default, PriceHighToLow, PriceLowToHigh }

class ProductsListPage extends StatefulWidget {
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  String selectedSubcategory = 'All';
  ProductSortOption _sortOption = ProductSortOption.Default;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final scale = KioskTheme.scale;
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String categoryName = arguments['category'];
    final List<Product> allProducts = arguments['products'];
    
    final double defaultFontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 24.0 * scale;

    final productsInMainCategory = allProducts.where((p) => p.category == categoryName).toList();
    final subcategories = ['All', ...productsInMainCategory.map((p) => p.subcategory).toSet().toList()];

    // --- FILTERING LOGIC ---
    final subCategoryFilteredProducts = selectedSubcategory == 'All'
      ? productsInMainCategory
      : productsInMainCategory.where((p) => p.subcategory == selectedSubcategory).toList();

    // --- SEARCH FILTERING ---
    final searchFilteredProducts = _searchQuery.isEmpty
      ? subCategoryFilteredProducts
      : subCategoryFilteredProducts.where((product) {
          final nameMatch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final tagMatch = product.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
          return nameMatch || tagMatch;
        }).toList();

    // --- SORTING LOGIC ---
    List<Product> sortedProducts = List.from(searchFilteredProducts);
    switch (_sortOption) {
      case ProductSortOption.PriceHighToLow:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.PriceLowToHigh:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.Default:
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
                padding: EdgeInsets.symmetric(vertical: 10.0 * scale, horizontal: 8.0 * scale),
                child: SizedBox(
                  // height: 40.0,
                  height: defaultFontSize * 2.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = subcategories[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0 * scale),
                        child: ChoiceChip(
                          padding: EdgeInsets.fromLTRB(5,5,5,40) ,
                          label: Text(subcategory, style: TextStyle(fontSize: 20 * scale),),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 8.0 * scale),
                child: TextField(
                  style: TextStyle(fontSize: 16 * scale),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search within "$categoryName"',
                    hintStyle: TextStyle(fontSize: 16 * scale),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20 * scale),
                  ),
                ),
              ),
              // --- Sort Options Bar ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0 * scale, vertical: 8.0 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Text("Sort by:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.sort,),
                    SizedBox(width: 4 * scale),
                    ChoiceChip(
                      label: Text('Price: High-Low', style: TextStyle(fontSize: 16 * scale),),
                      selected: _sortOption == ProductSortOption.PriceHighToLow,
                      onSelected: (_) => setState(() => _sortOption = ProductSortOption.PriceHighToLow),
                    ),
                    SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Price: Low-High', style: TextStyle(fontSize: 16 * scale),),
                      selected: _sortOption == ProductSortOption.PriceLowToHigh,
                      onSelected: (_) => setState(() => _sortOption = ProductSortOption.PriceLowToHigh),
                    ),
                  ],
                ),
              ),
              // Divider(),
              // --- Product List ---
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(4 * scale),
                  itemCount: sortedProducts.length, 
                  itemBuilder: (context, index) {
                    final product = sortedProducts[index]; 
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