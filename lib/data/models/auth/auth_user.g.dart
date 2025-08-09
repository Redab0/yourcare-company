// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'phone': instance.phone,
      'profileImage': instance.profileImage,
      'addresses': instance.addresses,
    };
