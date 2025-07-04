// lib/cart_page.dart

import 'package:flutter/material.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'admin_product_list_page.dart';
import 'widgets/common_app_bar.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final scale = KioskTheme.scale;
  void _showClearCartConfirmation() {
    final cart = Provider.of<CartModel>(context, listen: false);

    if (cart.items.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Clear Cart?', 
          style: TextStyle(
            fontSize: 24 * scale
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(
            fontSize: 18 * scale,
            height: 1 * scale
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 18 * scale,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cart.clear(); 
            },
            child: Text(
              'Clear', 
              style: TextStyle(
                color: Colors.red,
                fontSize: 18 * scale,
              )
            ),
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
        title: Text('Confirm Your Order', style: TextStyle(fontSize: 24 * scale),),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0 * scale)
        ),
        content: Text(
          '\nYou are about to place an order for ${cart.itemCount} items, '
          'totaling ₹${cart.totalPrice.toStringAsFixed(2)}.\n\nDo you wish to proceed?',
          style: TextStyle(fontSize: 18 * scale, height: 1 * scale),
          softWrap: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Go Back', style: TextStyle(fontSize: 18 * scale),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, 
              foregroundColor: Colors.white, 
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final String orderId = cart.placeOrder();
              Navigator.pushNamed(context, '/confirmation', arguments: orderId);
            },
            child: Text('Confirm', style: TextStyle(fontSize: 18 * scale),),
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
                  Icon((Icons.shopping_cart_outlined) , size: 240 * scale, color: Color.fromARGB(255, 233, 226, 226)),
                  SizedBox(height: 20 * scale),
                  Text('Your cart is empty.', style: TextStyle(fontSize: 24 * scale)),
                ]
              ),
            ); 
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0 * scale),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4.0 * scale),
                      child: ListTile(
                        leading: ProductImageView(
                          // width: 80 * scale,
                          // height: 120 * scale,
                          imagePath: cartItem.product.image
                        ),
                        title: Text(cartItem.product.name, style: TextStyle(fontSize: 24 * scale)),
                        subtitle: Text('₹${cartItem.product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18 * scale,)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, size: 28 * scale,),
                              onPressed: () => cart.decreaseQuantity(cartItem),
                            ),
                            Text(cartItem.quantity.toString(), style: TextStyle(fontSize: 22 * scale)),
                            IconButton(
                              icon: Icon(Icons.add, size: 28 * scale,),
                              onPressed: () => cart.add(cartItem.product),
                            ),

                            // SizedBox(width: 6 * scale,),

                            VerticalDivider(color: Colors.grey,), 

                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 25 * scale,),
                              tooltip: 'Remove from cart',
                              onPressed: () {
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
                                        onPressed: () {
                                          Navigator.of(ctx).pop(); 
                                          cart.removeItemById(cartItem.product.id);
                                        },
                                        style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                                        child: Text('Remove'),
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
                padding: EdgeInsets.all(10.0 * scale),
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
                          'Number of Items:  ${cart.itemCount} ',
                          style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.delete_sweep_outlined, size: 30 * scale,),
                          label: Text('Clear Cart', style: TextStyle(fontSize: 20 * scale),),
                          onPressed: _showClearCartConfirmation,
                        ),
                        Text(
                          'Total:  ₹${cart.totalPrice.toStringAsFixed(2)} ',
                          style: TextStyle(
                            fontSize: 25 * scale, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.black
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 6 * scale),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 20 * scale),
                          backgroundColor: Colors.green, 
                          foregroundColor: Colors.white, 
                        ),
                        onPressed: _showPlaceOrderConfirmation,
                        child: Text(
                          'Place Order', 
                          style: TextStyle(
                            fontSize: 30 * scale,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                    ),

                    SizedBox(height: 12 * scale),
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
