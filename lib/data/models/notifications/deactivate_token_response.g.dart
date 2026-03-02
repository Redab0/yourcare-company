// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deactivate_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeactivateTokenResponse _$DeactivateTokenResponseFromJson(
        Map<String, dynamic> json) =>
    DeactivateTokenResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$DeactivateTokenResponseToJson(
        DeactivateTokenResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
    };
