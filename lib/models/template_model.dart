// lib/models/template_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'template_model.g.dart';

@JsonSerializable()
class Template {
  final String id;
  final String name; // A name for the admin to identify it
  final String imagePath; // Path to the template image

  Template({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}