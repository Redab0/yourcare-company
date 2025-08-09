// 1) Define your enum and (de)serializer
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/cupertino.dart';
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
        return RequestStatus.cancelled;
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
        return 'cancelled';
      case RequestStatus.unknown:
      default:
        return 'unknown';
    }
  }
}
