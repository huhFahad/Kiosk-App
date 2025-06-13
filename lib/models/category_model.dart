// lib/models/category_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class Category {
  final String name;
  String imagePath;

  Category({required this.name, required this.imagePath});

  Category copyWith({
    String? name,
    String? imagePath,
  }) {
    return Category(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}