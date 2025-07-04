// lib/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scale = KioskTheme.scale;
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Admin Dashboard',
        showCartButton: false,
        showHomeButton: false,
        extraActions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, size: 45 * scale,),
            tooltip: 'Exit Admin Mode',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0 * scale),
        childAspectRatio: 1.0,
        crossAxisSpacing: 6.0 * scale,
        mainAxisSpacing: 12.0 * scale,
        children: [
          _buildDashboardCard(context, 'Manage Products', Icons.shopping_bag, () {
            Navigator.pushNamed(context, '/admin/products');
          }),
          _buildDashboardCard(context, 'Manage Frames', Icons.filter_frames_outlined, () {
            Navigator.pushNamed(context, '/admin/frames');
          }),
          _buildDashboardCard(context, 'Manage Templates', Icons.photo_library, () {
            Navigator.pushNamed(context, '/admin/templates');
          }),
          _buildDashboardCard(context, 'View Orders', Icons.receipt_long, () {
            Navigator.pushNamed(context, '/admin/orders');
          }),
          _buildDashboardCard(context, 'System Settings', Icons.settings, () {
            Navigator.pushNamed(context, '/admin/settings');
          }),
          _buildDashboardCard(context, 'App Updates', Icons.update, () {
            print('Check for updates');
          }),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final scale = KioskTheme.scale;
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100 * scale, color: Theme.of(context).primaryColor,),
            SizedBox(height: 10 * scale),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22 * scale)),
          ],
        ),
      ),
    );
  }
}