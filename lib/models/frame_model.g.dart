// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frame_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Frame _$FrameFromJson(Map<String, dynamic> json) => Frame(
  id: json['id'] as String,
  name: json['name'] as String,
  imagePath: json['imagePath'] as String,
  photoX: (json['photoX'] as num?)?.toDouble() ?? 0.1,
  photoY: (json['photoY'] as num?)?.toDouble() ?? 0.1,
  photoWidth: (json['photoWidth'] as num?)?.toDouble() ?? 0.8,
  photoHeight: (json['photoHeight'] as num?)?.toDouble() ?? 0.8,
);

Map<String, dynamic> _$FrameToJson(Frame instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imagePath': instance.imagePath,
  'photoX': instance.photoX,
  'photoY': instance.photoY,
  'photoWidth': instance.photoWidth,
  'photoHeight': instance.photoHeight,
};
