// lib/models/order_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:kiosk_app/models/product_model.dart';

part 'order_model.g.dart';

// We define the CartItem's JSON conversion here since it's part of an Order
@JsonSerializable(explicitToJson: true)
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}


@JsonSerializable(explicitToJson: true)
class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}