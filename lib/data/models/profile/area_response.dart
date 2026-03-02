import 'package:json_annotation/json_annotation.dart';

part 'area_response.g.dart';

@JsonSerializable(checked: true)
class AreaResponse {
  final Governorate? title;
  final List<AreaModel>? areas;

  AreaResponse({this.title, this.areas});

  factory AreaResponse.fromJson(Map<String, dynamic> json) =>
      _$AreaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AreaResponseToJson(this);
}

@JsonSerializable(checked: true)
class AreaModel {
  final String? id;
  final String? en;
  final String? ar;
  final String? name;
  final String? areaEn;
  final String? areaAr;
  final String? governorateEn;
  final String? governorateAr;

  AreaModel({
    this.id,
    this.en,
    this.ar,
    this.name,
    this.areaEn,
    this.areaAr,
    this.governorateEn,
    this.governorateAr,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);

  Map<String, dynamic> toJson() => _$AreaModelToJson(this);
}

@JsonSerializable(checked: true)
class Governorate {
  final String? en;
  final String? ar;

  Governorate({this.ar, this.en});

  factory Governorate.fromJson(Map<String, dynamic> json) =>
      _$GovernorateFromJson(json);

  Map<String, dynamic> toJson() => _$GovernorateToJson(this);
}
