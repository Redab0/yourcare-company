// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaUploadResponse _$MediaUploadResponseFromJson(Map<String, dynamic> json) =>
    MediaUploadResponse(
      url: json['url'] as String,
      key: json['key'] as String,
      mimetype: json['mimetype'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$MediaUploadResponseToJson(
        MediaUploadResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
      'key': instance.key,
      'mimetype': instance.mimetype,
      'size': instance.size,
    };
