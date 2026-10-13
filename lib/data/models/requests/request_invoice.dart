import 'package:json_annotation/json_annotation.dart';

part 'request_invoice.g.dart';

@JsonSerializable(checked: true)
class RequestInvoice {
  @JsonKey(name: '_id')
  final String? id;
  final String? type;
  @JsonKey(fromJson: _invoiceAmount)
  final double amount;
  final String? status;
  final String? paymentUrl;
  final String? paymentMethod;
  final String? description;
  final String? transactionReference;
  final DateTime? createdAt;
  final DateTime? paidAt;

  const RequestInvoice({
    this.id,
    this.type,
    this.amount = 0,
    this.status,
    this.paymentUrl,
    this.paymentMethod,
    this.description,
    this.transactionReference,
    this.createdAt,
    this.paidAt,
  });

  factory RequestInvoice.fromJson(Map<String, dynamic> json) =>
      _$RequestInvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$RequestInvoiceToJson(this);

  bool get isExtraFees {
    final value = type?.trim().toLowerCase().replaceAll('-', '_');
    return value == 'extra_fees' || value == 'extrafees';
  }

  bool get isPaid => status?.trim().toLowerCase() == 'paid';
}

/// The invoice list is authoritative when the legacy payment flag disagrees
/// with it. This happens when the backend has already marked every extra-fee
/// invoice as paid but still returns `awaitingExtraPayment: true`.
Map<String, dynamic> normalizeRequestInvoiceState(
  Map<String, dynamic> json,
) {
  final normalized = Map<String, dynamic>.from(json);
  final rawInvoices = json['invoices'];
  if (rawInvoices is! List) return normalized;

  final invoices = rawInvoices
      .whereType<Map>()
      .map((invoice) => Map<String, dynamic>.from(invoice))
      .toList(growable: false);
  normalized['invoices'] = invoices;

  if (invoices.isNotEmpty) {
    normalized['awaitingExtraPayment'] = invoices.any(
      (invoice) => invoice['status']?.toString().trim().toLowerCase() != 'paid',
    );
  }
  return normalized;
}

double _invoiceAmount(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
