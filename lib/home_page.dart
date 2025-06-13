// lib/home_page.dart

import 'package:flutter/material.dart';
// import 'models/product_model.dart'; // We'll need this for the search
import 'services/data_service.dart'; // And the service to load products

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final DataService _dataService = DataService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _executeSearch(BuildContext context) async {
    final query = _searchController.text;
    if (query.isEmpty) {
      // Don't search for nothing
      return; 
    }
    
    // We must load the full product list to search through it
    final allProducts = await _dataService.readProducts();
    
    // Use `mounted` check because of the async gap
    if (mounted) {
      Navigator.pushNamed(
        context,
        '/search',
        arguments: {
          'query': query,
          'products': allProducts,
        },
      );
    }
  }

  void _goTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void _showAdminPinDialog(BuildContext context) {
    // ... this method remains exactly the same ...
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Admin Access'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Enter PIN'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == '1234') {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect PIN')),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 100, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to Our Store',
                      // style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    SizedBox(height: 40),

                    // --- THE NEW SEARCH BAR ---
                    SizedBox(
                      width: 600,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for products (e.g., milk, apples)',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onSubmitted: (_) => _executeSearch(context),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("or", style: TextStyle(color: Colors.grey.shade600)),
                    // --- END OF SEARCH BAR ---
                    SizedBox(height:20),
                    SizedBox(
                      width: 350,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.grid_view_rounded),
                        onPressed: () => _goTo(context, '/categories'),
                        label: Text('Browse All Products'),
                        // style:
                        //   ElevatedButton.styleFrom(
                        //     minimumSize: Size(double.infinity, 60),
                        //     textStyle: TextStyle(fontSize: 20),
                        //   ),
                      ),
                    ),
                    SizedBox(height:20),
                    SizedBox(
                      width: 350,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.map_rounded),
                        onPressed: () => _goTo(context, '/map'),
                        label: Text('Find Product on Map'),
                        // style: ElevatedButton.styleFrom(
                        //   minimumSize: Size(double.infinity, 60),
                        //   textStyle: TextStyle(fontSize: 20),
                        // ),
                      ),
                    ),  
                    SizedBox(height:20),
                    SizedBox(
                      width: 350,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.shopping_cart_rounded),
                        onPressed: () => _goTo(context, '/cart'),
                        label: Text('View Your Cart'),
                        // style: ElevatedButton.styleFrom(
                        //   minimumSize: Size(double.infinity, 60),
                        //   textStyle: TextStyle(fontSize: 20),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: GestureDetector(
              onLongPress: () => _showAdminPinDialog(context),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}