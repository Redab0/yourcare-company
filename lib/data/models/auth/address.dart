import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable(includeIfNull: false, checked: true)
class Address {
  final String? id;
  final double? latitude;
  final double? longitude;
  final String? areaId;
  final String? area;
  final String? street;
  final String? building;
  final String? avenue;
  final String? block;
  final String? name;
  final String? floor;
  final String? apartment;
  final bool? isDefault;

  Address({
    this.latitude,
    this.longitude,
    this.areaId,
    this.area,
    this.street,
    this.building,
    this.avenue,
    this.block,
    this.name,
    this.id,
    this.isDefault,
    this.floor,
    this.apartment,
  });

  Address copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? areaId,
    String? area,
    String? street,
    String? building,
    String? avenue,
    String? block,
    String? name,
    bool? isDefault,
    String? floor,
    String? apartment,
  }) {
    return Address(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaId: areaId ?? this.areaId,
      street: street ?? this.street,
      building: building ?? this.building,
      avenue: avenue ?? this.avenue,
      block: block ?? this.block,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      area: area ?? this.area,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
