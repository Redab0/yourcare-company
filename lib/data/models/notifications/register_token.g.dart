// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterToken _$RegisterTokenFromJson(Map<String, dynamic> json) =>
    RegisterToken(
      fcmToken: json['fcmToken'] as String,
      deviceId: json['deviceId'] as String,
      platform: json['platform'] as String,
    );

Map<String, dynamic> _$RegisterTokenToJson(RegisterToken instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
    };
