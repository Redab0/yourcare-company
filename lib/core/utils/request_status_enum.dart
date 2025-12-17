// 1) Define your enum and (de)serializer
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

enum RequestStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('pending')
  pending,
  @JsonValue('inProgress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('canceled')
  canceled,
  @JsonValue('notPaid')
  notPaid,
  @JsonValue('paid')
  paid,
  @JsonValue('unknown')
  unknown,
}

RequestStatus requestStatusFromJson(String? s) => RequestStatusX.fromString(s);

String requestStatusToJson(RequestStatus status) => status.toJson();

extension RequestStatusX on RequestStatus {
  /// API → enum
  static RequestStatus fromString(String? s) {
    switch (s) {
      case 'confirmed':
        return RequestStatus.confirmed;
      case 'pending':
        return RequestStatus.pending;
      case 'inProgress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
      case 'canceled':
        return RequestStatus.cancelled;
      case 'notPaid':
        return RequestStatus.notPaid;
      case 'paid':
        return RequestStatus.paid;
      default:
        return RequestStatus.unknown;
    }
  }

  String displayText(BuildContext context) {
    switch (this) {
      case RequestStatus.confirmed:
        return context.l10n.confirmed;
      case RequestStatus.pending:
        return context.l10n.pending;
      case RequestStatus.inProgress:
        return context.l10n.inprogress;
      case RequestStatus.completed:
        return context.l10n.completed;
      case RequestStatus.cancelled:
      case RequestStatus.canceled:
        return context.l10n.cancelled;
      case RequestStatus.notPaid:
        return context.l10n.cancelled;
      case RequestStatus.paid:
        return context.l10n.cancelled;
      default:
        return 'Unknown';
    }
  }

  /// enum → API
  String toJson() {
    switch (this) {
      case RequestStatus.confirmed:
        return 'confirmed';
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.inProgress:
        return 'inProgress';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.cancelled:
      case RequestStatus.canceled:
        return 'cancelled';
      case RequestStatus.notPaid:
        return 'notPaid';
      case RequestStatus.paid:
        return 'paid';
      case RequestStatus.unknown:
        return 'unknown';
    }
  }
}

Color statusColor(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return Colors.orange;
    case RequestStatus.inProgress:
      return Colors.blue;
    case RequestStatus.completed:
      return Colors.green;
    case RequestStatus.confirmed:
      return Colors.teal;
    case RequestStatus.cancelled:
    case RequestStatus.canceled:
      return Colors.red;
    case RequestStatus.notPaid:
      return Colors.cyan;
    case RequestStatus.paid:
      return Colors.deepPurpleAccent;
    default:
      return Colors.grey;
  }
}
