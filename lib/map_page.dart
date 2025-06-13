// lib/map_page.dart

import 'package:flutter/material.dart';
import '../widgets/common_app_bar.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Find Product on Map')),
      appBar: CommonAppBar(title: 'Find Product on Map'),
      body: Center(
        child: Text(
          '🗺️ Store Map Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
