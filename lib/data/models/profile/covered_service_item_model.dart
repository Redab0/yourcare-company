class CoveredServiceGroup {
  final String serviceType;
  final List<CoveredServiceItem> services;

  const CoveredServiceGroup({
    required this.serviceType,
    required this.services,
  });

  factory CoveredServiceGroup.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    return CoveredServiceGroup(
      serviceType: (json['serviceType'] as String?) ?? '',
      services: rawServices is List
          ? rawServices
              .whereType<Map<String, dynamic>>()
              .map(CoveredServiceItem.fromJson)
              .toList()
          : const [],
    );
  }
}

class CoveredServiceItem {
  final String id;
  final String? titleEn;
  final String? titleAr;
  final bool selected;
  final bool canManage;

  const CoveredServiceItem({
    required this.id,
    this.titleEn,
    this.titleAr,
    required this.selected,
    this.canManage = false,
  });

  factory CoveredServiceItem.fromJson(Map<String, dynamic> json) {
    return CoveredServiceItem(
      id: (json['id'] as String?) ?? '',
      titleEn: json['titleEn'] as String?,
      titleAr: json['titleAr'] as String?,
      selected: json['selected'] as bool? ?? false,
      canManage: json['canManage'] as bool? ?? false,
    );
  }

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
