// house_cleaning_history.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/assigned_worker.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';
import 'package:cleaning_service_driver/data/models/requests/company_information.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cleaning_request.dart';

part 'house_keeping_history.g.dart';

@JsonSerializable(checked: true)
class HouseKeepingHistory implements CleaningRequest {
  @override
  final String? id;
  @override
  final String? type;
  @override
  final double totalPrice;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime scheduledTime;
  @override
  final Customer customer;

  @override
  final RequestStatus requestStatus;

  @JsonKey(name: 'cleaners')
  final List<AssignedWorker>? assignedWorker;

  @JsonKey(name: 'HouseCleaning')
  final HouseKeepingDetail detail;

  @JsonKey(name: 'businessId')
  final CompanyInformation? companyInformation;

  HouseKeepingHistory({
    this.id,
    required this.requestStatus,
    required this.totalPrice,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.detail,
    required this.scheduledTime,
    this.assignedWorker,
    required this.customer,
    this.companyInformation,
  });

  factory HouseKeepingHistory.fromJson(Map<String, dynamic> json) =>
      _$HouseKeepingHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$HouseKeepingHistoryToJson(this);
}

@JsonSerializable(checked: true)
class HouseKeepingDetail {
  final CleaningItem? numberOfCleaners;
  final CleaningItem? cleaningDuration;
  final CleaningItem? cleaningProducts;
  final CleaningItem? pricePerCleaner;
  final Address? address;
  final DateTime? scheduledTime;
  final String? specialNotes;
  final double? totalPrice;
  final String? area;

  HouseKeepingDetail(
      {this.numberOfCleaners,
      this.cleaningDuration,
      this.cleaningProducts,
      this.pricePerCleaner,
      this.address,
      this.scheduledTime,
      this.specialNotes,
      this.totalPrice,
      this.area});

  factory HouseKeepingDetail.fromJson(Map<String, dynamic> json) =>
      _$HouseKeepingDetailFromJson(json);
  Map<String, dynamic> toJson() => _$HouseKeepingDetailToJson(this);
}
