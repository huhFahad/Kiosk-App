// lib/widgets/common_app_bar.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/models/cart_model.dart';
import 'package:provider/provider.dart';

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
  
  // const double actionZoneWidth = 237.2;
  const double actionZoneWidth = 65;

  return AppBar(
    leadingWidth: actionZoneWidth, 
    automaticallyImplyLeading: false,
    leading: canPop
      ? Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            iconSize: 30, 
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
      style: const TextStyle(
        fontSize: 24,
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
                iconSize: 30,
                tooltip: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),

            if (showCartButton) const _CartBadge(),

            // if (showCartButton)
            //   IconButton(
            //     icon: Icon(Icons.shopping_cart_outlined),
            //     iconSize: 70,
            //     tooltip: 'View Cart',
            //     onPressed: () {
            //       Navigator.of(context).pushNamed('/cart');
            //     },
            //   ),

            if (showSaveButton)
              IconButton(
                icon: Icon(Icons.save_outlined),
                iconSize: 30,
                tooltip: 'Save',
                onPressed: onSavePressed,
              ),
            
            if (extraActions != null) ...extraActions,

            // const SizedBox(width: 30),
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
      return Consumer<CartModel>(
        builder: (context, cart, child) {
          return Stack(
            alignment: Alignment.center,
            children: [cart.itemCount == 0
              ? IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  iconSize: 30,
                  tooltip: 'View Cart',
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  iconSize: 30,
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
                          padding: const EdgeInsets.only(bottom: 44, left: 44),
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            child: Center(
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
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