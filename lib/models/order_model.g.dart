// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'product': instance.product.toJson(),
  'quantity': instance.quantity,
};

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['id'] as String,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'totalPrice': instance.totalPrice,
  'createdAt': instance.createdAt.toIso8601String(),
};
