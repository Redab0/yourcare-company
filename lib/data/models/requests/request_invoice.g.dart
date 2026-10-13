// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestInvoice _$RequestInvoiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'RequestInvoice',
      json,
      ($checkedConvert) {
        final val = RequestInvoice(
          id: $checkedConvert('_id', (v) => v as String?),
          type: $checkedConvert('type', (v) => v as String?),
          amount: $checkedConvert(
              'amount', (v) => v == null ? 0 : _invoiceAmount(v)),
          status: $checkedConvert('status', (v) => v as String?),
          paymentUrl: $checkedConvert('paymentUrl', (v) => v as String?),
          paymentMethod: $checkedConvert('paymentMethod', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          transactionReference:
              $checkedConvert('transactionReference', (v) => v as String?),
          createdAt: $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          paidAt: $checkedConvert(
              'paidAt', (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$RequestInvoiceToJson(RequestInvoice instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'status': instance.status,
      'paymentUrl': instance.paymentUrl,
      'paymentMethod': instance.paymentMethod,
      'description': instance.description,
      'transactionReference': instance.transactionReference,
      'createdAt': instance.createdAt?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
    };
