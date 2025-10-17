// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_job_media_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteJobRequest _$CompleteJobRequestFromJson(Map<String, dynamic> json) =>
    CompleteJobRequest(
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CompleteJobRequestToJson(CompleteJobRequest instance) =>
    <String, dynamic>{
      'files': instance.files,
    };
