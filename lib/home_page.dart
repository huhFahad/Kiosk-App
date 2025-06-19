// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/kiosk_scaffold.dart'; // Import our new widget

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State for this page is now very simple
  final _searchController = TextEditingController();
  final DataService _dataService = DataService();
  final FocusNode _searchFocusNode = FocusNode();

  // We no longer need _isKeyboardVisible or the listener functions here.
  // The KioskScaffold handles it all.

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  void _executeSearch(BuildContext context) async {
    final query = _searchController.text;
    if (query.isEmpty) return;
    
    // Unfocus the text field to hide the keyboard before navigating
    _searchFocusNode.unfocus(); 
    
    final allProducts = await _dataService.readProducts();
    if (mounted) {
      Navigator.pushNamed(context, '/search', arguments: {'query': query, 'products': allProducts});
    }
  }

  void _goTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void _showAdminPinDialog(BuildContext context) {
    // This dialog is separate and its keyboard is handled by the OS/Dialog itself.
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
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
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
    // We use our new KioskScaffold as the root widget for the page
    return KioskScaffold(
      // We pass the controller and focus node it needs to manage the keyboard
      keyboardController: _searchController,
      keyboardFocusNode: _searchFocusNode,
      
      // The 'body' is everything that should be displayed on the page
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store, size: 250, color: Colors.green),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome to Our Store',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 60, fontWeight: FontWeight.normal, fontFamily: 'Times New Roman'),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 900,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode, // Connect the TextField to the FocusNode
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search for products...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                          ),
                          onSubmitted: (_) => _executeSearch(context),
                        ),
                      ),
                    
                        SizedBox(height: 20),
                        Text("or", style: TextStyle(color: Colors.grey.shade600, fontSize: 30)),
                        SizedBox(height:20),
                        SizedBox(
                          width: 700,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.grid_view_rounded, size: 60),
                            onPressed: () => _goTo(context, '/categories'),
                            label: Text('Browse All Products', style: TextStyle(fontSize: 50)),
                          ),
                        ),
                        SizedBox(height:20),
                        SizedBox(
                          width: 700,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.map_rounded, size: 60),
                            onPressed: () => _goTo(context, '/map'),
                            label: Text('Find Product on Map', style: TextStyle(fontSize: 50)),
                          ),
                        ),  
                        SizedBox(height:20),
                        SizedBox(
                          width: 700,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.shopping_cart_rounded, size: 60),
                            onPressed: () => _goTo(context, '/cart'),
                            label: Text('View Your Cart', style: TextStyle(fontSize: 50)),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 700,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.print_rounded, size: 60, color: Colors.white),
                            onPressed: () {
                              _goTo(context, '/photo_upload');
                              // Navigator.pushNamed(context, '/photo_editor');

                            },
                            label: Text('Print Photos', style: TextStyle(fontSize: 50, color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 8, 45, 82)),
                          ),
                        ),
                        ],
                  ),
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