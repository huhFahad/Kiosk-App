// lib/widgets/common_app_bar.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';

typedef VoidCallback = void Function();

PreferredSizeWidget CommonAppBar({
  required BuildContext context,
  required String title,
  bool showHomeButton = true, 
  bool showCartButton = true, 
  bool showSaveButton = false,
  VoidCallback? onSavePressed,
  List<Widget>? extraActions,
}) {
  final canPop = Navigator.of(context).canPop();
  final scale = KioskTheme.scale;
  
  // double actionZoneWidth = 237.2;
  double actionZoneWidth = 60 * scale;

  return AppBar(
    leadingWidth: actionZoneWidth, 
    automaticallyImplyLeading: false,
    leading: canPop
      ? Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            iconSize: 45 * scale, 
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
        )
      : const SizedBox.shrink(),  
    centerTitle: true,
    titleSpacing: 0.0,
    title: Text(
      title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.bold,
      ),
    ),

    actions: [
      Container(
        // width: actionZoneWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            if (showHomeButton)
              IconButton(
                icon: Icon(Icons.home_outlined),
                iconSize: 45 * scale,
                tooltip: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),

            if (showCartButton) const _CartBadge(),

            // if (showCartButton)
            //   IconButton(
            //     icon: Icon(Icons.shopping_cart_outlined),
            //     iconSize: 45 * scale,
            //     tooltip: 'View Cart',
            //     onPressed: () {
            //       Navigator.of(context).pushNamed('/cart');
            //     },
            //   ),

            if (showSaveButton)
              IconButton(
                icon: Icon(Icons.save_outlined),
                iconSize: 45 * scale,
                tooltip: 'Save',
                onPressed: onSavePressed,
              ),
            
            if (extraActions != null) ...extraActions,

            SizedBox(width: 10 * scale),
          ],
        ),
      ),
    ],
  );
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context) {
      final scale = KioskTheme.scale;
      return Consumer<CartModel>(
        builder: (context, cart, child) {
          return Stack(
            alignment: Alignment.center,
            children: [cart.itemCount == 0
              ? IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  iconSize: 45 * scale,
                  tooltip: 'View Cart',
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  iconSize: 45 * scale,
                  tooltip: 'View Cart',
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: cart.itemCount > 0
                    ? Align(
                        key: const ValueKey('cartBadge'),
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24 * scale, left: 24 * scale),
                          child: Container(
                            padding: EdgeInsets.all(2.0 * scale),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).primaryColor, width: 1.5 * scale),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18 * scale,
                              minHeight: 18 * scale,
                            ),
                            child: Center(
                              child: Text(
                                '${cart.itemCount}',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      );
    }

}