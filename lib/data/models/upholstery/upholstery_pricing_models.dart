import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upholstery_pricing_models.g.dart';

@JsonSerializable(includeIfNull: false)
class UpholsteryBusinessCategory extends Equatable {
  final String type;
  final List<UpholsteryType> upholsteryTypes;

  const UpholsteryBusinessCategory({
    this.type = '',
    this.upholsteryTypes = const [],
  });

  factory UpholsteryBusinessCategory.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryBusinessCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$UpholsteryBusinessCategoryToJson(this);

  bool get isUpholsteryCleaning =>
      type.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase() ==
      'upholsterycleaning';

  @override
  List<Object?> get props => [type, upholsteryTypes];
}

@JsonSerializable(includeIfNull: false)
class UpholsteryType extends Equatable {
  @JsonKey(readValue: _readId)
  final String id;
  final String? title;
  final String? titleEn;
  final String? titleAr;
  final String? description;
  final String? descriptionEn;
  final String? descriptionAr;
  final List<UpholsterySize> sizes;

  const UpholsteryType({
    this.id = '',
    this.title,
    this.titleEn,
    this.titleAr,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.sizes = const [],
  });

  factory UpholsteryType.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryTypeFromJson(json);

  Map<String, dynamic> toJson() => _$UpholsteryTypeToJson(this);

  String localizedTitle({required bool isArabic}) {
    final preferred = isArabic ? titleAr : titleEn;
    final fallback = isArabic ? titleEn : titleAr;
    if (preferred?.trim().isNotEmpty ?? false) return preferred!.trim();
    if (title?.trim().isNotEmpty ?? false) return title!.trim();
    if (fallback?.trim().isNotEmpty ?? false) return fallback!.trim();
    return '-';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleEn,
        titleAr,
        description,
        descriptionEn,
        descriptionAr,
        sizes,
      ];
}

@JsonSerializable(includeIfNull: false)
class UpholsterySize extends Equatable {
  @JsonKey(readValue: _readId)
  final String id;
  final String? title;
  final String? titleEn;
  final String? titleAr;
  final String? description;
  final String? descriptionEn;
  final String? descriptionAr;
  final double price;

  const UpholsterySize({
    this.id = '',
    this.title,
    this.titleEn,
    this.titleAr,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.price = 0,
  });

  factory UpholsterySize.fromJson(Map<String, dynamic> json) =>
      _$UpholsterySizeFromJson(json);

  Map<String, dynamic> toJson() => _$UpholsterySizeToJson(this);

  String localizedTitle({required bool isArabic}) {
    final preferred = isArabic ? titleAr : titleEn;
    final fallback = isArabic ? titleEn : titleAr;
    if (preferred?.trim().isNotEmpty ?? false) return preferred!.trim();
    if (title?.trim().isNotEmpty ?? false) return title!.trim();
    if (fallback?.trim().isNotEmpty ?? false) return fallback!.trim();
    return '-';
  }

  String? localizedDescription({required bool isArabic}) {
    final preferred = isArabic ? descriptionAr : descriptionEn;
    final fallback = isArabic ? descriptionEn : descriptionAr;
    if (preferred?.trim().isNotEmpty ?? false) return preferred!.trim();
    if (description?.trim().isNotEmpty ?? false) return description!.trim();
    if (fallback?.trim().isNotEmpty ?? false) return fallback!.trim();
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleEn,
        titleAr,
        description,
        descriptionEn,
        descriptionAr,
        price,
      ];
}

@JsonSerializable(includeIfNull: false)
class UpholsteryPricingPackage extends Equatable {
  @JsonKey(readValue: _readPackageId, includeToJson: false)
  final String? packageId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? sizeId;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final double price;
  final double discountPercentage;

  const UpholsteryPricingPackage({
    this.packageId,
    this.localId = '',
    this.sizeId,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.price = 0,
    this.discountPercentage = 0,
  });

  factory UpholsteryPricingPackage.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryPricingPackageFromJson(json);

  Map<String, dynamic> toJson() => _$UpholsteryPricingPackageToJson(this);

  Map<String, dynamic> toPricingRequestJson() => <String, dynamic>{
        if (titleEn != null) 'titleEn': titleEn!.trim(),
        if (titleAr != null) 'titleAr': titleAr!.trim(),
        if (descriptionEn?.trim().isNotEmpty == true)
          'descriptionEn': descriptionEn!.trim(),
        if (descriptionAr?.trim().isNotEmpty == true)
          'descriptionAr': descriptionAr!.trim(),
        'price': price,
        'discountPercentage': discountPercentage,
      };

  String get rowKey => sizeId ?? packageId ?? localId;

  UpholsteryPricingPackage copyWith({
    String? packageId,
    String? localId,
    String? sizeId,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    double? price,
    double? discountPercentage,
  }) {
    return UpholsteryPricingPackage(
      packageId: packageId ?? this.packageId,
      localId: localId ?? this.localId,
      sizeId: sizeId ?? this.sizeId,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  @override
  List<Object?> get props => [
        packageId,
        localId,
        sizeId,
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        price,
        discountPercentage,
      ];
}

@JsonSerializable(includeIfNull: false)
class UpholsteryPricingGroup extends Equatable {
  @JsonKey(readValue: _readUpholsteryTypeId)
  final String upholsteryTypeId;
  final List<UpholsteryPricingPackage> packages;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isEnabled;

  const UpholsteryPricingGroup({
    required this.upholsteryTypeId,
    this.packages = const [],
    this.isEnabled = true,
  });

  factory UpholsteryPricingGroup.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryPricingGroupFromJson(json);

  Map<String, dynamic> toJson() => _$UpholsteryPricingGroupToJson(this);

  Map<String, dynamic> toPricingRequestJson() => <String, dynamic>{
        'upholsteryTypeId': upholsteryTypeId,
        'packages': packages
            .map((package) => package.toPricingRequestJson())
            .toList(growable: false),
      };

  UpholsteryPricingGroup copyWith({
    String? upholsteryTypeId,
    List<UpholsteryPricingPackage>? packages,
    bool? isEnabled,
  }) {
    return UpholsteryPricingGroup(
      upholsteryTypeId: upholsteryTypeId ?? this.upholsteryTypeId,
      packages: packages ?? this.packages,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [upholsteryTypeId, packages, isEnabled];
}

@JsonSerializable(includeIfNull: false, createToJson: false)
class UpholsteryPricingRequest extends Equatable {
  final List<UpholsteryPricingGroup> pricing;

  const UpholsteryPricingRequest({required this.pricing});

  factory UpholsteryPricingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryPricingRequestFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pricing': pricing
            .map((group) => group.toPricingRequestJson())
            .toList(growable: false),
      };

  @override
  List<Object?> get props => [pricing];
}

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['_id'];
}

Object? _readPackageId(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['id'] ?? json['_id'];
}

Object? _readUpholsteryTypeId(Map<dynamic, dynamic> json, String key) {
  final direct = json[key] ?? json['categoryTypeId'] ?? json['typeId'];
  if (direct != null) return direct;
  final type = json['upholsteryType'];
  if (type is Map) return type['id'] ?? type['_id'];
  return null;
}

List<UpholsteryType> mergeLocalizedUpholsteryTypes(
  List<UpholsteryType> english,
  List<UpholsteryType> arabic,
) {
  final englishById = {for (final type in english) type.id: type};
  final arabicById = {for (final type in arabic) type.id: type};
  final ids = <String>{
    ...english.map((type) => type.id),
    ...arabic.map((type) => type.id),
  }..remove('');

  return ids.map((id) {
    final englishType = englishById[id];
    final arabicType = arabicById[id];
    return UpholsteryType(
      id: id,
      titleEn: _firstText([
        englishType?.titleEn,
        englishType?.title,
        arabicType?.titleEn,
      ]),
      titleAr: _firstText([
        arabicType?.titleAr,
        arabicType?.title,
        englishType?.titleAr,
      ]),
      descriptionEn: _firstText([
        englishType?.descriptionEn,
        englishType?.description,
        arabicType?.descriptionEn,
      ]),
      descriptionAr: _firstText([
        arabicType?.descriptionAr,
        arabicType?.description,
        englishType?.descriptionAr,
      ]),
      sizes: _mergeLocalizedSizes(
        englishType?.sizes ?? const [],
        arabicType?.sizes ?? const [],
      ),
    );
  }).toList(growable: false);
}

List<UpholsterySize> _mergeLocalizedSizes(
  List<UpholsterySize> english,
  List<UpholsterySize> arabic,
) {
  final englishById = {for (final size in english) size.id: size};
  final arabicById = {for (final size in arabic) size.id: size};
  final ids = <String>{
    ...english.map((size) => size.id),
    ...arabic.map((size) => size.id),
  }..remove('');

  return ids.map((id) {
    final englishSize = englishById[id];
    final arabicSize = arabicById[id];
    return UpholsterySize(
      id: id,
      titleEn: _firstText([
        englishSize?.titleEn,
        englishSize?.title,
        arabicSize?.titleEn,
      ]),
      titleAr: _firstText([
        arabicSize?.titleAr,
        arabicSize?.title,
        englishSize?.titleAr,
      ]),
      descriptionEn: _firstText([
        englishSize?.descriptionEn,
        englishSize?.description,
        arabicSize?.descriptionEn,
      ]),
      descriptionAr: _firstText([
        arabicSize?.descriptionAr,
        arabicSize?.description,
        englishSize?.descriptionAr,
      ]),
      price: englishSize?.price ?? arabicSize?.price ?? 0,
    );
  }).toList(growable: false);
}

String? _firstText(List<String?> values) {
  for (final value in values) {
    if (value?.trim().isNotEmpty ?? false) return value!.trim();
  }
  return null;
}
