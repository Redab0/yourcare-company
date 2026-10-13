import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/request_invoice.dart';
import 'package:json_annotation/json_annotation.dart';

import 'laundry_models.dart';

part 'laundry_history.g.dart';

@JsonSerializable(checked: true, explicitToJson: true, includeIfNull: false)
class LaundryDetails {
  final String pricingMode;
  final String status;
  final String paymentStatus;
  final bool sameDay;
  final double minimumCharge;
  @JsonKey(fromJson: _referenceId)
  final String? addressId;
  @JsonKey(fromJson: _referenceId)
  final String? areaId;
  @JsonKey(readValue: _readAddress)
  final Address? address;
  @KuwaitScheduleConverter()
  final DateTime? scheduledTime;
  final String? specialNotes;
  final int? numberOfBags;
  final List<LaundryLine> items;
  final LaundryInvoice? invoice;
  final String? paymentUrl;

  const LaundryDetails(
      {required this.pricingMode,
      required this.status,
      required this.paymentStatus,
      this.sameDay = false,
      this.minimumCharge = 0,
      this.addressId,
      this.areaId,
      this.address,
      this.scheduledTime,
      this.specialNotes,
      this.numberOfBags,
      this.items = const [],
      this.invoice,
      this.paymentUrl});
  factory LaundryDetails.fromJson(Map<String, dynamic> json) =>
      _$LaundryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryDetailsToJson(this);

  LaundryDetails _withStatus(String status) => LaundryDetails(
        pricingMode: pricingMode,
        status: status,
        paymentStatus: paymentStatus,
        sameDay: sameDay,
        minimumCharge: minimumCharge,
        addressId: addressId,
        areaId: areaId,
        address: address,
        scheduledTime: scheduledTime,
        specialNotes: specialNotes,
        numberOfBags: numberOfBags,
        items: items,
        invoice: invoice,
        paymentUrl: paymentUrl,
      );

  bool get isPickupFirst => pricingMode == 'pickup_invoice_later';
  bool get isPaid => paymentStatus == 'paid';
  bool get isSettled => isPaid && invoice?.status == 'paid';
  bool get isTerminal =>
      const ['completed', 'pickup_rejected', 'cancelled'].contains(status);

  static const _invoiceableStatuses = {
    'pending_pickup',
    'pickup_accepted',
    'picked_up',
  };
  static const _activeStatuses = {
    ..._invoiceableStatuses,
    'invoice_sent',
    'confirmed',
    'paid',
    'in_progress',
    'ready_for_delivery',
    'out_for_delivery',
    'delivered',
  };

  /// Present old paid orders in the current flow without rewriting their history.
  String get displayStatus {
    if (isPaid &&
        (invoice == null || invoice?.status == 'paid') &&
        _activeStatuses.contains(status)) {
      return 'confirmed';
    }
    if (isAwaitingPayment) return 'invoice_sent';
    if (isPickupFirst &&
        !isPaid &&
        paymentStatus != 'refunded' &&
        _invoiceableStatuses.contains(status)) {
      return 'pending_pickup';
    }
    return status;
  }

  RequestStatus get displayRequestStatus => switch (displayStatus) {
        'confirmed' => RequestStatus.confirmed,
        'completed' => RequestStatus.completed,
        'cancelled' || 'pickup_rejected' => RequestStatus.cancelled,
        _ => RequestStatus.pending,
      };
  bool get canEditInvoice =>
      isPickupFirst &&
      _invoiceableStatuses.contains(status) &&
      !isPaid &&
      paymentStatus != 'refunded' &&
      (invoice == null || invoice!.status == 'draft');
  double get invoiceMinimumCharge => invoice?.minimumCharge ?? minimumCharge;
  bool get invoiceMeetsMinimum =>
      invoice != null &&
      (invoice!.subtotal * 1000).round() >=
          (invoiceMinimumCharge * 1000).round();
  bool get canSendInvoice =>
      canEditInvoice && invoice?.status == 'draft' && invoiceMeetsMinimum;
  bool get isAwaitingPayment =>
      !isPaid &&
      paymentStatus != 'refunded' &&
      !isTerminal &&
      _activeStatuses.contains(status) &&
      (status == 'invoice_sent' || !isPickupFirst);
  List<LaundryLine> get displayedItems => invoice?.items ?? items;

  /// The server remains authoritative for payment, cancellation and completion.
  List<String> get nextStatuses {
    if (isTerminal) return const [];
    if (isSettled && _activeStatuses.contains(status)) {
      return const ['completed', 'cancelled'];
    }
    // Preserve the existing cancellation policy for unpaid pickup requests.
    if (const ['pending_pickup', 'pickup_accepted'].contains(status)) {
      return const ['cancelled'];
    }
    return const [];
  }

  /// Laundry has no In progress tab; other services keep their existing tabs.
  int get jobTab => switch (status) {
        'completed' => 2,
        'cancelled' || 'pickup_rejected' => 3,
        _ => 0,
      };
}

@JsonSerializable(checked: true, explicitToJson: true, includeIfNull: false)
class LaundryHistory implements CleaningRequest {
  @override
  @JsonKey(readValue: laundryId)
  final String? id;
  @override
  final String type;
  @override
  @JsonKey(fromJson: requestStatusFromJson, toJson: requestStatusToJson)
  final RequestStatus requestStatus;
  @override
  final double totalPrice;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey(fromJson: _customer)
  final Customer customer;
  @override
  @KuwaitScheduleConverter()
  final DateTime? scheduledTime;
  @JsonKey(name: 'Laundry')
  final LaundryDetails detail;
  @override
  final double? extraFees;
  @override
  final String? extraFeesDescription;
  @override
  final bool awaitingExtraPayment;
  @override
  final String? extraPaymentUrl;
  @override
  final List<RequestInvoice> invoices;

  const LaundryHistory(
      {this.id,
      this.type = 'laundry',
      required this.requestStatus,
      this.totalPrice = 0,
      required this.createdAt,
      required this.updatedAt,
      required this.customer,
      this.scheduledTime,
      required this.detail,
      this.extraFees,
      this.extraFeesDescription,
      this.awaitingExtraPayment = false,
      this.extraPaymentUrl,
      this.invoices = const []});

  /// A shared terminal status must win over an inconsistent legacy snapshot.
  /// Keep [detail] unchanged so serialization retains the original history.
  LaundryDetails get displayDetail {
    final terminalStatus = switch (requestStatus) {
      RequestStatus.completed => 'completed',
      RequestStatus.cancelled || RequestStatus.canceled => 'cancelled',
      _ => null,
    };
    return terminalStatus == null || terminalStatus == detail.status
        ? detail
        : detail._withStatus(terminalStatus);
  }

  factory LaundryHistory.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['Laundry'] ??= normalized['laundry'];
    final detail = normalized['Laundry'];
    if (detail is Map && normalized['address'] is Map) {
      normalized['Laundry'] = <String, dynamic>{
        ...Map<String, dynamic>.from(detail),
        'address': normalized['address']
      };
    }
    normalized['scheduledTime'] ??=
        (normalized['Laundry'] as Map?)?['scheduledTime'];
    return _$LaundryHistoryFromJson(normalized);
  }
  Map<String, dynamic> toJson() => _$LaundryHistoryToJson(this);

  Address? get pickupAddress {
    if (detail.address != null) return detail.address;
    return customer.addresses
        ?.where((address) => address.id == detail.addressId)
        .firstOrNull;
  }

  @override
  LaundryHistory copyWithExtraInvoice(
          {required double extraFees,
          required String extraFeesDescription,
          required bool awaitingExtraPayment,
          String? extraPaymentUrl,
          List<RequestInvoice>? invoices}) =>
      LaundryHistory(
          id: id,
          type: type,
          requestStatus: requestStatus,
          totalPrice: totalPrice,
          createdAt: createdAt,
          updatedAt: updatedAt,
          customer: customer,
          scheduledTime: scheduledTime,
          detail: detail,
          extraFees: extraFees,
          extraFeesDescription: extraFeesDescription,
          awaitingExtraPayment: awaitingExtraPayment,
          extraPaymentUrl: extraPaymentUrl,
          invoices: invoices ?? this.invoices);
}

String? _referenceId(Object? value) => value is Map
    ? (value['id'] ?? value['_id'])?.toString()
    : value?.toString();
Object? _readAddress(Map json, String key) =>
    json['address'] ?? (json['addressId'] is Map ? json['addressId'] : null);
Customer _customer(Object? value) => value is Map
    ? Customer.fromJson(Map<String, dynamic>.from(value))
    : Customer(id: value?.toString());
