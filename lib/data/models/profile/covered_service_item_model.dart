import 'package:json_annotation/json_annotation.dart';

part 'covered_service_item_model.g.dart';

@JsonSerializable()
class CoveredServiceGroup {
  final String serviceType;
  final List<CoveredServiceItem> services;

  const CoveredServiceGroup({
    required this.serviceType,
    required this.services,
  });

  factory CoveredServiceGroup.fromJson(Map<String, dynamic> json) =>
      _$CoveredServiceGroupFromJson(json);

  Map<String, dynamic> toJson() => _$CoveredServiceGroupToJson(this);
}

@JsonSerializable()
class CoveredServiceItem {
  final String id;
  final String? titleEn;
  final String? titleAr;
  @JsonKey(defaultValue: false)
  final bool selected;
  @JsonKey(defaultValue: false)
  final bool canManage;

  const CoveredServiceItem({
    required this.id,
    this.titleEn,
    this.titleAr,
    required this.selected,
    this.canManage = false,
  });

  factory CoveredServiceItem.fromJson(Map<String, dynamic> json) =>
      _$CoveredServiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$CoveredServiceItemToJson(this);

  CoveredServiceItem copyWith({
    String? id,
    String? titleEn,
    String? titleAr,
    bool? selected,
    bool? canManage,
  }) {
    return CoveredServiceItem(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      selected: selected ?? this.selected,
      canManage: canManage ?? this.canManage,
    );
  }
}
