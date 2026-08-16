// cleaning_request.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';

import 'deep_cleaning_history.dart';
import 'house_keeping_history.dart';

/// A sealed base for either kind of request
abstract class CleaningRequest {
  String? get id;
  String? get type;
  RequestStatus get requestStatus;
  double get totalPrice;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get scheduledTime;
  Customer get customer;
  double? get extraFees;
  String? get extraFeesDescription;
  bool get awaitingExtraPayment;
  String? get extraPaymentUrl;

  CleaningRequest copyWithExtraInvoice({
    required double extraFees,
    required String extraFeesDescription,
    required bool awaitingExtraPayment,
    String? extraPaymentUrl,
  });

  /// Factory constructor does the “discriminator” logic
  factory CleaningRequest.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['type'] == null) {
      if (normalized.containsKey('DeepCleaning')) {
        normalized['type'] = 'deepCleaning';
      } else if (normalized.containsKey('HouseCleaning') ||
          normalized.containsKey('houseCleaning')) {
        normalized['type'] = 'houseCleaning';
      } else if (normalized.containsKey('UpholsteryCleaning') ||
          normalized.containsKey('upholsteryCleaning')) {
        normalized['type'] = 'upholsteryCleaning';
      } else if (normalized.containsKey('CarWash') ||
          normalized.containsKey('carWash')) {
        normalized['type'] = 'carWash';
      }
    }
    if (normalized['customer'] == null) {
      normalized['customer'] = <String, dynamic>{};
    }
    final type = normalized['type']?.toString() ?? '';
    switch (type.toLowerCase()) {
      case 'deepcleaning':
        return DeepCleaningHistory.fromJson(normalized);
      case 'housecleaning':
        return HouseKeepingHistory.fromJson(normalized);
      case 'upholsterycleaning':
        return UpholsteryCleaningHistory.fromJson(normalized);
      case 'carwash':
        return CarWashHistory.fromJson(normalized);
      default:
        throw UnsupportedError('Unknown cleaning type: $type');
    }
  }
}

extension CleaningRequestExtraInvoiceX on CleaningRequest {
  bool get canCreateExtraInvoice =>
      requestStatus == RequestStatus.confirmed ||
      requestStatus == RequestStatus.inProgress;

  bool get hasExtraInvoice =>
      (extraFees ?? 0) > 0 ||
      (extraFeesDescription?.isNotEmpty ?? false) ||
      awaitingExtraPayment;
}
