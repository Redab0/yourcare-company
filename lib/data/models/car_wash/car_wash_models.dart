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

  Map<String, dynamic> toPricingRequestJson() {
    return <String, dynamic>{
      if (titleEn case final value?) 'titleEn': value,
      if (titleAr case final value?) 'titleAr': value,
      if (descriptionEn case final value?) 'descriptionEn': value,
      if (descriptionAr case final value?) 'descriptionAr': value,
      'price': price,
      'discountPercentage': discountPercentage,
    };
  }

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

@JsonSerializable(includeIfNull: false, createFactory: false)
class CarWashPricingGroup extends Equatable {
  final String vehicleTypeId;
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

  Map<String, dynamic> toPricingRequestJson() {
    return <String, dynamic>{
      'vehicleTypeId': vehicleTypeId,
      'packages': packages
          .map((package) => package.toPricingRequestJson())
          .toList(growable: false),
    };
  }

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

@JsonSerializable(includeIfNull: false, createToJson: false)
class CarWashPricingRequest extends Equatable {
  final List<CarWashPricingGroup> pricing;

  const CarWashPricingRequest({required this.pricing});

  factory CarWashPricingRequest.fromJson(Map<String, dynamic> json) =>
      _$CarWashPricingRequestFromJson(json);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pricing': pricing
          .map((group) => group.toPricingRequestJson())
          .toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [pricing];
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

class CarWashPackageWorkingHour extends Equatable {
  final int dayOfWeek;
  final String startTime;
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

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      };

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

class CarWashPackage extends Equatable {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final double discountPercentage;
  final int duration;
  final List<CarWashPackageWorkingHour> workingHours;

  const CarWashPackage({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn = '',
    this.descriptionAr = '',
    required this.price,
    this.discountPercentage = 0,
    this.duration = 0,
    this.workingHours = const [],
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
      price: _asDouble(source['price']),
      discountPercentage: _asDouble(
        source['discountPercentage'] ?? source['discount'],
      ),
      duration: _asInt(source['duration']),
      workingHours: _parsePackageWorkingHours(
        source['workingHours'] ?? source['hours'] ?? source['availability'],
      ),
    );
  }

  CarWashPackageMutationRequest toMutationRequest() {
    return CarWashPackageMutationRequest(
      titleEn: titleEn,
      titleAr: titleAr,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      price: price,
      discountPercentage: discountPercentage,
      duration: duration,
      workingHours: workingHours,
    );
  }

  @override
  List<Object?> get props => [
        id,
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        price,
        discountPercentage,
        duration,
        workingHours,
      ];
}

class CarWashPackageMutationRequest extends Equatable {
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final double discountPercentage;
  final int duration;
  final List<CarWashPackageWorkingHour> workingHours;

  const CarWashPackageMutationRequest({
    required this.titleEn,
    required this.titleAr,
    this.descriptionEn = '',
    this.descriptionAr = '',
    required this.price,
    this.discountPercentage = 0,
    required this.duration,
    this.workingHours = const [],
  });

  Map<String, dynamic> toJson() => {
        'titleEn': titleEn.trim(),
        'titleAr': titleAr.trim(),
        'descriptionEn': descriptionEn.trim(),
        'descriptionAr': descriptionAr.trim(),
        'price': price,
        'discountPercentage': discountPercentage,
        'duration': duration,
        'workingHours': workingHours
            .map((workingHour) => workingHour.toJson())
            .toList(growable: false),
      };

  @override
  List<Object?> get props => [
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
        price,
        discountPercentage,
        duration,
        workingHours,
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

class CarWashPricingAssignmentRequest extends Equatable {
  final List<CarWashVehiclePackageAssignment> pricing;

  const CarWashPricingAssignmentRequest({required this.pricing});

  Map<String, dynamic> toJson({bool useLegacyPackagesKey = false}) => {
        'pricing': pricing
            .map(
              (assignment) => {
                'vehicleTypeId': assignment.vehicleTypeId,
                useLegacyPackagesKey ? 'packages' : 'packageIds':
                    assignment.packageIds,
              },
            )
            .toList(growable: false),
      };

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

class CarWashAreaFeeRequest extends Equatable {
  final String areaId;
  final double fee;

  const CarWashAreaFeeRequest({required this.areaId, required this.fee});

  Map<String, dynamic> toJson() => {'areaId': areaId, 'fee': fee};

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

    void readPackageList(Object? value) {
      if (value is! List) return;
      for (final rawPackage in value) {
        final packageJson = _asStringMap(rawPackage);
        if (packageJson == null || _looksLikePricingGroup(packageJson)) {
          continue;
        }
        final package = CarWashPackage.fromJson(packageJson);
        if (package.id.isNotEmpty) packagesById[package.id] = package;
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
          final package = CarWashPackage.fromJson(packageJson);
          if (package.id.isNotEmpty) {
            packagesById.putIfAbsent(
              package.id,
              () => package,
            );
          }
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
