import 'package:json_annotation/json_annotation.dart';

part 'cleaning_item.g.dart';

@JsonSerializable(checked: true)
class CleaningItem {
  final String? id;
  final double? price;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CleaningItem({
    this.id,
    this.price,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CleaningItem.fromJson(Map<String, dynamic> json) =>
      _$CleaningItemFromJson(json);

  Map<String, dynamic> toJson() => _$CleaningItemToJson(this);
}
