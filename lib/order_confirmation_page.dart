// lib/order_confirmation_page.dart

import 'dart:async';
import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatefulWidget {
  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate back to the home screen after 5 seconds.
    Timer(Duration(seconds: 5), () {
      // This removes all previous screens (like cart, products) from history.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', // Navigate to the Home page
        (Route<dynamic> route) => false, // This predicate always returns false
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // We can get the order ID passed from the cart page
    final String orderId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor, size: 120),
            SizedBox(height: 24),
            Text(
              'Thank You!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your order has been placed.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Order ID: $orderId',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            Text(
              'Please proceed to the counter for payment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}