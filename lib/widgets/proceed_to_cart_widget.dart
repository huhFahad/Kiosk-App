// lib/widgets/proceed_to_cart_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kiosk_app/models/cart_model.dart';

class ProceedToCartWidget extends StatelessWidget {
  const ProceedToCartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<CartModel>(
          builder: (context, cart, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: cart.items.isEmpty
                  ? const SizedBox.shrink(key: ValueKey('empty_cart_button'))
                  : FloatingActionButton.extended(
                      key: const ValueKey('cart_button_with_items'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 50,),
                      label: Text(
                        '${cart.itemCount} Items | ₹${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );

  }
}