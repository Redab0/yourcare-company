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

class HousekeepingPricing {
  final double? basePricePerCleanerPerHour;
  final List<HousekeepingAreaFee>? areaFees;
  final bool? isActive;

  const HousekeepingPricing({
    this.basePricePerCleanerPerHour,
    this.areaFees,
    this.isActive,
  });

  factory HousekeepingPricing.fromJson(Map<String, dynamic> json) {
    return HousekeepingPricing(
      basePricePerCleanerPerHour:
          (json['basePricePerCleanerPerHour'] as num?)?.toDouble(),
      areaFees: (json['areaFees'] as List<dynamic>?)
          ?.map((e) => HousekeepingAreaFee.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (basePricePerCleanerPerHour != null)
        'basePricePerCleanerPerHour': basePricePerCleanerPerHour,
      if (areaFees != null)
        'areaFees': areaFees!.map((e) => e.toJson()).toList(),
      if (isActive != null) 'isActive': isActive,
    };
  }

  HousekeepingPricing copyWith({
    double? basePricePerCleanerPerHour,
    List<HousekeepingAreaFee>? areaFees,
    bool? isActive,
  }) {
    return HousekeepingPricing(
      basePricePerCleanerPerHour:
          basePricePerCleanerPerHour ?? this.basePricePerCleanerPerHour,
      areaFees: areaFees ?? this.areaFees,
      isActive: isActive ?? this.isActive,
    );
  }
}

class HousekeepingPricingRequest {
  final double basePricePerCleanerPerHour;
  final List<HousekeepingAreaFee> areaFees;
  final bool isActive;

  const HousekeepingPricingRequest({
    required this.basePricePerCleanerPerHour,
    required this.areaFees,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'basePricePerCleanerPerHour': basePricePerCleanerPerHour,
      'areaFees': areaFees.map((e) => e.toJson()).toList(),
      'isActive': isActive,
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
