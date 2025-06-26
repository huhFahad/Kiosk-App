// lib/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'admin_product_list_page.dart';
import 'widgets/common_app_bar.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _showClearCartConfirmation() {
    // Get the CartModel once, without listening.
    final cart = Provider.of<CartModel>(context, listen: false);

    // Don't show the dialog if the cart is already empty.
    if (cart.items.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear Cart?'),
        content: Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cart.clear(); 
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPlaceOrderConfirmation() {
    final cart = Provider.of<CartModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Your Order'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0)
        ),
        content: Text(
          '\nYou are about to place an order for ${cart.itemCount} items, '
          'totaling ₹${cart.totalPrice.toStringAsFixed(2)}.\n\nDo you want to proceed?',
          style: TextStyle(fontSize: 20, height: 1.0),
          softWrap: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final String orderId = cart.placeOrder();
              Navigator.pushNamed(context, '/confirmation', arguments: orderId);
            },
            child: Text('Confirm & Place Order'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context, 
        title: 'Your Cart', 
        showCartButton: false,
      ), 
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon((Icons.shopping_cart_outlined) , size: 240, color: Color.fromARGB(255, 233, 226, 226)),
                  SizedBox(height: 20),
                  const Text('Your cart is empty.', style: TextStyle(fontSize: 24)),
                ]
              ),
            ); 
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: ProductImageView(
                          // width: 80,
                          // height: 80,
                          imagePath: cartItem.product.image
                        ),
                        title: Text(cartItem.product.name, style: TextStyle(fontSize: 30)),
                        subtitle: Text('₹${cartItem.product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 28)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // The quantity controls
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => cart.decreaseQuantity(cartItem),
                            ),
                            Text(cartItem.quantity.toString(), style: TextStyle(fontSize: 25)),
                            SizedBox(width: 8,),
                            IconButton(
                              icon: Icon(Icons.add, size: 40,),
                              onPressed: () => cart.add(cartItem.product),
                            ),

                            SizedBox(width: 15,),

                            // A divider for visual separation
                            VerticalDivider(), 

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Number of Items:  ${cart.itemCount}   ',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.delete_sweep_outlined, size: 40,),
                          label: Text('Clear Cart'),
                          onPressed: _showClearCartConfirmation,
                        ),
                        Text('Total:  ₹${cart.totalPrice.toStringAsFixed(2)}  ', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black)),
                        // Text('₹${cart.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // The "Place Order" button.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Theme.of(context).primaryColor, 
                          foregroundColor: Colors.white, 
                        ),
                        onPressed: _showPlaceOrderConfirmation,
                        child: Text('Place Order', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                  ],
                ),
              ),

              // This is the total price bar at the bottom
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         'Number of Items:  ${cart.itemCount}',
              //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              //       ),
              //       Text(
              //         'Total:  ₹${cart.totalPrice.toStringAsFixed(2)}',
              //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
