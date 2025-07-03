// lib/main.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'models/cart_model.dart';
import 'loading_page.dart';
import 'categories_page.dart';
import 'products_list_page.dart';
import 'order_confirmation_page.dart';
import 'map_page.dart';
import 'cart_page.dart';
import 'home_page.dart';
import 'search_results_page.dart';
import 'admin_template_list_page.dart';
import 'frame_selection_page.dart';
import 'photo_upload_page.dart';
import 'photo_editor_page.dart';
import 'print_confirmation_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_product_list_page.dart';
import 'admin_frame_list_page.dart';
import 'admin_order_list_page.dart';
import 'admin_order_detail_page.dart';
import 'admin_map_picker_page.dart';
import 'system_settings_page.dart';
import 'wifi_settings_page.dart';
import 'screensaver_page.dart';
import 'thank_you_page.dart';
import 'widgets/inactivity_detector.dart';
import 'notifiers/settings_notifier.dart';
import 'theme/kiosk_theme.dart';
import 'theme/theme_notifier.dart';

void main() {
  final frames = ['⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷'];
  int i = 0;
  Timer.periodic(Duration(milliseconds: 100), (timer) {
    stdout.write('\r${frames[i++ % frames.length]} Loading...');
  });
  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CartModel()),
          ChangeNotifierProvider(create: (context) => ThemeNotifier()),
          ChangeNotifierProvider(create: (context) => SettingsNotifier()),
        ],
        child: InactivityDetector(
          child: KioskApp(),
        ),
      ),
    ),
  );
  
}

class KioskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    
    final screenWidth = MediaQuery.of(context).size.width;
    KioskTheme.setScaleFromWidth(screenWidth);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Retail Kiosk',
      theme: themeNotifier.currentTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
        '/': (context) => HomePage(),
        '/categories': (context) => CategoriesPage(),
        '/products': (context) => ProductsListPage(),
        '/map': (context) => MapPage(),
        '/cart': (context) => CartPage(),
        '/confirmation': (context) => OrderConfirmationPage(),
        '/search': (context) => SearchResultsPage(),
        '/frame_selection': (context) => FrameSelectionPage(),
        '/photo_upload': (context) => PhotoUploadPage(),
        '/photo_editor': (context) => PhotoEditorPage(),
        '/print_confirmation': (context) => PrintConfirmationPage(),
        '/admin': (context) => AdminDashboardPage(),
        '/admin/products': (context) => AdminProductListPage(),
        '/admin/frames': (context) => AdminFrameListPage(),
        '/admin/templates': (context) => AdminTemplateListPage(),
        '/admin/orders':(context) => AdminOrderListPage(),
        '/admin/order_detail': (context) => AdminOrderDetailPage(),
        '/admin/settings': (context) => SystemSettingsPage(),
        '/admin/map_picker': (context) => AdminMapPickerPage(),
        '/admin/wifi': (context) => WifiSettingsPage(),
        '/screensaver': (context) => ScreensaverPage(),
        '/thank_you': (context) => ThankYouPage(),
      },
    );
  }
}

