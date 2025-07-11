// lib/models/cart_model.dart

import 'package:flutter/foundation.dart';
import 'product_model.dart';
import 'order_model.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'dart:math';

class CartModel extends ChangeNotifier {
  // The cart now stores a list of CartItem objects
  final List<CartItem> _items = [];
  final DataService _dataService = DataService();

  // Public getter for the items
  List<CartItem> get items => _items;

  // Getter to calculate the total price of all items in the cart
  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  CartItem? findItemById(String productId) {
    try {
      // firstWhere will throw an error if no item is found.
      // Using try-catch or firstWhereOrNull (from collection package) is safer.
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      // If no item is found, return null.
      return null;
    }
  }

  // Upgraded 'add' method to handle quantities
  void add(Product product) {
    // Check if the product is already in the cart
    for (var item in _items) {
      if (item.product.id == product.id) {
        // If it is, just increase the quantity and exit
        item.quantity++;
        notifyListeners();
        return;
      }
    }

    // If it's not in the cart, add it as a new CartItem
    _items.add(CartItem(product: product));
    notifyListeners();
  }

  // Method to remove an entire item from the cart
  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }
  
  // Method to decrease an item's quantity
  void decreaseQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      // If quantity is 1, remove the item completely
      _items.remove(cartItem);
    }
    notifyListeners();
  }

  void removeItemById(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Method to clear the cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  String placeOrder() {
    // Create a unique ID
    final orderId = 'ORD-${Random().nextInt(9000) + 1000}';
    
    // Create a new Order object from the current cart state
    final newOrder = Order(
      id: orderId,
      items: List<CartItem>.from(_items), // Create a copy of the items list
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
    );
    
    // Use the DataService to save the order to a file
    _dataService.saveOrder(newOrder);

    // Clear the cart for the next customer
    _items.clear();
    notifyListeners();
    
    return orderId;
  }

}