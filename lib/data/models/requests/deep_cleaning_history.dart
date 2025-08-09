// deep_cleaning_history.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';
import 'package:cleaning_service_driver/data/models/requests/company_information.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cleaning_request.dart';

part 'deep_cleaning_history.g.dart';

@JsonSerializable(checked: true)
class DeepCleaningHistory implements CleaningRequest {
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

  @JsonKey(name: 'DeepCleaning')
  final DeepCleaningDetail detail;

  @JsonKey(name: 'team')
  final TeamModel? assignedTeam;

  @JsonKey(name: 'businessId')
  final CompanyInformation? companyInformation;

  @override
  final RequestStatus requestStatus;

  DeepCleaningHistory({
    this.id,
    required this.requestStatus,
    required this.totalPrice,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.detail,
    required this.scheduledTime,
    required this.customer,
    this.assignedTeam,
    this.companyInformation,
  });

  factory DeepCleaningHistory.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DeepCleaningHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$DeepCleaningHistoryToJson(this);
}

@JsonSerializable(checked: true)
class DeepCleaningDetail {
  final CleaningItem? departmentType;
  final CleaningItem? bedroom;
  final CleaningItem? bathroom;
  final CleaningItem? kitchen;
  final CleaningItem? livingRoom;
  final Address? address;
  final String? additionalInformation;
  final List<String>? photosAndVideos;
  final DateTime? scheduledTime;
  final String? area;

  DeepCleaningDetail(
      {this.departmentType,
      this.bedroom,
      this.bathroom,
      this.kitchen,
      this.livingRoom,
      this.address,
      this.additionalInformation,
      this.photosAndVideos,
      this.scheduledTime,
      this.area});

  factory DeepCleaningDetail.fromJson(Map<String, dynamic> json) =>
      _$DeepCleaningDetailFromJson(json);
  Map<String, dynamic> toJson() => _$DeepCleaningDetailToJson(this);
}
