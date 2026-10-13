// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laundry_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaundryDetails _$LaundryDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryDetails',
      json,
      ($checkedConvert) {
        final val = LaundryDetails(
          pricingMode: $checkedConvert('pricingMode', (v) => v as String),
          status: $checkedConvert('status', (v) => v as String),
          paymentStatus: $checkedConvert('paymentStatus', (v) => v as String),
          sameDay: $checkedConvert('sameDay', (v) => v as bool? ?? false),
          minimumCharge: $checkedConvert(
              'minimumCharge', (v) => (v as num?)?.toDouble() ?? 0),
          addressId: $checkedConvert('addressId', (v) => _referenceId(v)),
          areaId: $checkedConvert('areaId', (v) => _referenceId(v)),
          address: $checkedConvert(
            'address',
            (v) =>
                v == null ? null : Address.fromJson(v as Map<String, dynamic>),
            readValue: _readAddress,
          ),
          scheduledTime: $checkedConvert(
              'scheduledTime',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const KuwaitScheduleConverter().fromJson)),
          specialNotes: $checkedConvert('specialNotes', (v) => v as String?),
          numberOfBags:
              $checkedConvert('numberOfBags', (v) => (v as num?)?.toInt()),
          items: $checkedConvert(
              'items',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          LaundryLine.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
          invoice: $checkedConvert(
              'invoice',
              (v) => v == null
                  ? null
                  : LaundryInvoice.fromJson(v as Map<String, dynamic>)),
          paymentUrl: $checkedConvert('paymentUrl', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$LaundryDetailsToJson(LaundryDetails instance) =>
    <String, dynamic>{
      'pricingMode': instance.pricingMode,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'sameDay': instance.sameDay,
      'minimumCharge': instance.minimumCharge,
      if (instance.addressId case final value?) 'addressId': value,
      if (instance.areaId case final value?) 'areaId': value,
      if (instance.address?.toJson() case final value?) 'address': value,
      if (_$JsonConverterToJson<String, DateTime>(
              instance.scheduledTime, const KuwaitScheduleConverter().toJson)
          case final value?)
        'scheduledTime': value,
      if (instance.specialNotes case final value?) 'specialNotes': value,
      if (instance.numberOfBags case final value?) 'numberOfBags': value,
      'items': instance.items.map((e) => e.toJson()).toList(),
      if (instance.invoice?.toJson() case final value?) 'invoice': value,
      if (instance.paymentUrl case final value?) 'paymentUrl': value,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

LaundryHistory _$LaundryHistoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryHistory',
      json,
      ($checkedConvert) {
        final val = LaundryHistory(
          id: $checkedConvert(
            'id',
            (v) => v as String?,
            readValue: laundryId,
          ),
          type: $checkedConvert('type', (v) => v as String? ?? 'laundry'),
          requestStatus: $checkedConvert(
              'requestStatus', (v) => requestStatusFromJson(v as String?)),
          totalPrice: $checkedConvert(
              'totalPrice', (v) => (v as num?)?.toDouble() ?? 0),
          createdAt:
              $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
          customer: $checkedConvert('customer', (v) => _customer(v)),
          scheduledTime: $checkedConvert(
              'scheduledTime',
              (v) => _$JsonConverterFromJson<String, DateTime>(
                  v, const KuwaitScheduleConverter().fromJson)),
          detail: $checkedConvert('Laundry',
              (v) => LaundryDetails.fromJson(v as Map<String, dynamic>)),
          extraFees:
              $checkedConvert('extraFees', (v) => (v as num?)?.toDouble()),
          extraFeesDescription:
              $checkedConvert('extraFeesDescription', (v) => v as String?),
          awaitingExtraPayment: $checkedConvert(
              'awaitingExtraPayment', (v) => v as bool? ?? false),
          extraPaymentUrl:
              $checkedConvert('extraPaymentUrl', (v) => v as String?),
          invoices: $checkedConvert(
              'invoices',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          RequestInvoice.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
        );
        return val;
      },
      fieldKeyMap: const {'detail': 'Laundry'},
    );

Map<String, dynamic> _$LaundryHistoryToJson(LaundryHistory instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'type': instance.type,
      'requestStatus': requestStatusToJson(instance.requestStatus),
      'totalPrice': instance.totalPrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'customer': instance.customer.toJson(),
      if (_$JsonConverterToJson<String, DateTime>(
              instance.scheduledTime, const KuwaitScheduleConverter().toJson)
          case final value?)
        'scheduledTime': value,
      'Laundry': instance.detail.toJson(),
      if (instance.extraFees case final value?) 'extraFees': value,
      if (instance.extraFeesDescription case final value?)
        'extraFeesDescription': value,
      'awaitingExtraPayment': instance.awaitingExtraPayment,
      if (instance.extraPaymentUrl case final value?) 'extraPaymentUrl': value,
      'invoices': instance.invoices.map((e) => e.toJson()).toList(),
    };
