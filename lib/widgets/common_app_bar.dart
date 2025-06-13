// lib/widgets/common_app_bar.dart
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showCartIcon;

  const CommonAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showCartIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.home_outlined),
          tooltip: 'Go to Home',
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
        ),

        if (showCartIcon)
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            tooltip: 'View Cart',
            onPressed: () {
              // Avoid pushing a new cart page if we are already on it.
              // This is a good defensive check.
              if (ModalRoute.of(context)?.settings.name != '/cart') {
                Navigator.of(context).pushNamed('/cart');
              }
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}