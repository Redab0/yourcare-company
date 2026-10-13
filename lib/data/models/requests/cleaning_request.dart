import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
// cleaning_request.dart

import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/request_invoice.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';

import 'deep_cleaning_history.dart';
import 'house_keeping_history.dart';
import 'request_campaign.dart';

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
  List<RequestInvoice> get invoices;

  CleaningRequest copyWithExtraInvoice({
    required double extraFees,
    required String extraFeesDescription,
    required bool awaitingExtraPayment,
    String? extraPaymentUrl,
    List<RequestInvoice>? invoices,
  });

  /// Factory constructor does the “discriminator” logic
  factory CleaningRequest.fromJson(Map<String, dynamic> json) {
    final normalized = normalizeRequestInvoiceState(json);
    if (normalized['type'] == null) {
      if (normalized.containsKey('DeepCleaning')) {
        normalized['type'] = 'deepCleaning';
      } else if (normalized.containsKey('HouseCleaning') ||
          normalized.containsKey('houseCleaning')) {
        normalized['type'] = 'houseCleaning';
      } else if (normalized.containsKey('UpholsteryCleaning') ||
          normalized.containsKey('upholsteryCleaning')) {
        normalized['type'] = 'upholsteryCleaning';
      } else if (normalized.containsKey('Laundry') ||
          normalized.containsKey('laundry')) {
        normalized['type'] = 'laundry';
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
      case 'laundry':
        return LaundryHistory.fromJson(normalized);
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

  List<RequestInvoice> get extraInvoices => invoices;

  bool get hasPendingExtraInvoicePayment =>
      awaitingExtraPayment || extraInvoices.any((invoice) => !invoice.isPaid);

  bool get allExtraInvoicePaymentsSuccessful =>
      extraInvoices.isNotEmpty &&
      !hasPendingExtraInvoicePayment &&
      extraInvoices.every((invoice) => invoice.isPaid);

  bool get hasExtraInvoice =>
      extraInvoices.isNotEmpty ||
      (extraFees ?? 0) > 0 ||
      (extraFeesDescription?.isNotEmpty ?? false) ||
      awaitingExtraPayment;
}

/// Gift labels use the server flag and the order snapshot, never eligibility.
extension RegistrationGiftRequest on CleaningRequest {
  bool get registrationGiftApplied => switch (this) {
        HouseKeepingHistory r => r.registrationGiftApplied,
        DeepCleaningHistory r => r.registrationGiftApplied,
        UpholsteryCleaningHistory r => r.registrationGiftApplied,
        CarWashHistory r => r.registrationGiftApplied,
        _ => false,
      };

  RequestCampaign? get campaignSnapshot => switch (this) {
        HouseKeepingHistory r => r.campaign,
        DeepCleaningHistory r => r.campaign,
        UpholsteryCleaningHistory r => r.campaign,
        CarWashHistory r => r.campaign,
        _ => null,
      };

  bool get hasActiveRegistrationGift {
    // Cancellation does not necessarily refund or release a consumed gift.
    if (!registrationGiftApplied) return false;
    final snapshot = campaignSnapshot;
    // Legacy responses have only the server flag. Do not invent an amount.
    if (snapshot == null) return true;
    final amount = snapshot.discountKwd;
    return snapshot.hasActiveRegistrationGift &&
        (amount == null || (amount.isFinite && amount > 0));
  }

  double? get registrationGiftDiscountKwd =>
      hasActiveRegistrationGift ? campaignSnapshot?.discountKwd : null;

  bool get isRegistrationGiftReserved =>
      hasActiveRegistrationGift && campaignSnapshot?.state == 'reserved';

  bool get hasVisibleCampaignBenefit =>
      hasActiveRegistrationGift || campaignSnapshot?.hasVisibleBenefit == true;
}
