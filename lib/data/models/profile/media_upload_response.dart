import 'package:json_annotation/json_annotation.dart';

part 'media_upload_response.g.dart';

@JsonSerializable()
class MediaUploadResponse {
  final String url;
  final String key;
  final String mimetype;
  final int size;

  MediaUploadResponse({
    required this.url,
    required this.key,
    required this.mimetype,
    required this.size,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$MediaUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MediaUploadResponseToJson(this);
}
