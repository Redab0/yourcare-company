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
  final DateTime? scheduledTime;
  @override
  final Customer customer;

  @JsonKey(name: 'DeepCleaning')
  final DeepCleaningDetail detail;

  @JsonKey(name: 'team')
  final TeamModel? assignedTeam;

  @JsonKey(name: 'businessId')
  final CompanyInformation? companyInformation;

  @JsonKey(name: 'serviceFrequencyCount')
  final int? serviceFrequencyCount;

  @JsonKey(name: 'serviceIntervalDays')
  final int? serviceIntervalDays;

  @JsonKey(name: 'frequencyDates')
  final List<FrequencyDate>? frequencyDates;

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
    this.serviceFrequencyCount,
    this.serviceIntervalDays,
    this.frequencyDates,
  });

  DeepCleaningHistory copyWith({
    String? id,
    RequestStatus? requestStatus,
    double? totalPrice,
    String? type,
    DeepCleaningDetail? detail,
    DateTime? scheduledTime,
    TeamModel? assignedTeam,
    Customer? customer,
    CompanyInformation? companyInformation,
    int? serviceFrequencyCount,
    int? serviceIntervalDays,
    List<FrequencyDate>? frequencyDates,
  }) {
    return DeepCleaningHistory(
        id: id ?? this.id,
        requestStatus: requestStatus ?? this.requestStatus,
        totalPrice: totalPrice ?? this.totalPrice,
        createdAt: createdAt,
        updatedAt: updatedAt,
        assignedTeam: assignedTeam ?? this.assignedTeam,
        detail: detail ?? this.detail,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        customer: customer ?? this.customer,
        companyInformation: companyInformation ?? this.companyInformation,
        serviceFrequencyCount:
            serviceFrequencyCount ?? this.serviceFrequencyCount,
        serviceIntervalDays: serviceIntervalDays ?? this.serviceIntervalDays,
        frequencyDates: frequencyDates ?? this.frequencyDates,
        type: type ?? this.type);
  }

  factory DeepCleaningHistory.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DeepCleaningHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$DeepCleaningHistoryToJson(this);
}

@JsonSerializable(checked: true)
class DeepCleaningDetail {
  final DeepCleaningDepartmentSelection? departmentSelection;
  final CleaningItem? departmentType;
  final CleaningItem? bedroom;
  final CleaningItem? bathroom;
  final CleaningItem? kitchen;
  final CleaningItem? livingRoom;
  final CleaningItem? numberOfFloors;
  final Address? address;
  final String? additionalInformation;
  final List<String>? photosAndVideos;
  final DateTime? scheduledTime;
  final String? area;
  final String? areaId;

  DeepCleaningDetail(
      {this.departmentSelection,
      this.departmentType,
      this.bedroom,
      this.bathroom,
      this.kitchen,
      this.livingRoom,
      this.numberOfFloors,
      this.address,
      this.additionalInformation,
      this.photosAndVideos,
      this.scheduledTime,
      this.area,
      this.areaId});

  factory DeepCleaningDetail.fromJson(Map<String, dynamic> json) =>
      _$DeepCleaningDetailFromJson(json);
  Map<String, dynamic> toJson() => _$DeepCleaningDetailToJson(this);
}

@JsonSerializable(checked: true)
class DeepCleaningDepartmentSelection {
  final CleaningItem? departmentType;
  final CleaningItem? bedrooms;
  final CleaningItem? bathrooms;
  final CleaningItem? kitchens;
  final CleaningItem? livingRooms;
  final CleaningItem? numberOfFloors;
  final CleaningItem? sizeOptions;
  final bool? furnitureCheckbox;
  final bool? kitchenCheckbox;
  final bool? bathroomCheckbox;
  final String? additionalInformation;
  final double? calculatedPrice;

  DeepCleaningDepartmentSelection({
    this.departmentType,
    this.bedrooms,
    this.bathrooms,
    this.kitchens,
    this.livingRooms,
    this.numberOfFloors,
    this.sizeOptions,
    this.furnitureCheckbox,
    this.kitchenCheckbox,
    this.bathroomCheckbox,
    this.additionalInformation,
    this.calculatedPrice,
  });

  factory DeepCleaningDepartmentSelection.fromJson(Map<String, dynamic> json) =>
      _$DeepCleaningDepartmentSelectionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DeepCleaningDepartmentSelectionToJson(this);
}

@JsonSerializable(checked: true)
class FrequencyDate {
  final String? id;
  final DateTime? date;
  final String? status;

  FrequencyDate({this.id, this.date, this.status});

  factory FrequencyDate.fromJson(Map<String, dynamic> json) =>
      _$FrequencyDateFromJson(json);
  Map<String, dynamic> toJson() => _$FrequencyDateToJson(this);
}
