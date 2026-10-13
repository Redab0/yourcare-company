import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'car_wash_models.g.dart';

@JsonSerializable(includeIfNull: false)
class CarWashCategoryResponse extends Equatable {
  final List<CarWashVehicleType> vehicleTypes;

  const CarWashCategoryResponse({
    this.vehicleTypes = const [],
  });

  factory CarWashCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CarWashCategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CarWashCategoryResponseToJson(this);

  @override
  List<Object?> get props => [vehicleTypes];
}

@JsonSerializable(includeIfNull: false)
class CarWashVehicleType extends Equatable {
  @JsonKey(readValue: _readId)
  final String id;
  final String? titleEn;
  final String? titleAr;
  final List<CarWashSizeOption> sizes;

  const CarWashVehicleType({
    this.id = '',
    this.titleEn,
    this.titleAr,
    this.sizes = const [],
  });

  factory CarWashVehicleType.fromJson(Map<String, dynamic> json) =>
      _$CarWashVehicleTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CarWashVehicleTypeToJson(this);

  @override
  List<Object?> get props => [id, titleEn, titleAr, sizes];
}

@JsonSerializable(includeIfNull: false)
class CarWashSizeOption extends Equatable {
  @JsonKey(readValue: _readId)
  final String id;
  final String? titleEn;
  final String? titleAr;

  const CarWashSizeOption({
    this.id = '',
    this.titleEn,
    this.titleAr,
  });

  factory CarWashSizeOption.fromJson(Map<String, dynamic> json) =>
      _$CarWashSizeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$CarWashSizeOptionToJson(this);

  @override
  List<Object?> get props => [id, titleEn, titleAr];
}

@JsonSerializable(includeIfNull: false)
class CarWashPricingPackage extends Equatable {
  @JsonKey(readValue: _readPackageId, includeToJson: false)
  final String? packageId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String localId;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final double price;
  final double discountPercentage;

  const CarWashPricingPackage({
    this.packageId,
    this.localId = '',
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.price = 0,
    this.discountPercentage = 0,
  });

  factory CarWashPricingPackage.fromJson(Map<String, dynamic> json) =>
      _$CarWashPricingPackageFromJson(json);

  Map<String, dynamic> toJson() => _$CarWashPricingPackageToJson(this);

  String get rowKey => packageId ?? localId;

  CarWashPricingPackage copyWith({
    String? packageId,
    String? localId,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    double? price,
    double? discountPercentage,
  }) {
    return CarWashPricingPackage(
      packageId: packageId ?? this.packageId,
      localId: localId ?? this.localId,
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
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        price,
        discountPercentage,
      ];
}

@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
  ignoreUnannotated: true,
)
class CarWashPricingGroup extends Equatable {
  @JsonKey()
  final String vehicleTypeId;
  @JsonKey()
  final List<CarWashPricingPackage> packages;

  const CarWashPricingGroup({
    required this.vehicleTypeId,
    this.packages = const [],
  });

  factory CarWashPricingGroup.fromJson(Map<String, dynamic> json) {
    final rawPackages = json['packages'];
    return CarWashPricingGroup(
      vehicleTypeId: (json['vehicleTypeId'] ??
              json['vehicleType'] ??
              json['categoryTypeId'] ??
              '')
          .toString(),
      packages: rawPackages is List
          ? rawPackages.map((rawPackage) {
              if (rawPackage is Map<String, dynamic>) {
                return CarWashPricingPackage.fromJson(rawPackage);
              }
              return CarWashPricingPackage(
                packageId: rawPackage?.toString(),
              );
            }).toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() => _$CarWashPricingGroupToJson(this);

  CarWashPricingGroup copyWith({
    String? vehicleTypeId,
    List<CarWashPricingPackage>? packages,
  }) {
    return CarWashPricingGroup(
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      packages: packages ?? this.packages,
    );
  }

  @override
  List<Object?> get props => [vehicleTypeId, packages];
}

class CarWashPackagesResponse extends Equatable {
  final List<CarWashPricingGroup> pricing;

  const CarWashPackagesResponse({this.pricing = const []});

  factory CarWashPackagesResponse.fromJson(Object? json) {
    if (json is List) {
      return CarWashPackagesResponse(
        pricing: json
            .whereType<Map<String, dynamic>>()
            .map(CarWashPricingGroup.fromJson)
            .toList(growable: false),
      );
    }
    if (json is Map<String, dynamic>) {
      final value = json['pricing'] ??
          json['carWashPricing'] ??
          json['packages'] ??
          json['data'];
      if (value is List) {
        return CarWashPackagesResponse(
          pricing: value
              .whereType<Map<String, dynamic>>()
              .map(CarWashPricingGroup.fromJson)
              .toList(growable: false),
        );
      }
    }
    return const CarWashPackagesResponse();
  }

  @override
  List<Object?> get props => [pricing];
}

@JsonSerializable(includeIfNull: false)
class CarWashWorkingHour extends Equatable {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const CarWashWorkingHour({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory CarWashWorkingHour.fromJson(Map<String, dynamic> json) =>
      _$CarWashWorkingHourFromJson(json);

  Map<String, dynamic> toJson() => _$CarWashWorkingHourToJson(this);

  CarWashWorkingHour copyWith({
    int? dayOfWeek,
    String? startTime,
    String? endTime,
  }) {
    return CarWashWorkingHour(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime];
}

@JsonSerializable(includeIfNull: false)
class CarWashWorkingHoursRequest extends Equatable {
  final List<CarWashWorkingHour> hours;

  const CarWashWorkingHoursRequest({required this.hours});

  factory CarWashWorkingHoursRequest.fromJson(Map<String, dynamic> json) =>
      _$CarWashWorkingHoursRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CarWashWorkingHoursRequestToJson(this);

  @override
  List<Object?> get props => [hours];
}

@JsonSerializable(createFactory: false, ignoreUnannotated: true)
class CarWashPackageWorkingHour extends Equatable {
  @JsonKey()
  final int dayOfWeek;
  @JsonKey()
  final String startTime;
  @JsonKey()
  final String endTime;

  const CarWashPackageWorkingHour({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory CarWashPackageWorkingHour.fromJson(
    Map<String, dynamic> json, {
    int? inheritedDayOfWeek,
  }) {
    return CarWashPackageWorkingHour(
      dayOfWeek: _asInt(
        json['dayOfWeek'] ?? json['day'] ?? inheritedDayOfWeek,
      ),
      startTime: (json['startTime'] ?? json['start'] ?? '').toString(),
      endTime: (json['endTime'] ?? json['end'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => _$CarWashPackageWorkingHourToJson(this);

  CarWashPackageWorkingHour copyWith({
    int? dayOfWeek,
    String? startTime,
    String? endTime,
  }) {
    return CarWashPackageWorkingHour(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime];
}

@JsonSerializable(createFactory: false, ignoreUnannotated: true)
class CarWashPackageVehiclePrice extends Equatable {
  @JsonKey()
  final String vehicleTypeId;
  @JsonKey()
  final double price;

  const CarWashPackageVehiclePrice({
    required this.vehicleTypeId,
    required this.price,
  });

  factory CarWashPackageVehiclePrice.fromJson(Map<String, dynamic> json) {
    return CarWashPackageVehiclePrice(
      vehicleTypeId: _readStringId(
        json['vehicleTypeId'] ??
            json['vehicleTypeID'] ??
            json['vehicleType'] ??
            json['categoryTypeId'],
      ),
      price: _asDouble(json['price'] ?? json['resolvedPrice']),
    );
  }

  Map<String, dynamic> toJson() => _$CarWashPackageVehiclePriceToJson(this);

  @override
  List<Object?> get props => [vehicleTypeId, price];
}

class CarWashPackage extends Equatable {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final double legacyPrice;
  final double discountPercentage;
  final int duration;
  final List<CarWashPackageWorkingHour> workingHours;
  final List<CarWashPackageVehiclePrice> pricing;
  final bool enabled;

  const CarWashPackage({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.legacyPrice = 0,
    this.discountPercentage = 0,
    this.duration = 0,
    this.workingHours = const [],
    this.pricing = const [],
    this.enabled = true,
  });

  factory CarWashPackage.fromJson(Map<String, dynamic> json) {
    final nested = _asStringMap(json['package']);
    final source = nested == null ? json : {...nested, ...json};
    return CarWashPackage(
      id: _readStringId(
        source['packageId'] ?? source['id'] ?? source['_id'],
      ),
      titleEn: (source['titleEn'] ?? source['title'] ?? '').toString(),
      titleAr: (source['titleAr'] ?? source['title'] ?? '').toString(),
      descriptionEn:
          (source['descriptionEn'] ?? source['description'] ?? '').toString(),
      descriptionAr:
          (source['descriptionAr'] ?? source['description'] ?? '').toString(),
      legacyPrice: _asDouble(source['price']),
      discountPercentage: _asDouble(
        source['discountPercentage'] ?? source['discount'],
      ),
      duration: _asInt(source['duration']),
      workingHours: _parsePackageWorkingHours(
        source['workingHours'] ?? source['hours'] ?? source['availability'],
      ),
      pricing: _parsePackageVehiclePricing(
        source['pricing'] ?? source['vehiclePricing'] ?? source['prices'],
      ),
      enabled: _asBool(source['enabled'], fallback: true),
    );
  }

  double? priceForVehicle(String vehicleTypeId) {
    for (final vehiclePrice in pricing) {
      if (vehiclePrice.vehicleTypeId == vehicleTypeId) {
        return vehiclePrice.price;
      }
    }
    return pricing.isEmpty && legacyPrice > 0 ? legacyPrice : null;
  }

  CarWashPackage withVehiclePrice(String vehicleTypeId, double vehiclePrice) {
    if (vehicleTypeId.isEmpty) return this;
    final pricesByVehicle = {
      for (final entry in pricing) entry.vehicleTypeId: entry,
      vehicleTypeId: CarWashPackageVehiclePrice(
        vehicleTypeId: vehicleTypeId,
        price: vehiclePrice,
      ),
    };
    return CarWashPackage(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      legacyPrice: legacyPrice,
      discountPercentage: discountPercentage,
      duration: duration,
      workingHours: workingHours,
      pricing: pricesByVehicle.values.toList(growable: false),
      enabled: enabled,
    );
  }

  CarWashPackageMutationRequest toMutationRequest({bool? enabled}) {
    return CarWashPackageMutationRequest(
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      pricing: pricing,
      discountPercentage: discountPercentage,
      duration: duration,
      workingHours: workingHours,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        legacyPrice,
        discountPercentage,
        duration,
        workingHours,
        pricing,
        enabled,
      ];
}

@JsonSerializable(
  createFactory: false,
  includeIfNull: false,
  explicitToJson: true,
  ignoreUnannotated: true,
)
class CarWashPackageMutationRequest extends Equatable {
  @JsonKey(toJson: _trimRequestText)
  final String titleEn;
  @JsonKey(toJson: _trimRequestText)
  final String titleAr;
  @JsonKey(toJson: _trimRequestText)
  final String descriptionEn;
  @JsonKey(toJson: _trimRequestText)
  final String descriptionAr;
  @JsonKey()
  final List<CarWashPackageVehiclePrice> pricing;
  @JsonKey()
  final double discountPercentage;
  @JsonKey()
  final int duration;
  @JsonKey()
  final List<CarWashPackageWorkingHour> workingHours;
  @JsonKey()
  final bool enabled;

  const CarWashPackageMutationRequest({
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn = '',
    this.descriptionAr = '',
    required this.pricing,
    this.discountPercentage = 0,
    required this.duration,
    this.workingHours = const [],
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => _$CarWashPackageMutationRequestToJson(this);

  @override
  List<Object?> get props => [
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        pricing,
        discountPercentage,
        duration,
        workingHours,
        enabled,
      ];
}

class CarWashVehiclePackageAssignment extends Equatable {
  final String vehicleTypeId;
  final List<String> packageIds;

  const CarWashVehiclePackageAssignment({
    required this.vehicleTypeId,
    this.packageIds = const [],
  });

  factory CarWashVehiclePackageAssignment.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawPackages = json['packageIds'] ??
        json['packages'] ??
        json['resolvedPackages'] ??
        const [];
    return CarWashVehiclePackageAssignment(
      vehicleTypeId: _readStringId(
        json['vehicleTypeId'] ?? json['vehicleType'] ?? json['categoryTypeId'],
      ),
      packageIds: rawPackages is List
          ? rawPackages
              .map(_packageIdFromAssignmentValue)
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList(growable: false)
          : const [],
    );
  }

  CarWashVehiclePackageAssignment copyWith({
    String? vehicleTypeId,
    List<String>? packageIds,
  }) {
    return CarWashVehiclePackageAssignment(
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      packageIds: packageIds ?? this.packageIds,
    );
  }

  @override
  List<Object?> get props => [vehicleTypeId, packageIds];
}

@JsonSerializable(createFactory: false, ignoreUnannotated: true)
class CarWashPricingPackageReferenceRequest extends Equatable {
  @JsonKey()
  final String packageId;

  const CarWashPricingPackageReferenceRequest({required this.packageId});

  Map<String, dynamic> toJson() =>
      _$CarWashPricingPackageReferenceRequestToJson(this);

  @override
  List<Object?> get props => [packageId];
}

@JsonSerializable(
  createFactory: false,
  explicitToJson: true,
  ignoreUnannotated: true,
)
class CarWashPricingEntryRequest extends Equatable {
  @JsonKey()
  final String vehicleTypeId;
  @JsonKey()
  final List<CarWashPricingPackageReferenceRequest> packages;

  const CarWashPricingEntryRequest({
    required this.vehicleTypeId,
    required this.packages,
  });

  factory CarWashPricingEntryRequest.fromAssignment(
    CarWashVehiclePackageAssignment assignment,
  ) {
    return CarWashPricingEntryRequest(
      vehicleTypeId: assignment.vehicleTypeId,
      packages: assignment.packageIds
          .map(
            (packageId) => CarWashPricingPackageReferenceRequest(
              packageId: packageId,
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => _$CarWashPricingEntryRequestToJson(this);

  @override
  List<Object?> get props => [vehicleTypeId, packages];
}

@JsonSerializable(
  createFactory: false,
  explicitToJson: true,
  ignoreUnannotated: true,
)
class CarWashPricingAssignmentRequest extends Equatable {
  @JsonKey()
  final List<CarWashPricingEntryRequest> pricing;

  factory CarWashPricingAssignmentRequest({
    required List<CarWashVehiclePackageAssignment> pricing,
  }) {
    return CarWashPricingAssignmentRequest._(
      pricing: pricing
          .map(CarWashPricingEntryRequest.fromAssignment)
          .toList(growable: false),
    );
  }

  const CarWashPricingAssignmentRequest._({required this.pricing});

  Map<String, dynamic> toJson() =>
      _$CarWashPricingAssignmentRequestToJson(this);

  @override
  List<Object?> get props => [pricing];
}

class CarWashAreaFee extends Equatable {
  final String areaId;
  final double fee;

  const CarWashAreaFee({required this.areaId, required this.fee});

  factory CarWashAreaFee.fromJson(Map<String, dynamic> json) {
    return CarWashAreaFee(
      areaId: _readStringId(json['areaId'] ?? json['area']),
      fee: _asDouble(json['fee']),
    );
  }

  @override
  List<Object?> get props => [areaId, fee];
}

@JsonSerializable(createFactory: false, ignoreUnannotated: true)
class CarWashAreaFeeRequest extends Equatable {
  @JsonKey()
  final String areaId;
  @JsonKey()
  final double fee;

  const CarWashAreaFeeRequest({required this.areaId, required this.fee});

  Map<String, dynamic> toJson() => _$CarWashAreaFeeRequestToJson(this);

  @override
  List<Object?> get props => [areaId, fee];
}

class CarWashPackagesConfiguration extends Equatable {
  final List<CarWashPackage> packages;
  final List<CarWashVehiclePackageAssignment> assignments;
  final List<CarWashAreaFee> areaFees;

  const CarWashPackagesConfiguration({
    this.packages = const [],
    this.assignments = const [],
    this.areaFees = const [],
  });

  factory CarWashPackagesConfiguration.fromJson(Object? rawJson) {
    final json = _unwrapConfigurationJson(rawJson);
    final packagesById = <String, CarWashPackage>{};
    final assignments = <CarWashVehiclePackageAssignment>[];

    void keepPackage(CarWashPackage package) {
      if (package.id.isEmpty) return;
      final existing = packagesById[package.id];
      packagesById[package.id] =
          existing == null ? package : _mergeCarWashPackages(existing, package);
    }

    void readPackageList(Object? value) {
      if (value is! List) return;
      for (final rawPackage in value) {
        final packageJson = _asStringMap(rawPackage);
        if (packageJson == null || _looksLikePricingGroup(packageJson)) {
          continue;
        }
        final package = CarWashPackage.fromJson(packageJson);
        keepPackage(package);
      }
    }

    void readPricingList(Object? value) {
      if (value is! List) return;
      for (final rawGroup in value) {
        final groupJson = _asStringMap(rawGroup);
        if (groupJson == null) continue;
        final assignment = CarWashVehiclePackageAssignment.fromJson(groupJson);
        if (assignment.vehicleTypeId.isNotEmpty) assignments.add(assignment);

        final rawPackages = groupJson['resolvedPackages'] ??
            groupJson['packages'] ??
            groupJson['packageIds'];
        if (rawPackages is! List) continue;
        for (final rawPackage in rawPackages) {
          final packageJson = _asStringMap(rawPackage);
          if (packageJson == null) continue;
          var package = CarWashPackage.fromJson(packageJson);
          if (assignment.vehicleTypeId.isNotEmpty && package.legacyPrice > 0) {
            package = package.withVehiclePrice(
              assignment.vehicleTypeId,
              package.legacyPrice,
            );
          }
          keepPackage(package);
        }
      }
    }

    if (json is List) {
      final containsGroups = json
          .map(_asStringMap)
          .whereType<Map<String, dynamic>>()
          .any(_looksLikePricingGroup);
      if (containsGroups) {
        readPricingList(json);
      } else {
        readPackageList(json);
      }
    } else if (json is Map<String, dynamic>) {
      final rawPackages = json['packages'] ??
          json['carWashPackages'] ??
          json['standalonePackages'];
      if (rawPackages is List &&
          rawPackages
              .map(_asStringMap)
              .whereType<Map<String, dynamic>>()
              .any(_looksLikePricingGroup)) {
        readPricingList(rawPackages);
      } else {
        readPackageList(rawPackages);
      }
      readPricingList(
        json['pricing'] ??
            json['resolvedPricing'] ??
            json['vehiclePricing'] ??
            json['assignments'],
      );
    }

    final areaFees = <CarWashAreaFee>[];
    if (json is Map<String, dynamic>) {
      final rawAreaFees = json['areaFees'] ?? json['deliveryFees'];
      if (rawAreaFees is List) {
        for (final rawFee in rawAreaFees) {
          final feeJson = _asStringMap(rawFee);
          if (feeJson == null) continue;
          final fee = CarWashAreaFee.fromJson(feeJson);
          if (fee.areaId.isNotEmpty) areaFees.add(fee);
        }
      }
    }

    return CarWashPackagesConfiguration(
      packages: packagesById.values.toList(growable: false),
      assignments: _mergeDuplicateAssignments(assignments),
      areaFees: areaFees,
    );
  }

  @override
  List<Object?> get props => [packages, assignments, areaFees];
}

Object? _readId(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['_id'] ?? json['optionId'];
}

String _trimRequestText(String value) => value.trim();

Object? _readPackageId(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['id'] ?? json['_id'] ?? json['optionId'];
}

List<CarWashPackageWorkingHour> _parsePackageWorkingHours(Object? rawHours) {
  if (rawHours is! List) return const [];
  final result = <CarWashPackageWorkingHour>[];
  for (final rawHour in rawHours) {
    final hourJson = _asStringMap(rawHour);
    if (hourJson == null) continue;
    final rawSlots = hourJson['slots'];
    if (rawSlots is List) {
      final day = _asInt(hourJson['dayOfWeek'] ?? hourJson['day']);
      for (final rawSlot in rawSlots) {
        final slotJson = _asStringMap(rawSlot);
        if (slotJson == null) continue;
        result.add(CarWashPackageWorkingHour.fromJson(
          slotJson,
          inheritedDayOfWeek: day,
        ));
      }
    } else {
      result.add(CarWashPackageWorkingHour.fromJson(hourJson));
    }
  }
  return result;
}

List<CarWashPackageVehiclePrice> _parsePackageVehiclePricing(
  Object? rawPricing,
) {
  if (rawPricing is! List) return const [];
  final pricesByVehicle = <String, CarWashPackageVehiclePrice>{};
  for (final rawPrice in rawPricing) {
    final priceJson = _asStringMap(rawPrice);
    if (priceJson == null) continue;
    final vehiclePrice = CarWashPackageVehiclePrice.fromJson(priceJson);
    if (vehiclePrice.vehicleTypeId.isNotEmpty) {
      pricesByVehicle[vehiclePrice.vehicleTypeId] = vehiclePrice;
    }
  }
  return pricesByVehicle.values.toList(growable: false);
}

CarWashPackage _mergeCarWashPackages(
  CarWashPackage existing,
  CarWashPackage incoming,
) {
  final pricesByVehicle = <String, CarWashPackageVehiclePrice>{
    for (final entry in incoming.pricing) entry.vehicleTypeId: entry,
    for (final entry in existing.pricing) entry.vehicleTypeId: entry,
  };
  return CarWashPackage(
    id: existing.id,
    titleEn: existing.titleEn.isNotEmpty ? existing.titleEn : incoming.titleEn,
    titleAr: existing.titleAr.isNotEmpty ? existing.titleAr : incoming.titleAr,
    descriptionEn: existing.descriptionEn.isNotEmpty
        ? existing.descriptionEn
        : incoming.descriptionEn,
    descriptionAr: existing.descriptionAr.isNotEmpty
        ? existing.descriptionAr
        : incoming.descriptionAr,
    legacyPrice:
        existing.legacyPrice > 0 ? existing.legacyPrice : incoming.legacyPrice,
    discountPercentage: existing.discountPercentage > 0
        ? existing.discountPercentage
        : incoming.discountPercentage,
    duration: existing.duration > 0 ? existing.duration : incoming.duration,
    workingHours: existing.workingHours.isNotEmpty
        ? existing.workingHours
        : incoming.workingHours,
    pricing: pricesByVehicle.values.toList(growable: false),
    enabled: existing.enabled,
  );
}

bool _asBool(Object? value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
    }
  }
  return fallback;
}

Object? _unwrapConfigurationJson(Object? rawJson) {
  var current = rawJson;
  for (var depth = 0; depth < 3; depth++) {
    if (current is! Map<String, dynamic>) break;
    final hasConfigurationFields = current.containsKey('packages') ||
        current.containsKey('carWashPackages') ||
        current.containsKey('standalonePackages') ||
        current.containsKey('pricing') ||
        current.containsKey('resolvedPricing') ||
        current.containsKey('vehiclePricing') ||
        current.containsKey('assignments') ||
        current.containsKey('areaFees') ||
        current.containsKey('deliveryFees');
    if (hasConfigurationFields || !current.containsKey('data')) break;
    current = current['data'];
  }
  return current;
}

bool _looksLikePricingGroup(Map<String, dynamic> json) {
  return json.containsKey('vehicleTypeId') ||
      json.containsKey('vehicleType') ||
      json.containsKey('categoryTypeId');
}

List<CarWashVehiclePackageAssignment> _mergeDuplicateAssignments(
  List<CarWashVehiclePackageAssignment> assignments,
) {
  final packageIdsByVehicle = <String, Set<String>>{};
  for (final assignment in assignments) {
    packageIdsByVehicle
        .putIfAbsent(assignment.vehicleTypeId, () => <String>{})
        .addAll(assignment.packageIds);
  }
  return packageIdsByVehicle.entries
      .map(
        (entry) => CarWashVehiclePackageAssignment(
          vehicleTypeId: entry.key,
          packageIds: entry.value.toList(growable: false),
        ),
      )
      .toList(growable: false);
}

String _packageIdFromAssignmentValue(Object? value) {
  final map = _asStringMap(value);
  if (map != null) {
    final nestedPackage = _asStringMap(map['package']);
    return _readStringId(
      map['packageId'] ??
          map['id'] ??
          map['_id'] ??
          nestedPackage?['packageId'] ??
          nestedPackage?['id'] ??
          nestedPackage?['_id'],
    );
  }
  return _readStringId(value);
}

String _readStringId(Object? value) {
  final map = _asStringMap(value);
  if (map != null) {
    return _readStringId(map['id'] ?? map['_id'] ?? map['areaId']);
  }
  return value?.toString() ?? '';
}

Map<String, dynamic>? _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
