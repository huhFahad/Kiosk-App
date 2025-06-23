// lib/admin_order_list_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // A package for formatting dates
import 'package:kiosk_app/models/order_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class AdminOrderListPage extends StatefulWidget {
  @override
  _AdminOrderListPageState createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  final DataService _dataService = DataService();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _dataService.readOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'All Orders', showCartButton: false, showHomeButton: false),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders have been placed yet.'));
          }
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  title: Text('Order ID: ${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Date: ${DateFormat.yMMMd().add_jm().format(order.createdAt)}\n'
                    'Total: ₹${order.totalPrice.toStringAsFixed(2)}',
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/admin/order_detail',
                      arguments: order,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}