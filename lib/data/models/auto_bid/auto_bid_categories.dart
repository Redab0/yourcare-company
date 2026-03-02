import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';

class AutoBidDepartmentOptions {
  final List<CleaningItem> bedrooms;
  final List<CleaningItem> bathrooms;
  final List<CleaningItem> kitchens;
  final List<CleaningItem> livingRooms;
  final List<CleaningItem> sizeOptions;
  final List<CleaningItem> numberOfFloors;

  const AutoBidDepartmentOptions({
    required this.bedrooms,
    required this.bathrooms,
    required this.kitchens,
    required this.livingRooms,
    required this.sizeOptions,
    required this.numberOfFloors,
  });

  factory AutoBidDepartmentOptions.empty() {
    return const AutoBidDepartmentOptions(
      bedrooms: [],
      bathrooms: [],
      kitchens: [],
      livingRooms: [],
      sizeOptions: [],
      numberOfFloors: [],
    );
  }

  factory AutoBidDepartmentOptions.fromJson(Map<String, dynamic> json) {
    return AutoBidDepartmentOptions(
      bedrooms: _parseItems(json['bedrooms']),
      bathrooms: _parseItems(json['bathrooms']),
      kitchens: _parseItems(json['kitchens']),
      livingRooms: _parseItems(json['livingRooms']),
      sizeOptions: _parseItems(json['sizeOptions']),
      numberOfFloors: _parseItems(json['numberOfFloors']),
    );
  }

  static List<CleaningItem> _parseItems(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(CleaningItem.fromJson)
          .toList();
    }
    return [];
  }
}

class AutoBidDepartmentType {
  final String? id;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final double? price;
  final AutoBidDepartmentOptions options;

  const AutoBidDepartmentType({
    this.id,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.price,
    required this.options,
  });

  factory AutoBidDepartmentType.fromJson(Map<String, dynamic> json) {
    return AutoBidDepartmentType(
      id: json['_id'] as String? ?? json['id'] as String?,
      titleEn: json['titleEn'] as String? ?? json['title'] as String?,
      titleAr: json['titleAr'] as String?,
      descriptionEn:
          json['descriptionEn'] as String? ?? json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      options: json['options'] is Map<String, dynamic>
          ? AutoBidDepartmentOptions.fromJson(
              json['options'] as Map<String, dynamic>,
            )
          : AutoBidDepartmentOptions.empty(),
    );
  }
}

class AutoBidDeepCleaningCategories {
  final List<AutoBidDepartmentType> departmentTypes;

  const AutoBidDeepCleaningCategories({
    required this.departmentTypes,
  });

  factory AutoBidDeepCleaningCategories.empty() {
    return const AutoBidDeepCleaningCategories(departmentTypes: []);
  }

  factory AutoBidDeepCleaningCategories.fromJson(Map<String, dynamic> json) {
    final raw = json['departmentType'];
    if (raw is List) {
      return AutoBidDeepCleaningCategories(
        departmentTypes: raw
            .whereType<Map<String, dynamic>>()
            .map(AutoBidDepartmentType.fromJson)
            .toList(),
      );
    }
    return AutoBidDeepCleaningCategories.empty();
  }
}

class AutoBidUpholsteryTypeCategory {
  final String? id;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final List<CleaningItem> sizes;
  final List<CleaningItem> materials;
  final List<CleaningItem> conditions;

  const AutoBidUpholsteryTypeCategory({
    this.id,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.sizes,
    required this.materials,
    required this.conditions,
  });

  factory AutoBidUpholsteryTypeCategory.fromJson(Map<String, dynamic> json) {
    final options = json['options'] as Map<String, dynamic>?;
    return AutoBidUpholsteryTypeCategory(
      id: json['_id'] as String? ?? json['id'] as String?,
      titleEn: json['titleEn'] as String? ?? json['title'] as String?,
      titleAr: json['titleAr'] as String?,
      descriptionEn:
          json['descriptionEn'] as String? ?? json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      sizes: AutoBidDepartmentOptions._parseItems(
          json['sizes'] ?? options?['sizes']),
      materials: AutoBidDepartmentOptions._parseItems(
          json['materials'] ?? options?['materials']),
      conditions: AutoBidDepartmentOptions._parseItems(
          json['conditions'] ?? options?['conditions']),
    );
  }
}

class AutoBidUpholsteryCategories {
  final List<AutoBidUpholsteryTypeCategory> upholsteryTypes;

  const AutoBidUpholsteryCategories({
    required this.upholsteryTypes,
  });

  factory AutoBidUpholsteryCategories.empty() {
    return const AutoBidUpholsteryCategories(upholsteryTypes: []);
  }

  factory AutoBidUpholsteryCategories.fromJson(Map<String, dynamic> json) {
    final raw = json['upholsteryTypes'];
    if (raw is List) {
      return AutoBidUpholsteryCategories(
        upholsteryTypes: raw
            .whereType<Map<String, dynamic>>()
            .map(AutoBidUpholsteryTypeCategory.fromJson)
            .toList(),
      );
    }
    return AutoBidUpholsteryCategories.empty();
  }
}
