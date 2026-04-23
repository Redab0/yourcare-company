import 'package:cleaning_service_driver/data/models/profile/area_response.dart';

class HousekeepingAreaFee {
  final String? areaId;
  final AreaModel? area;
  final double? fee;

  const HousekeepingAreaFee({
    this.areaId,
    this.area,
    this.fee,
  });

  factory HousekeepingAreaFee.fromJson(Map<String, dynamic> json) {
    final rawArea = json['areaId'];
    if (rawArea is Map<String, dynamic>) {
      final area = AreaModel.fromJson(rawArea);
      return HousekeepingAreaFee(
        areaId: area.id,
        area: area,
        fee: (json['fee'] as num?)?.toDouble(),
      );
    }
    return HousekeepingAreaFee(
      areaId: rawArea as String?,
      fee: (json['fee'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final id = areaId ?? area?.id;
    return {
      if (id != null) 'areaId': id,
      if (fee != null) 'fee': fee,
    };
  }
}

class HousekeepingPricingOption {
  final String optionId;
  final double price;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? logo;

  const HousekeepingPricingOption({
    required this.optionId,
    required this.price,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.logo,
  });

  factory HousekeepingPricingOption.fromJson(Map<String, dynamic> json) {
    return HousekeepingPricingOption(
      optionId: json['optionId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      titleAr: json['titleAr']?.toString(),
      titleEn: json['titleEn']?.toString(),
      descriptionAr: json['descriptionAr']?.toString(),
      descriptionEn: json['descriptionEn']?.toString(),
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optionId': optionId,
      'price': price,
    };
  }

  HousekeepingPricingOption copyWith({
    String? optionId,
    double? price,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? logo,
  }) {
    return HousekeepingPricingOption(
      optionId: optionId ?? this.optionId,
      price: price ?? this.price,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      logo: logo ?? this.logo,
    );
  }
}

class HousekeepingSinglePricingModel {
  final bool isActive;
  final double basePricePerCleanerPerHour;

  const HousekeepingSinglePricingModel({
    required this.isActive,
    required this.basePricePerCleanerPerHour,
  });

  factory HousekeepingSinglePricingModel.fromJson(Map<String, dynamic> json) {
    return HousekeepingSinglePricingModel(
      isActive: json['isActive'] as bool? ?? false,
      basePricePerCleanerPerHour:
          (json['basePricePerCleanerPerHour'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'basePricePerCleanerPerHour': basePricePerCleanerPerHour,
    };
  }
}

class HousekeepingMultiplePricingModel {
  final bool isActive;
  final List<HousekeepingPricingOption> options;

  const HousekeepingMultiplePricingModel({
    required this.isActive,
    required this.options,
  });

  factory HousekeepingMultiplePricingModel.fromJson(Map<String, dynamic> json) {
    return HousekeepingMultiplePricingModel(
      isActive: json['isActive'] as bool? ?? false,
      options: (json['options'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(HousekeepingPricingOption.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class HousekeepingPricing {
  final List<HousekeepingAreaFee>? areaFees;
  final bool? isActive;
  final double? cleaningProductsPrice;
  final HousekeepingSinglePricingModel? singlePricingModel;
  final HousekeepingMultiplePricingModel? multiplePricingModel;

  const HousekeepingPricing({
    this.areaFees,
    this.isActive,
    this.cleaningProductsPrice,
    this.singlePricingModel,
    this.multiplePricingModel,
  });

  factory HousekeepingPricing.fromJson(Map<String, dynamic> json) {
    return HousekeepingPricing(
      areaFees: (json['areaFees'] as List<dynamic>?)
          ?.map((e) => HousekeepingAreaFee.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool?,
      cleaningProductsPrice: (json['cleaningProductsPrice'] as num?)?.toDouble(),
      singlePricingModel: _parseSinglePricingModel(json),
      multiplePricingModel: _parseMultiplePricingModel(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (areaFees != null) 'areaFees': areaFees!.map((e) => e.toJson()).toList(),
      if (isActive != null) 'isActive': isActive,
      if (cleaningProductsPrice != null)
        'cleaningProductsPrice': cleaningProductsPrice,
      if (singlePricingModel != null) 'singlePricingModel': singlePricingModel!.toJson(),
      if (multiplePricingModel != null)
        'multiplePricingModel': multiplePricingModel!.toJson(),
    };
  }
}

class HousekeepingPricingRequest {
  final List<HousekeepingAreaFee> areaFees;
  final bool isActive;
  final double cleaningProductsPrice;
  final HousekeepingSinglePricingModel singlePricingModel;
  final HousekeepingMultiplePricingModel multiplePricingModel;

  const HousekeepingPricingRequest({
    required this.areaFees,
    required this.isActive,
    required this.cleaningProductsPrice,
    required this.singlePricingModel,
    required this.multiplePricingModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'areaFees': areaFees.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'cleaningProductsPrice': cleaningProductsPrice,
      'singlePricingModel': singlePricingModel.toJson(),
      'multiplePricingModel': multiplePricingModel.toJson(),
    };
  }
}

class HousekeepingAreaFeeRequest {
  final String areaId;
  final double fee;

  const HousekeepingAreaFeeRequest({
    required this.areaId,
    required this.fee,
  });

  Map<String, dynamic> toJson() {
    return {
      'areaId': areaId,
      'fee': fee,
    };
  }
}

HousekeepingSinglePricingModel? _parseSinglePricingModel(
  Map<String, dynamic> json,
) {
  final raw = json['singlePricingModel'];
  if (raw is Map<String, dynamic>) {
    return HousekeepingSinglePricingModel.fromJson(raw);
  }

  // Backward-compatible fallback
  final legacyBase = (json['basePricePerCleanerPerHour'] as num?)?.toDouble();
  final legacyActive = json['isActive'] as bool?;
  if (legacyBase != null || legacyActive != null) {
    return HousekeepingSinglePricingModel(
      isActive: legacyActive ?? false,
      basePricePerCleanerPerHour: legacyBase ?? 0,
    );
  }
  return null;
}

HousekeepingMultiplePricingModel? _parseMultiplePricingModel(
  Map<String, dynamic> json,
) {
  final raw = json['multiplePricingModel'];
  if (raw is Map<String, dynamic>) {
    return HousekeepingMultiplePricingModel.fromJson(raw);
  }
  return null;
}
