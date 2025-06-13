// lib/widgets/quantity_control_widget.dart

import 'package:flutter/material.dart';
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
    // We use a Consumer here so that ONLY this little widget rebuilds
    // when the cart changes, not the entire product list page. This is efficient.
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        // Find the specific item in the cart to get its quantity
        final cartItem = cart.findItemById(product.id);
        final int quantity = cartItem?.quantity ?? 0;

        // If the quantity is 0, show the simple "Add" button.
        if (quantity == 0) {
          return ElevatedButton(
            onPressed: () {
              cart.add(product);
            },
            child: Text('Add'),
          );
        }

        // If the quantity is > 0, show the +/- controls.
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.green.shade50,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease quantity button
              IconButton(
                icon: Icon(Icons.remove, color: Colors.green),
                onPressed: () {
                  // The decreaseQuantity method in CartModel will handle
                  // removing the item if the quantity becomes 0.
                  if (cartItem != null) {
                    cart.decreaseQuantity(cartItem);
                  }
                },
                splashRadius: 20,
              ),
              // The quantity display
              Text(
                quantity.toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Increase quantity button
              IconButton(
                icon: Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  cart.add(product);
                },
                splashRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}