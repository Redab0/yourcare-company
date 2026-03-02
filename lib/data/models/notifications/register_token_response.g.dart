// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterTokenResponse _$RegisterTokenResponseFromJson(
        Map<String, dynamic> json) =>
    RegisterTokenResponse(
      tokensCount: (json['tokensCount'] as num).toInt(),
      platform: json['platform'] as String,
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RegisterTokenResponseToJson(
        RegisterTokenResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'platform': instance.platform,
      'tokensCount': instance.tokensCount,
    };
