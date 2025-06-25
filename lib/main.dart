// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:window_manager/window_manager.dart';

import 'models/cart_model.dart';
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
import 'printer_settings_page.dart';
import 'screensaver_page.dart';
import 'thank_you_page.dart';
import 'widgets/inactivity_detector.dart';
import 'notifiers/settings_notifier.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // windowManager.waitUntilReadyToShow(const WindowOptions(fullScreen: true));
  // windowManager.waitUntilReadyToShow(
  //   const WindowOptions(
  //     fullScreen: true,
  //     titleBarStyle: TitleBarStyle.hidden,
  //     alwaysOnTop: false,
  //   )
  // );
  
  await dotenv.load(fileName: ".env");
  final String encryptionKey = dotenv.env['ENCRYPTION_KEY'] ?? 'd3v3l0pm3ntK3y16';
  if (encryptionKey.length != 16) {
    throw Exception('Encryption key must be 16 characters long.');
  }
  await EncryptedSharedPreferences.initialize(encryptionKey);

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

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Retail Kiosk',
      theme: themeNotifier.currentTheme,
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
        '/admin/printers': (context) => PrinterSettingsPage(),
        '/screensaver': (context) => ScreensaverPage(),
        '/thank_you': (context) => ThankYouPage(),
      },
    );
  }
}

