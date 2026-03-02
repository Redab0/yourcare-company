import 'package:json_annotation/json_annotation.dart';

part 'cleaning_item.g.dart';

@JsonSerializable(checked: true)
class CleaningItem {
  final String? id;
  final double? price;
  final String? title;
  final String? description;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CleaningItem({
    this.id,
    this.price,
    this.title,
    this.description,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.createdAt,
    this.updatedAt,
  });

  factory CleaningItem.fromJson(Map<String, dynamic> json) =>
      _$CleaningItemFromJson(json);

  Map<String, dynamic> toJson() => _$CleaningItemToJson(this);
}
