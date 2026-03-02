// cleaning_request.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
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

  /// Factory constructor does the “discriminator” logic
  factory CleaningRequest.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['type'] == null) {
      if (normalized.containsKey('DeepCleaning')) {
        normalized['type'] = 'deepCleaning';
      } else if (normalized.containsKey('houseCleaning')) {
        normalized['type'] = 'houseCleaning';
      } else if (normalized.containsKey('upholsteryCleaning')) {
        normalized['type'] = 'upholsteryCleaning';
      }
    }
    if (normalized['customer'] == null) {
      normalized['customer'] = <String, dynamic>{};
    }
    switch (normalized['type'] as String) {
      case 'deepCleaning':
        return DeepCleaningHistory.fromJson(normalized);
      case 'houseCleaning':
        return HouseKeepingHistory.fromJson(normalized);
      case 'upholsteryCleaning':
        return UpholsteryCleaningHistory.fromJson(normalized);
      default:
        throw UnsupportedError('Unknown cleaning type: ${normalized['type']}');
    }
  }
}
