// lib/widgets/quantity_control_widget.dart

import 'package:flutter/material.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class QuantityControlWidget extends StatelessWidget {
  final Product product;

  const QuantityControlWidget({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = KioskTheme.scale;

    return Consumer<CartModel>(
      builder: (context, cart, child) {
        final cartItem = cart.findItemById(product.id);
        final int quantity = cartItem?.quantity ?? 0;

        if (quantity == 0) {
          return SizedBox(
            width: 80 * scale,
            height: 45 * scale,
            child: ElevatedButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.6 * scale,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                cart.add(product);
              },
              child: Center(
                child: Text(
                  'Add',
                  style: TextStyle(fontSize: 16 * scale), 
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).primaryColor.withOpacity(0.15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease quantity button
              IconButton(
                icon: Icon(Icons.remove, color: Theme.of(context).primaryColor, size: 20 * scale,),
                onPressed: () {
                  if (cartItem != null) {
                    cart.decreaseQuantity(cartItem);
                  }
                },
                splashRadius: 10 * scale,
              ),
              // The quantity display
              Text(
                quantity.toString(),
                style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold),
              ),
              // Increase quantity button
              IconButton(
                icon: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 20 * scale),
                onPressed: () {
                  cart.add(product);
                },
                splashRadius: 10 * scale,
              ),
            ],
          ),
        );
      },
    );
  }
}