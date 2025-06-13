// lib/admin_dashboard_page.dart

import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        automaticallyImplyLeading: false, // Prevents back button
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Exit Admin Mode',
            onPressed: () {
              // Navigate back to home and remove all admin pages from history
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 1.2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildDashboardCard(context, 'Manage Products', Icons.shopping_bag, () {
            Navigator.pushNamed(context, '/admin/products');
            // print('Go to product management');
          }),
          _buildDashboardCard(context, 'View Orders', Icons.receipt_long, () {
            print('Go to order history');
          }),
          _buildDashboardCard(context, 'System Settings', Icons.settings, () {
            print('Go to system settings');
          }),
          _buildDashboardCard(context, 'App Updates', Icons.update, () {
            print('Check for updates');
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.green),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}