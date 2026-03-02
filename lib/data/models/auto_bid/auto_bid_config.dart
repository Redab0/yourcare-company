class AutoBidOption {
  final String? categoryOptionId;
  final double? price;
  final int? expectedTimeInDays;
  final String? titleEn;
  final String? titleAr;

  const AutoBidOption({
    this.categoryOptionId,
    this.price,
    this.expectedTimeInDays,
    this.titleEn,
    this.titleAr,
  });

  factory AutoBidOption.fromJson(Map<String, dynamic> json) {
    return AutoBidOption(
      categoryOptionId: json['categoryOptionId'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      expectedTimeInDays: (json['expectedTimeInDays'] as num?)?.toInt(),
      titleEn: json['titleEn'] as String? ?? json['title'] as String?,
      titleAr: json['titleAr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (categoryOptionId != null) 'categoryOptionId': categoryOptionId,
      if (price != null) 'price': price,
      if (expectedTimeInDays != null) 'expectedTimeInDays': expectedTimeInDays,
    };
  }

  AutoBidOption copyWith({
    double? price,
    int? expectedTimeInDays,
  }) {
    return AutoBidOption(
      categoryOptionId: categoryOptionId,
      price: price ?? this.price,
      expectedTimeInDays: expectedTimeInDays ?? this.expectedTimeInDays,
      titleEn: titleEn,
      titleAr: titleAr,
    );
  }
}

class AutoBidDeepCleaningPricing {
  final List<AutoBidOption> departmentTypes;
  final List<AutoBidOption> bedrooms;
  final List<AutoBidOption> bathrooms;
  final List<AutoBidOption> kitchens;
  final List<AutoBidOption> livingRooms;
  final List<AutoBidOption> numberOfFloors;
  final List<AutoBidOption> sizeOptions;

  const AutoBidDeepCleaningPricing({
    required this.departmentTypes,
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.livingRooms,
    required this.numberOfFloors,
    required this.sizeOptions,
  });

  factory AutoBidDeepCleaningPricing.empty() {
    return const AutoBidDeepCleaningPricing(
      departmentTypes: [],
      bedrooms: [],
      bathrooms: [],
      kitchens: [],
      livingRooms: [],
      numberOfFloors: [],
      sizeOptions: [],
    );
  }

  factory AutoBidDeepCleaningPricing.fromJson(Map<String, dynamic> json) {
    return AutoBidDeepCleaningPricing(
      departmentTypes: _parseOptions(json['departmentTypes']),
      bedrooms: _parseOptions(json['bedrooms']),
      bathrooms: _parseOptions(json['bathrooms']),
      kitchens: _parseOptions(json['kitchens']),
      livingRooms: _parseOptions(json['livingRooms']),
      numberOfFloors: _parseOptions(json['numberOfFloors']),
      sizeOptions: _parseOptions(json['sizeOptions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentTypes': departmentTypes.map((e) => e.toJson()).toList(),
      'bedrooms': bedrooms.map((e) => e.toJson()).toList(),
      'bathrooms': bathrooms.map((e) => e.toJson()).toList(),
      'kitchens': kitchens.map((e) => e.toJson()).toList(),
      'livingRooms': livingRooms.map((e) => e.toJson()).toList(),
      'numberOfFloors': numberOfFloors.map((e) => e.toJson()).toList(),
      'sizeOptions': sizeOptions.map((e) => e.toJson()).toList(),
    };
  }

  AutoBidDeepCleaningPricing copyWith({
    List<AutoBidOption>? departmentTypes,
    List<AutoBidOption>? bedrooms,
    List<AutoBidOption>? bathrooms,
    List<AutoBidOption>? kitchens,
    List<AutoBidOption>? livingRooms,
    List<AutoBidOption>? numberOfFloors,
    List<AutoBidOption>? sizeOptions,
  }) {
    return AutoBidDeepCleaningPricing(
      departmentTypes: departmentTypes ?? this.departmentTypes,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      kitchens: kitchens ?? this.kitchens,
      livingRooms: livingRooms ?? this.livingRooms,
      numberOfFloors: numberOfFloors ?? this.numberOfFloors,
      sizeOptions: sizeOptions ?? this.sizeOptions,
    );
  }

  static List<AutoBidOption> _parseOptions(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AutoBidOption.fromJson)
          .toList();
    }
    return [];
  }
}

class AutoBidTypeOverride {
  final String? categoryTypeId;
  final String? titleEn;
  final String? titleAr;
  final List<AutoBidOption> sizes;
  final List<AutoBidOption> materials;
  final List<AutoBidOption> conditions;

  const AutoBidTypeOverride({
    required this.categoryTypeId,
    this.titleEn,
    this.titleAr,
    required this.sizes,
    required this.materials,
    required this.conditions,
  });

  factory AutoBidTypeOverride.empty() {
    return const AutoBidTypeOverride(
      categoryTypeId: null,
      sizes: [],
      materials: [],
      conditions: [],
    );
  }

  factory AutoBidTypeOverride.fromJson(Map<String, dynamic> json) {
    return AutoBidTypeOverride(
      categoryTypeId: json['categoryTypeId'] as String?,
      titleEn: json['titleEn'] as String? ?? json['title'] as String?,
      titleAr: json['titleAr'] as String?,
      sizes: AutoBidDeepCleaningPricing._parseOptions(json['sizes']),
      materials: AutoBidDeepCleaningPricing._parseOptions(json['materials']),
      conditions: AutoBidDeepCleaningPricing._parseOptions(json['conditions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (categoryTypeId != null) 'categoryTypeId': categoryTypeId,
      'sizes': sizes.map((e) => e.toJson()).toList(),
      'materials': materials.map((e) => e.toJson()).toList(),
      'conditions': conditions.map((e) => e.toJson()).toList(),
    };
  }

  AutoBidTypeOverride copyWith({
    List<AutoBidOption>? sizes,
    List<AutoBidOption>? materials,
    List<AutoBidOption>? conditions,
  }) {
    return AutoBidTypeOverride(
      categoryTypeId: categoryTypeId,
      titleEn: titleEn,
      titleAr: titleAr,
      sizes: sizes ?? this.sizes,
      materials: materials ?? this.materials,
      conditions: conditions ?? this.conditions,
    );
  }
}

class AutoBidUpholsteryPricing {
  final List<AutoBidTypeOverride> typeOverrides;

  const AutoBidUpholsteryPricing({
    required this.typeOverrides,
  });

  factory AutoBidUpholsteryPricing.empty() {
    return const AutoBidUpholsteryPricing(typeOverrides: []);
  }

  factory AutoBidUpholsteryPricing.fromJson(Map<String, dynamic> json) {
    final raw = json['typeOverrides'];
    if (raw is List) {
      return AutoBidUpholsteryPricing(
        typeOverrides: raw
            .whereType<Map<String, dynamic>>()
            .map(AutoBidTypeOverride.fromJson)
            .toList(),
      );
    }
    return AutoBidUpholsteryPricing.empty();
  }

  Map<String, dynamic> toJson() {
    return {
      'typeOverrides': typeOverrides.map((e) => e.toJson()).toList(),
    };
  }

  AutoBidUpholsteryPricing copyWith({
    List<AutoBidTypeOverride>? typeOverrides,
  }) {
    return AutoBidUpholsteryPricing(
      typeOverrides: typeOverrides ?? this.typeOverrides,
    );
  }
}

class AutoBidConfig {
  final String? id;
  final String? serviceType;
  final String? businessId;
  final bool? isEnabled;
  final AutoBidDeepCleaningPricing? deepCleaningPricing;
  final AutoBidUpholsteryPricing? upholsteryPricing;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AutoBidConfig({
    this.id,
    this.serviceType,
    this.businessId,
    this.isEnabled,
    this.deepCleaningPricing,
    this.upholsteryPricing,
    this.createdAt,
    this.updatedAt,
  });

  factory AutoBidConfig.fromJson(Map<String, dynamic> json) {
    return AutoBidConfig(
      id: json['_id'] as String? ?? json['id'] as String?,
      serviceType: json['serviceType'] as String?,
      businessId: json['businessId'] as String?,
      isEnabled: json['isEnabled'] as bool?,
      deepCleaningPricing: json['deepCleaningPricing'] is Map<String, dynamic>
          ? AutoBidDeepCleaningPricing.fromJson(
              json['deepCleaningPricing'] as Map<String, dynamic>,
            )
          : null,
      upholsteryPricing: json['upholsteryPricing'] is Map<String, dynamic>
          ? AutoBidUpholsteryPricing.fromJson(
              json['upholsteryPricing'] as Map<String, dynamic>,
            )
          : null,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class AutoBidConfigRequest {
  final String serviceType;
  final bool isEnabled;
  final AutoBidDeepCleaningPricing? deepCleaningPricing;
  final AutoBidUpholsteryPricing? upholsteryPricing;

  const AutoBidConfigRequest({
    required this.serviceType,
    required this.isEnabled,
    this.deepCleaningPricing,
    this.upholsteryPricing,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'isEnabled': isEnabled,
      if (deepCleaningPricing != null)
        'deepCleaningPricing': deepCleaningPricing!.toJson(),
      if (upholsteryPricing != null)
        'upholsteryPricing': upholsteryPricing!.toJson(),
    };
  }
}
