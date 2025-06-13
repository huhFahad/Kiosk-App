// lib/widgets/common_app_bar.dart
import 'package:flutter/material.dart';

PreferredSizeWidget CommonAppBar({
  required BuildContext context, // It now requires the context to be passed in
  required String title,
  List<Widget>? extraActions,
}) {
  final canPop = Navigator.of(context).canPop();
  final onCartPage = ModalRoute.of(context)?.settings.name == '/cart';

  // Get the height directly from the theme using the passed-in context
  final double appBarHeight = Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight;

  return AppBar(
    // The theme from KioskTheme will control:
    // - backgroundColor, titleTextStyle, elevation, centerTitle
    
    // We explicitly set the height here to ensure it's always correct
    toolbarHeight: appBarHeight, 
    
    // automaticallyImplyLeading: canPop,

    leading: canPop
      ? Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 60),
              ),
            ),
          ),
        )
      : null,


    title: Text(title),
    actions: [
      IconButton(
        icon: const Icon(Icons.home_outlined),
        tooltip: 'Go to Home',
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      ),
      if (!onCartPage)
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'View Cart',
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      if (extraActions != null) ...extraActions!,
      SizedBox(width: 30,)
    ],
  );
}