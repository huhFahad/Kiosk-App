// lib/models/product_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart'; // This file will be generated

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final double price;
  final String unit;
  final String image;
  final double mapX;
  final double mapY;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.unit,
    required this.image,
    this.mapX = -1.0, 
    this.mapY = -1.0,
    this.tags = const [],
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? subcategory,
    double? price,
    String? unit,
    String? image,
    double? mapX,
    double? mapY,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      image: image ?? this.image,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
      tags: tags ?? this.tags,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}