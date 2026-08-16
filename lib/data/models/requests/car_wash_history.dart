import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/company_information.dart';

import 'cleaning_request.dart';

class CarWashHistory implements CleaningRequest {
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

  final CompanyInformation? companyInformation;
  final CarWashHistoryDetail? detail;
  @override
  final double? extraFees;
  @override
  final String? extraFeesDescription;
  @override
  final bool awaitingExtraPayment;
  @override
  final String? extraPaymentUrl;

  const CarWashHistory({
    this.id,
    this.type = 'carWash',
    required this.requestStatus,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    this.scheduledTime,
    this.companyInformation,
    this.detail,
    this.extraFees,
    this.extraFeesDescription,
    this.awaitingExtraPayment = false,
    this.extraPaymentUrl,
  });

  factory CarWashHistory.fromJson(Map<String, dynamic> json) {
    final detailJson = _asMap(json['CarWash'] ?? json['carWash']);
    final detail =
        detailJson == null ? null : CarWashHistoryDetail.fromJson(detailJson);
    final customerJson = _asMap(json['customer']);
    final rawCustomer = json['customer'];
    final companyJson = _asMap(json['businessId']);

    return CarWashHistory(
      id: _readId(json['id'] ?? json['_id'] ?? json['readableId']),
      type: (json['type'] ?? 'carWash').toString(),
      requestStatus: requestStatusFromJson(json['requestStatus']?.toString()),
      totalPrice: _asDouble(json['totalPrice']),
      createdAt: _requiredDate(json['createdAt'], 'createdAt'),
      updatedAt: _requiredDate(json['updatedAt'], 'updatedAt'),
      customer: customerJson != null
          ? Customer.fromJson(customerJson)
          : Customer(id: rawCustomer is String ? rawCustomer : null),
      scheduledTime: _asDate(json['scheduledTime']) ?? detail?.scheduledTime,
      companyInformation:
          companyJson == null ? null : CompanyInformation.fromJson(companyJson),
      detail: detail,
      extraFees: _asNullableDouble(json['extraFees']),
      extraFeesDescription: _nonEmptyString(json['extraFeesDescription']),
      awaitingExtraPayment: _asBool(json['awaitingExtraPayment']),
      extraPaymentUrl: _nonEmptyString(json['extraPaymentUrl']),
    );
  }

  CarWashHistory copyWith({
    RequestStatus? requestStatus,
    double? totalPrice,
    DateTime? updatedAt,
    DateTime? scheduledTime,
    CarWashHistoryDetail? detail,
    double? extraFees,
    String? extraFeesDescription,
    bool? awaitingExtraPayment,
    String? extraPaymentUrl,
  }) {
    return CarWashHistory(
      id: id,
      type: type,
      requestStatus: requestStatus ?? this.requestStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      companyInformation: companyInformation,
      detail: detail ?? this.detail,
      extraFees: extraFees ?? this.extraFees,
      extraFeesDescription: extraFeesDescription ?? this.extraFeesDescription,
      awaitingExtraPayment: awaitingExtraPayment ?? this.awaitingExtraPayment,
      extraPaymentUrl: extraPaymentUrl ?? this.extraPaymentUrl,
    );
  }

  @override
  CarWashHistory copyWithExtraInvoice({
    required double extraFees,
    required String extraFeesDescription,
    required bool awaitingExtraPayment,
    String? extraPaymentUrl,
  }) =>
      copyWith(
        extraFees: extraFees,
        extraFeesDescription: extraFeesDescription,
        awaitingExtraPayment: awaitingExtraPayment,
        extraPaymentUrl: extraPaymentUrl,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (id != null) 'id': id,
        'type': type,
        'requestStatus': requestStatusToJson(requestStatus),
        'totalPrice': totalPrice,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'customer': customer.toJson(),
        if (scheduledTime != null)
          'scheduledTime': scheduledTime!.toIso8601String(),
        if (companyInformation != null)
          'businessId': companyInformation!.toJson(),
        if (detail != null) 'CarWash': detail!.toJson(),
        if (extraFees != null) 'extraFees': extraFees,
        if (extraFeesDescription != null)
          'extraFeesDescription': extraFeesDescription,
        'awaitingExtraPayment': awaitingExtraPayment,
        if (extraPaymentUrl != null) 'extraPaymentUrl': extraPaymentUrl,
      };
}

class CarWashHistoryDetail {
  final List<CarWashHistoryVehicle> vehicles;
  final String? addressId;
  final String? areaId;
  final Address? address;
  final DateTime? scheduledTime;
  final double? totalPrice;
  final String? specialNotes;

  const CarWashHistoryDetail({
    this.vehicles = const [],
    this.addressId,
    this.areaId,
    this.address,
    this.scheduledTime,
    this.totalPrice,
    this.specialNotes,
  });

  factory CarWashHistoryDetail.fromJson(Map<String, dynamic> json) {
    final rawVehicles = json['vehicles'];
    final addressJson = _asMap(json['address']);
    final addressIdJson = _asMap(json['addressId']);

    return CarWashHistoryDetail(
      vehicles: rawVehicles is List
          ? rawVehicles
              .whereType<Map>()
              .map((item) => CarWashHistoryVehicle.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList(growable: false)
          : const [],
      addressId: _readId(json['addressId']),
      areaId: _readId(json['areaId']),
      address: addressJson != null
          ? Address.fromJson(addressJson)
          : addressIdJson != null
              ? Address.fromJson(addressIdJson)
              : null,
      scheduledTime: _asDate(json['scheduledTime']),
      totalPrice: _asNullableDouble(json['totalPrice']),
      specialNotes: _nonEmptyString(
        json['specialNotes'] ?? json['additionalInformation'],
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vehicles': vehicles.map((vehicle) => vehicle.toJson()).toList(),
        if (addressId != null) 'addressId': addressId,
        if (areaId != null) 'areaId': areaId,
        if (address != null) 'address': address!.toJson(),
        if (scheduledTime != null)
          'scheduledTime': scheduledTime!.toIso8601String(),
        if (totalPrice != null) 'totalPrice': totalPrice,
        if (specialNotes != null) 'specialNotes': specialNotes,
      };
}

class CarWashHistoryVehicle {
  final String vehicleTypeId;
  final String packageId;
  final double price;
  final String? vehicleTitleEn;
  final String? vehicleTitleAr;
  final String? packageTitleEn;
  final String? packageTitleAr;
  final String? packageDescriptionEn;
  final String? packageDescriptionAr;

  const CarWashHistoryVehicle({
    this.vehicleTypeId = '',
    this.packageId = '',
    this.price = 0,
    this.vehicleTitleEn,
    this.vehicleTitleAr,
    this.packageTitleEn,
    this.packageTitleAr,
    this.packageDescriptionEn,
    this.packageDescriptionAr,
  });

  factory CarWashHistoryVehicle.fromJson(Map<String, dynamic> json) {
    final vehicleJson = _asMap(
      json['vehicleTypeId'] ?? json['vehicleType'],
    );
    final packageJson = _asMap(json['packageId'] ?? json['package']);

    return CarWashHistoryVehicle(
      vehicleTypeId: _readId(
            json['vehicleTypeId'] ?? json['vehicleType'],
          ) ??
          '',
      packageId: _readId(json['packageId'] ?? json['package']) ?? '',
      price: _asDouble(json['price'] ?? packageJson?['price']),
      vehicleTitleEn: _nonEmptyString(
        vehicleJson?['titleEn'] ??
            json['vehicleTypeTitleEn'] ??
            json['vehicleTitleEn'],
      ),
      vehicleTitleAr: _nonEmptyString(
        vehicleJson?['titleAr'] ??
            json['vehicleTypeTitleAr'] ??
            json['vehicleTitleAr'],
      ),
      packageTitleEn: _nonEmptyString(
        packageJson?['titleEn'] ?? json['titleEn'] ?? json['packageTitleEn'],
      ),
      packageTitleAr: _nonEmptyString(
        packageJson?['titleAr'] ?? json['titleAr'] ?? json['packageTitleAr'],
      ),
      packageDescriptionEn: _nonEmptyString(
        packageJson?['descriptionEn'] ??
            json['descriptionEn'] ??
            json['packageDescriptionEn'],
      ),
      packageDescriptionAr: _nonEmptyString(
        packageJson?['descriptionAr'] ??
            json['descriptionAr'] ??
            json['packageDescriptionAr'],
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vehicleTypeId': vehicleTypeId,
        'packageId': packageId,
        'price': price,
        if (vehicleTitleEn != null) 'vehicleTitleEn': vehicleTitleEn,
        if (vehicleTitleAr != null) 'vehicleTitleAr': vehicleTitleAr,
        if (packageTitleEn != null) 'packageTitleEn': packageTitleEn,
        if (packageTitleAr != null) 'packageTitleAr': packageTitleAr,
        if (packageDescriptionEn != null)
          'packageDescriptionEn': packageDescriptionEn,
        if (packageDescriptionAr != null)
          'packageDescriptionAr': packageDescriptionAr,
      };
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _readId(Object? value) {
  final map = _asMap(value);
  final raw = map == null
      ? value
      : map['id'] ?? map['_id'] ?? map['packageId'] ?? map['vehicleTypeId'];
  final id = raw?.toString().trim();
  return id == null || id.isEmpty ? null : id;
}

String? _nonEmptyString(Object? value) {
  final result = value?.toString().trim();
  return result == null || result.isEmpty ? null : result;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

DateTime? _asDate(Object? value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

DateTime _requiredDate(Object? value, String field) {
  final date = _asDate(value);
  if (date != null) return date;
  throw FormatException('Invalid or missing $field');
}
