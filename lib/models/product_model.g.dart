// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  subcategory: json['subcategory'] as String,
  price: (json['price'] as num).toDouble(),
  unit: json['unit'] as String,
  image: json['image'] as String,
  mapX: (json['mapX'] as num?)?.toDouble() ?? -1.0,
  mapY: (json['mapY'] as num?)?.toDouble() ?? -1.0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'price': instance.price,
  'unit': instance.unit,
  'image': instance.image,
  'mapX': instance.mapX,
  'mapY': instance.mapY,
  'tags': instance.tags,
};
