// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // triggers rebuild when text changes
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _executeSearch(BuildContext context) async {
    final query = _searchController.text;
    if (query.isEmpty) return;
    
    FocusScope.of(context).unfocus(); 
    
    final allProducts = await _dataService.readProducts();
    if (mounted) {
      Navigator.pushNamed(context, '/search', arguments: {'query': query, 'products': allProducts});
    }
  }

  void _goTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void _showAdminPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final dataService = DataService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Access'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter PIN'),
            autofocus: true, // This should trigger the OSK in the dialog
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final String savedPin = await dataService.getAdminPin();
                  if (pinController.text == savedPin) {
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin');
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Incorrect PIN')),
                      );
                    }
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
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/urban_rain_logo.png",
                            width: 700,
                            // height: 500,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome to Urban Rain',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 60,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 900,
                            // This is now a standard, editable TextField
                            child: TextField(
                              controller: _searchController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                label: Text('Search for products'),
                                hintText: 'Apples, Mobile Phones.. etc',
                                hintStyle: TextStyle(color: const Color.fromARGB(255, 142, 142, 142)),
                                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor,),
                                suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.arrow_forward_rounded),
                                    tooltip: 'Search',
                                    onPressed: () {
                                      _executeSearch(context);
                                    },
                                  )
                                : null,  
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onSubmitted: (_) => _executeSearch(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "or",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 30),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 700, height: 150,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 6, // This keeps the shadow
                              ),
                              icon: Icon(Icons.grid_view_rounded, size: 60),
                              onPressed: () => _goTo(context, '/categories'),
                              label: Text('Browse All Products', style: TextStyle(fontSize: 50)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(                     
                            width: 700, height: 150,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 6, // This keeps the shadow
                              ),
                              icon: Icon(Icons.map_rounded, size: 60),
                              onPressed: () => _goTo(context, '/map'),
                              label: Text('Find Product on Map', style: TextStyle(fontSize: 50)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 700, height: 150,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 6, // This keeps the shadow
                              ),
                              icon: Icon(Icons.shopping_cart_rounded, size: 60),
                              onPressed: () => _goTo(context, '/cart'),
                              label: Text('View Your Cart', style: TextStyle(fontSize: 50)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 700, height: 150,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context).primaryColor,                                
                                elevation: 6, // This keeps the shadow
                              ),
                              icon: Icon(Icons.print_rounded, size: 60, color: Colors.white),
                              onPressed: () => _goTo(context, '/photo_upload'),
                              label: Text('Print Photos', style: TextStyle(fontSize: 50, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              child: Icon(Icons.icecream_outlined, size: 50,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
                              