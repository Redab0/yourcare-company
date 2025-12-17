// house_cleaning_history.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/assigned_worker.dart';
import 'package:cleaning_service_driver/data/models/requests/company_information.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cleaning_request.dart';

part 'upholstery_cleaning_history.g.dart';

@JsonSerializable(checked: true)
class UpholsteryCleaningHistory implements CleaningRequest {
  @override
  final String id;
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
  final DateTime scheduledTime;

  @JsonKey(name: 'businessId')
  final CompanyInformation? companyInformation;
  @JsonKey(name: 'cleaners')
  final List<AssignedWorker>? assignedWorker;

  @JsonKey(name: 'frequencyDates')
  final List<FrequentRequestModel>? subRequests;

  @JsonKey(name: 'UpholsteryCleaning')
  final UpholsteryCleaningDetails upholsteryCleaning;

  UpholsteryCleaningHistory({
    required this.id,
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
  });

  factory UpholsteryCleaningHistory.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$UpholsteryCleaningHistoryToJson(this);
}

@JsonSerializable(checked: true)
class UpholsteryCleaningDetails {
  final List<UpholsteryCleaningItems>? items;

  const UpholsteryCleaningDetails(this.items);

  factory UpholsteryCleaningDetails.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UpholsteryCleaningDetailsToJson(this);
}

@JsonSerializable(checked: true)
class UpholsteryCleaningItems {
  final int? quantity;
  final double? calculatedPrice;
  final CleaningItemType? type;
  final CleaningItemSize? size;
  final CleaningItemMaterial? material;
  final CleaningItemCondition? condition;
  final List<String>? mediaUrls;

  UpholsteryCleaningItems(this.quantity, this.calculatedPrice, this.type,
      this.size, this.material, this.condition, this.mediaUrls);

  factory UpholsteryCleaningItems.fromJson(Map<String, dynamic> json) =>
      _$UpholsteryCleaningItemsFromJson(json);
  Map<String, dynamic> toJson() => _$UpholsteryCleaningItemsToJson(this);
}

CleaningItemType? _parseCleaningItemType(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return CleaningItemType.fromJson(v);
  if (v is String) return CleaningItemType(v, null, null, null, null, null, null);
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
