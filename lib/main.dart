// lib/main.dart

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'models/cart_model.dart';
import 'categories_page.dart';
import 'products_list_page.dart';
import 'order_confirmation_page.dart';
import 'map_page.dart';
import 'cart_page.dart';
import 'home_page.dart';
import 'search_results_page.dart';
import 'admin_template_list_page.dart';

// import 'photo_and_frame_editor_page.dart';
import 'frame_selection_page.dart';
import 'photo_upload_page.dart';
import 'photo_editor_page.dart';
import 'print_confirmation_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_product_list_page.dart';
import 'admin_frame_list_page.dart';
import 'theme/kiosk_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // windowManager.waitUntilReadyToShow(const WindowOptions(fullScreen: true));
  // windowManager.waitUntilReadyToShow(
  //   const WindowOptions(
  //     fullScreen: true,
  //     titleBarStyle: TitleBarStyle.hidden,
  //     alwaysOnTop: false,
  //   )
  // );

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: KioskApp(),
    ),
  );
}

class KioskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retail Kiosk',
      // theme: ThemeData(
      //   brightness: Brightness.light,
      //   primarySwatch: Colors.green,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      theme: KioskTheme.themeData,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/categories': (context) => CategoriesPage(),
        '/products': (context) => ProductsListPage(),
        '/map': (context) => MapPage(),
        '/cart': (context) => CartPage(),
        '/confirmation': (context) => OrderConfirmationPage(),
        '/search': (context) => SearchResultsPage(),
        '/admin': (context) => AdminDashboardPage(),
        '/admin/products': (context) => AdminProductListPage(),
        '/admin/frames': (context) => AdminFrameListPage(),
        '/admin/templates': (context) => AdminTemplateListPage(),
        '/frame_selection': (context) => FrameSelectionPage(),
        '/photo_upload': (context) => PhotoUploadPage(),
        '/photo_editor': (context) => PhotoEditorPage(),
        // '/photo_editor': (context) => PhotoAndFrameEditorPage(),
        '/print_confirmation': (context) => PrintConfirmationPage(),

      },
    );
  }
}

