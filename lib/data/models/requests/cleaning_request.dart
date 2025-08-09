// cleaning_request.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';

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
  DateTime get scheduledTime;
  Customer get customer;

  /// Factory constructor does the “discriminator” logic
  factory CleaningRequest.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'deepCleaning':
        return DeepCleaningHistory.fromJson(json);
      case 'houseCleaning':
        return HouseKeepingHistory.fromJson(json);
      default:
        throw UnsupportedError('Unknown cleaning type: ${json['type']}');
    }
  }
}
