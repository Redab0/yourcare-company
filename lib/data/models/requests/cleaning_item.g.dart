// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cleaning_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CleaningItem _$CleaningItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CleaningItem',
      json,
      ($checkedConvert) {
        final val = CleaningItem(
          id: $checkedConvert('id', (v) => v as String?),
          price: $checkedConvert('price', (v) => (v as num?)?.toDouble()),
          title: $checkedConvert('title', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          createdAt: $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          updatedAt: $checkedConvert('updatedAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$CleaningItemToJson(CleaningItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
