// lib/models/frame_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'frame_model.g.dart';

@JsonSerializable()
class Frame {
  final String id;
  final String name;
  final String imagePath; // Path to the frame image (with transparency)

  // Metadata for the photo window, all relative (0.0 to 1.0)
  final double photoX; 
  final double photoY; 
  final double photoWidth; 
  final double photoHeight;

  Frame({
    required this.id,
    required this.name,
    required this.imagePath,
    this.photoX = 0.1, // Default to a small rectangle
    this.photoY = 0.1,
    this.photoWidth = 0.8,
    this.photoHeight = 0.8,
  });

  factory Frame.fromJson(Map<String, dynamic> json) => _$FrameFromJson(json);
  Map<String, dynamic> toJson() => _$FrameToJson(this);
}