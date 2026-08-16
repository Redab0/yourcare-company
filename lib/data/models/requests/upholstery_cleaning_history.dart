// house_cleaning_history.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/assigned_worker.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer_response.dart';
import 'package:cleaning_service_driver/data/models/requests/company_information.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cleaning_request.dart';

part 'upholstery_cleaning_history.g.dart';

@JsonSerializable(checked: true)
class UpholsteryCleaningHistory implements CleaningRequest {
  @override
  final String? id;
  @override
  final String type;
  @override
  final RequestStatus requestStatus;
  @override
  final double totalPrice;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final Customer customer;
  @override
  final DateTime? scheduledTime;
  @override
  final double? extraFees;
  @override
  final String? extraFeesDescription;
  @override
  @JsonKey(defaultValue: false)
  final bool awaitingExtraPayment;
  @override
  final String? extraPaymentUrl;

  @JsonKey(name: 'businessId')
  final CompanyInformation? companyInformation;
  @JsonKey(name: 'cleaners')
  final List<AssignedWorker>? assignedWorker;

  @JsonKey(name: 'frequencyDates')
  final List<FrequentRequestModel>? subRequests;

  @JsonKey(name: 'UpholsteryCleaning')
  final UpholsteryCleaningDetails upholsteryCleaning;
  final BusinessOfferResponse? myBid;

  UpholsteryCleaningHistory({
    this.id,
    required this.customer,
    required this.requestStatus,
    required this.totalPrice,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.upholsteryCleaning,
    required this.scheduledTime,
    this.companyInformation,
    this.assignedWorker,
    this.subRequests,
    this.myBid,
    this.extraFees,
    this.extraFeesDescription,
    this.awaitingExtraPayment = false,
    this.extraPaymentUrl,
  });

  factory UpholsteryCleaningHistory.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningHistoryFromJson(_normalizeUpholsteryHistory(json));
  Map<String, dynamic> toJson() => _$UpholsteryCleaningHistoryToJson(this);

  @override
  UpholsteryCleaningHistory copyWithExtraInvoice({
    required double extraFees,
    required String extraFeesDescription,
    required bool awaitingExtraPayment,
    String? extraPaymentUrl,
  }) {
    return UpholsteryCleaningHistory(
      id: id,
      customer: customer,
      requestStatus: requestStatus,
      totalPrice: totalPrice,
      type: type,
      createdAt: createdAt,
      updatedAt: updatedAt,
      upholsteryCleaning: upholsteryCleaning,
      scheduledTime: scheduledTime,
      companyInformation: companyInformation,
      assignedWorker: assignedWorker,
      subRequests: subRequests,
      myBid: myBid,
      extraFees: extraFees,
      extraFeesDescription: extraFeesDescription,
      awaitingExtraPayment: awaitingExtraPayment,
      extraPaymentUrl: extraPaymentUrl ?? this.extraPaymentUrl,
    );
  }
}

@JsonSerializable(checked: true)
class UpholsteryCleaningDetails {
  final Address? address;
  final String? addressId;
  final String? areaId;
  final String? specialNotes;
  final DateTime? scheduledTime;
  final List<UpholsteryCleaningItems>? items;

  const UpholsteryCleaningDetails(
      {this.items,
      this.address,
      this.addressId,
      this.areaId,
      this.specialNotes,
      this.scheduledTime});

  factory UpholsteryCleaningDetails.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UpholsteryCleaningDetailsToJson(this);
}

@JsonSerializable(checked: true)
class UpholsteryCleaningItems {
  final int? quantity;
  final double? calculatedPrice;
  @JsonKey(fromJson: _parseCleaningItemType)
  final CleaningItemType? type;
  @JsonKey(fromJson: _parseCleaningItemSize)
  final CleaningItemSize? size;
  @JsonKey(fromJson: _parseCleaningItemMaterial)
  final CleaningItemMaterial? material;
  @JsonKey(fromJson: _parseCleaningItemCondition)
  final CleaningItemCondition? condition;
  final List<String>? mediaUrls;
  final String? additionalInformation;
  final String? upholsteryTypeId;
  final String? packageId;
  final UpholsteryCleaningPackage? package;
  final double? price;

  const UpholsteryCleaningItems({
    this.quantity,
    this.calculatedPrice,
    this.type,
    this.size,
    this.material,
    this.condition,
    this.mediaUrls,
    this.additionalInformation,
    this.upholsteryTypeId,
    this.packageId,
    this.package,
    this.price,
  });

  factory UpholsteryCleaningItems.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningItemsFromJson(_normalizeUpholsteryItem(json));
  Map<String, dynamic> toJson() => _$UpholsteryCleaningItemsToJson(this);

  bool get isDirectBookingItem =>
      package != null || (packageId?.isNotEmpty ?? false);
}

@JsonSerializable(checked: true)
class UpholsteryCleaningPackage {
  final String? packageId;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final double? price;
  final double? discountPercentage;

  const UpholsteryCleaningPackage({
    this.packageId,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    this.price,
    this.discountPercentage,
  });

  factory UpholsteryCleaningPackage.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningPackageFromJson(json);
  Map<String, dynamic> toJson() => _$UpholsteryCleaningPackageToJson(this);

  String? localizedTitle({required bool isArabic}) {
    final values = isArabic ? [titleAr, titleEn] : [titleEn, titleAr];
    for (final value in values) {
      if (value?.trim().isNotEmpty == true) return value!.trim();
    }
    return null;
  }

  double? get discountedPrice {
    final amount = price;
    if (amount == null) return null;
    final discount = (discountPercentage ?? 0).clamp(0, 100);
    return amount * (1 - discount / 100);
  }
}

Map<String, dynamic> _normalizeUpholsteryHistory(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  if (normalized['businessId'] is String) normalized['businessId'] = null;

  final details = _upholsteryMap(
        normalized['UpholsteryCleaning'] ??
            normalized['upholsteryCleaning'] ??
            normalized['detail'],
      ) ??
      <String, dynamic>{};
  final normalizedDetails = Map<String, dynamic>.from(details);
  normalizedDetails['items'] = _upholsteryList(details['items'])
      .map(_upholsteryMap)
      .whereType<Map<String, dynamic>>()
      .map(_normalizeUpholsteryItem)
      .toList(growable: false);
  final directNotes = normalizedDetails['specialNotes']?.toString();
  if (directNotes == null || directNotes.trim().isEmpty) {
    normalizedDetails['specialNotes'] =
        normalizedDetails['additionalInformation'] ??
            normalized['specialNotes'] ??
            normalized['additionalInformation'];
  }

  final addressId = _upholsteryStringOrNull(normalizedDetails['addressId']);
  if (_upholsteryMap(normalizedDetails['address']) == null &&
      addressId != null) {
    final customer = _upholsteryMap(normalized['customer']);
    for (final rawAddress in _upholsteryList(customer?['addresses'])) {
      final address = _upholsteryMap(rawAddress);
      if (_upholsteryStringOrNull(address?['id'] ?? address?['_id']) ==
          addressId) {
        normalizedDetails['address'] = address;
        break;
      }
    }
  }

  normalized['UpholsteryCleaning'] = normalizedDetails;
  normalized['scheduledTime'] ??= normalizedDetails['scheduledTime'];
  normalized['totalPrice'] = _upholsteryDouble(
        normalized['totalPrice'] ?? normalizedDetails['totalPrice'],
      ) ??
      0;
  return normalized;
}

Map<String, dynamic> _normalizeUpholsteryItem(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  final rawType = _upholsteryMap(
    normalized['type'] ??
        normalized['upholsteryType'] ??
        normalized['upholsteryTypeId'],
  );
  final typeId = _upholsteryStringOrNull(
    rawType?['id'] ??
        rawType?['_id'] ??
        normalized['upholsteryTypeId'] ??
        normalized['typeId'] ??
        (normalized['type'] is String ? normalized['type'] : null),
  );
  if (rawType != null) {
    normalized['type'] = {
      ...rawType,
      'id': _upholsteryStringOrNull(rawType['id'] ?? rawType['_id'] ?? typeId),
    };
  } else if (typeId != null) {
    normalized['type'] = {
      'id': typeId,
      'titleEn': normalized['typeTitleEn'],
      'titleAr': normalized['typeTitleAr'],
      'title': normalized['typeTitle'],
    };
  }
  normalized['upholsteryTypeId'] = typeId;

  final rawPackage =
      _upholsteryMap(normalized['package'] ?? normalized['packageId']);
  final packageId = _upholsteryStringOrNull(
    rawPackage?['packageId'] ??
        rawPackage?['id'] ??
        rawPackage?['_id'] ??
        (normalized['packageId'] is String ? normalized['packageId'] : null),
  );
  if (rawPackage != null) {
    normalized['package'] = {
      ...rawPackage,
      'packageId': packageId,
      'price': rawPackage['price'] ?? normalized['price'],
    };
  } else if (packageId != null) {
    normalized['package'] = {
      'packageId': packageId,
      'titleEn': normalized['packageTitleEn'],
      'titleAr': normalized['packageTitleAr'],
      'descriptionEn': normalized['packageDescriptionEn'],
      'descriptionAr': normalized['packageDescriptionAr'],
      'price': normalized['price'],
      'discountPercentage': normalized['discountPercentage'],
    };
  }
  normalized['packageId'] = packageId;
  normalized['price'] = _upholsteryDouble(
    normalized['price'] ??
        rawPackage?['price'] ??
        normalized['calculatedPrice'],
  );
  return normalized;
}

List<Object?> _upholsteryList(Object? value) =>
    value is List ? value : const [];

Map<String, dynamic>? _upholsteryMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _upholsteryStringOrNull(Object? value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

double? _upholsteryDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

CleaningItemType? _parseCleaningItemType(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return CleaningItemType.fromJson(v);
  if (v is String) {
    return CleaningItemType(v, null, null, null, null, null, null);
  }
  return null;
}

CleaningItemSize? _parseCleaningItemSize(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return CleaningItemSize.fromJson(v);
  if (v is String) return CleaningItemSize(v, null, null);
  return null;
}

CleaningItemMaterial? _parseCleaningItemMaterial(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return CleaningItemMaterial.fromJson(v);
  if (v is String) return CleaningItemMaterial(v, null, null);
  return null;
}

CleaningItemCondition? _parseCleaningItemCondition(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return CleaningItemCondition.fromJson(v);
  if (v is String) return CleaningItemCondition(v, v, '');
  return null;
}

@JsonSerializable()
class FrequentRequestModel {
  String? id;
  DateTime? date;
  RequestStatus? status;

  FrequentRequestModel(
    this.status,
    this.id,
    this.date,
  );

  factory FrequentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FrequentRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$FrequentRequestModelToJson(this);
}

@JsonSerializable()
class CleaningItemType {
  final String? id;
  final String? titleEn;
  final String? titleAr;
  final String? title;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? description;

  const CleaningItemType(this.id, this.titleEn, this.titleAr, this.title,
      this.descriptionEn, this.descriptionAr, this.description);

  factory CleaningItemType.fromJson(Map<String, dynamic> json) =>
      _$CleaningItemTypeFromJson(json);
  Map<String, dynamic> toJson() => _$CleaningItemTypeToJson(this);
}

@JsonSerializable()
class CleaningItemSize {
  final String? id;
  final String? title;
  final String? description;

  const CleaningItemSize(this.id, this.title, this.description);

  factory CleaningItemSize.fromJson(Map<String, dynamic> json) =>
      _$CleaningItemSizeFromJson(json);
  Map<String, dynamic> toJson() => _$CleaningItemSizeToJson(this);
}

@JsonSerializable()
class CleaningItemMaterial {
  final String? id;
  final String? title;
  final String? description;

  const CleaningItemMaterial(this.id, this.title, this.description);

  factory CleaningItemMaterial.fromJson(Map<String, dynamic> json) =>
      _$CleaningItemMaterialFromJson(json);
  Map<String, dynamic> toJson() => _$CleaningItemMaterialToJson(this);
}

@JsonSerializable()
class CleaningItemCondition {
  final String id;
  final String title;
  final String description;

  const CleaningItemCondition(this.id, this.title, this.description);

  factory CleaningItemCondition.fromJson(Map<String, dynamic> json) =>
      _$CleaningItemConditionFromJson(json);
  Map<String, dynamic> toJson() => _$CleaningItemConditionToJson(this);
}
