// lib/admin_order_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiosk_app/models/order_model.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

// A helper widget to display product images consistently
class OrderDetailProductImage extends StatelessWidget {
  final String imagePath;
  const OrderDetailProductImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');
    return SizedBox(
      width: 50,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: isAsset
            ? Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported))
            : Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported)),
      ),
    );
  }
}

class AdminOrderDetailPage extends StatelessWidget {
  const AdminOrderDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Receive the specific Order object passed from the list page
    final order = ModalRoute.of(context)!.settings.arguments as Order;

    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Order Details', showCartButton: false, showHomeButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Order Summary Card ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Order Summary', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildSummaryRow('Order ID:', order.id),
                    _buildSummaryRow('Date:', DateFormat.yMMMd().add_jm().format(order.createdAt)),
                    _buildSummaryRow('Total Items:', order.items.fold(0, (sum, item) => sum + item.quantity).toString()),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Total Price:',
                      '₹${order.totalPrice.toStringAsFixed(2)}',
                      isBold: true,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor,),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // --- Items List Header ---
            Text('Items in this Order', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // --- List of Products in the Order ---
            ListView.builder(
              // We use shrinkWrap and physics because this ListView is inside a SingleChildScrollView
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final cartItem = order.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: OrderDetailProductImage(imagePath: cartItem.product.image),
                    title: Text(cartItem.product.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Price: ₹${cartItem.product.price.toStringAsFixed(2)}'),
                    trailing: Text(
                      'Qty: ${cartItem.quantity}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent summary rows
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Text(
            value,
            style: style ?? TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}