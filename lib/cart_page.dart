// lib/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'admin_product_list_page.dart';
import 'widgets/common_app_bar.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Your Cart',
        ), 
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Text('🧺 Your cart is empty.', style: TextStyle(fontSize: 24)),
            );
          }

          return Column(
            children: [
              // This makes the list take up most of the screen
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: ProductImageView(imagePath: cartItem.product.image),
                        title: Text(cartItem.product.name, style: TextStyle(fontSize: 18)),
                        subtitle: Text('₹${cartItem.product.price.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // The quantity controls
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => cart.decreaseQuantity(cartItem),
                            ),
                            Text(cartItem.quantity.toString(), style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8,),
                            IconButton(
                              icon: Icon(Icons.add, size: 40,),
                              onPressed: () => cart.add(cartItem.product),
                            ),

                            SizedBox(width: 15,),

                            // A divider for visual separation
                            VerticalDivider(), 

                            // --- THE NEW DELETE BUTTON ---
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 40,),
                              tooltip: 'Remove from cart',
                              onPressed: () {
                                // Show a confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Remove Item'),
                                    content: Text('Are you sure you want to remove all "${cartItem.product.name}" from your cart?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.of(ctx).pop(),
                                      ),
                                      TextButton(
                                        child: Text('Remove'),
                                        onPressed: () {
                                          Navigator.of(ctx).pop(); // Close dialog
                                          cart.removeItemById(cartItem.product.id);
                                        },
                                        style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                   },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // The total price row stays the same.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('₹${cart.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    // The new "Place Order" button.
                    SizedBox(
                      width: double.infinity, // Makes the button take the full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.green, // Use primary color
                          foregroundColor: Colors.white, // Text color
                        ),
                        onPressed: () {
                          // Get the cart model
                          var cart = Provider.of<CartModel>(context, listen: false);

                          if (cart.items.isNotEmpty) {
                            // Place the order and get the new order ID
                            final String orderId = cart.placeOrder();

                            // Navigate to the confirmation screen, passing the order ID
                            Navigator.pushNamed(context, '/confirmation', arguments: orderId);
                          }
                        },
                        child: Text('Place Order', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),

              // This is the total price bar at the bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${cart.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
