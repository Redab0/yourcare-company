// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laundry_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaundryCategory _$LaundryCategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryCategory',
      json,
      ($checkedConvert) {
        final val = LaundryCategory(
          id: $checkedConvert(
            '_id',
            (v) => v as String,
            readValue: laundryId,
          ),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameAr: $checkedConvert('nameAr', (v) => v as String),
          active: $checkedConvert('active', (v) => v as bool? ?? true),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$LaundryCategoryToJson(LaundryCategory instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'active': instance.active,
    };

LaundrySize _$LaundrySizeFromJson(Map<String, dynamic> json) => $checkedCreate(
      'LaundrySize',
      json,
      ($checkedConvert) {
        final val = LaundrySize(
          id: $checkedConvert(
            '_id',
            (v) => v as String?,
            readValue: laundryId,
          ),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameAr: $checkedConvert('nameAr', (v) => v as String),
          price: $checkedConvert('price', (v) => (v as num).toDouble()),
          defaultPrice:
              $checkedConvert('defaultPrice', (v) => (v as num?)?.toDouble()),
          usesDefaultPrice:
              $checkedConvert('usesDefaultPrice', (v) => v as bool? ?? true),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$LaundrySizeToJson(LaundrySize instance) =>
    <String, dynamic>{
      if (instance.id case final value?) '_id': value,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'price': instance.price,
    };

LaundryServiceDefinition _$LaundryServiceDefinitionFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryServiceDefinition',
      json,
      ($checkedConvert) {
        final val = LaundryServiceDefinition(
          id: $checkedConvert(
            '_id',
            (v) => v as String,
            readValue: laundryId,
          ),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameAr: $checkedConvert('nameAr', (v) => v as String),
          active: $checkedConvert('active', (v) => v as bool? ?? true),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$LaundryServiceDefinitionToJson(
        LaundryServiceDefinition instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'active': instance.active,
    };

LaundryItemService _$LaundryItemServiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryItemService',
      json,
      ($checkedConvert) {
        final val = LaundryItemService(
          serviceId: $checkedConvert('serviceId', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameAr: $checkedConvert('nameAr', (v) => v as String),
          serviceActive:
              $checkedConvert('serviceActive', (v) => v as bool? ?? true),
          companyActive:
              $checkedConvert('companyActive', (v) => v as bool? ?? false),
          active: $checkedConvert('active', (v) => v as bool? ?? false),
          defaultPrice:
              $checkedConvert('defaultPrice', (v) => (v as num?)?.toDouble()),
          price: $checkedConvert('price', (v) => (v as num?)?.toDouble()),
          usesDefaultPrice:
              $checkedConvert('usesDefaultPrice', (v) => v as bool? ?? true),
        );
        return val;
      },
    );

Map<String, dynamic> _$LaundryItemServiceToJson(LaundryItemService instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'serviceActive': instance.serviceActive,
      'companyActive': instance.companyActive,
      'active': instance.active,
      if (instance.defaultPrice case final value?) 'defaultPrice': value,
      if (instance.price case final value?) 'price': value,
      'usesDefaultPrice': instance.usesDefaultPrice,
    };

Map<String, dynamic> _$LaundryServiceConfigToJson(
        LaundryServiceConfig instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'active': instance.active,
      if (instance.price case final value?) 'price': value,
    };

LaundryCatalogItem _$LaundryCatalogItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryCatalogItem',
      json,
      ($checkedConvert) {
        final val = LaundryCatalogItem(
          imageUrl: $checkedConvert('imageUrl', (v) => v as String?),
          categoryId: $checkedConvert('categoryId', (v) => v as String?),
          category: $checkedConvert(
              'category',
              (v) => v == null
                  ? null
                  : LaundryCategory.fromJson(v as Map<String, dynamic>)),
          id: $checkedConvert(
            '_id',
            (v) => v as String,
            readValue: laundryId,
          ),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameAr: $checkedConvert('nameAr', (v) => v as String),
          unit: $checkedConvert('unit', (v) => v as String? ?? 'item'),
          unitLabel: $checkedConvert('unitLabel', (v) => v as String?),
          price: $checkedConvert('price', (v) => (v as num?)?.toDouble()),
          sizes: $checkedConvert(
              'sizes',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          LaundrySize.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
          services: $checkedConvert(
              'services',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) => LaundryItemService.fromJson(
                          e as Map<String, dynamic>))
                      .toList() ??
                  const []),
          active: $checkedConvert('active', (v) => v as bool? ?? true),
          source: $checkedConvert('source', (v) => v as String? ?? 'company'),
          productId: $checkedConvert('productId', (v) => v as String?),
          productActive:
              $checkedConvert('productActive', (v) => v as bool? ?? true),
          companyActive: $checkedConvert('companyActive', (v) => v as bool?),
          configured: $checkedConvert('configured', (v) => v as bool? ?? true),
          defaultPrice:
              $checkedConvert('defaultPrice', (v) => (v as num?)?.toDouble()),
          usesDefaultPrice:
              $checkedConvert('usesDefaultPrice', (v) => v as bool? ?? true),
        );
        return val;
      },
      fieldKeyMap: const {'id': '_id'},
    );

Map<String, dynamic> _$LaundryCatalogItemToJson(LaundryCatalogItem instance) =>
    <String, dynamic>{
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.categoryId case final value?) 'categoryId': value,
      if (instance.category?.toJson() case final value?) 'category': value,
      '_id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'unit': instance.unit,
      if (instance.unitLabel case final value?) 'unitLabel': value,
      if (instance.price case final value?) 'price': value,
      'sizes': instance.sizes.map((e) => e.toJson()).toList(),
      'services': instance.services.map((e) => e.toJson()).toList(),
      'active': instance.active,
      'source': instance.source,
      if (instance.productId case final value?) 'productId': value,
      'productActive': instance.productActive,
      if (instance.companyActive case final value?) 'companyActive': value,
      'configured': instance.configured,
      if (instance.defaultPrice case final value?) 'defaultPrice': value,
      'usesDefaultPrice': instance.usesDefaultPrice,
    };

Map<String, dynamic> _$LaundryProductSizePriceToJson(
        LaundryProductSizePrice instance) =>
    <String, dynamic>{
      'sizeId': instance.sizeId,
      'price': instance.price,
    };

Map<String, dynamic> _$LaundryProductConfigToJson(
        LaundryProductConfig instance) =>
    <String, dynamic>{
      'active': instance.active,
      if (instance.price case final value?) 'price': value,
      'sizes': instance.sizes.map((e) => e.toJson()).toList(),
      if (instance.services?.map((e) => e.toJson()).toList() case final value?)
        'services': value,
    };

Map<String, dynamic> _$LaundryItemPriceUpdateToJson(
        LaundryItemPriceUpdate instance) =>
    <String, dynamic>{
      if (instance.productId case final value?) 'productId': value,
      if (instance.itemId case final value?) 'itemId': value,
      if (instance.active case final value?) 'active': value,
      if (instance.price case final value?) 'price': value,
      if (instance.sizes?.map((e) => e.toJson()).toList() case final value?)
        'sizes': value,
      if (instance.services?.map((e) => e.toJson()).toList() case final value?)
        'services': value,
    };

Map<String, dynamic> _$LaundryBulkPricesRequestToJson(
        LaundryBulkPricesRequest instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

Map<String, dynamic> _$LaundryCatalogMutationToJson(
        LaundryCatalogMutation instance) =>
    <String, dynamic>{
      if (instance.categoryId case final value?) 'categoryId': value,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'unit': instance.unit,
      if (instance.unitLabel case final value?) 'unitLabel': value,
      if (instance.price case final value?) 'price': value,
      'sizes': instance.sizes.map((e) => e.toJson()).toList(),
      if (instance.services?.map((e) => e.toJson()).toList() case final value?)
        'services': value,
      'active': instance.active,
    };

LaundryLine _$LaundryLineFromJson(Map<String, dynamic> json) => $checkedCreate(
      'LaundryLine',
      json,
      ($checkedConvert) {
        final val = LaundryLine(
          imageUrl: $checkedConvert('imageUrl', (v) => v as String?),
          categoryId: $checkedConvert('categoryId', (v) => v as String?),
          category: $checkedConvert(
              'category',
              (v) => v == null
                  ? null
                  : LaundryCategory.fromJson(v as Map<String, dynamic>)),
          serviceId: $checkedConvert('serviceId', (v) => v as String?),
          itemId: $checkedConvert('itemId', (v) => v as String),
          itemName: $checkedConvert('itemName', (v) => v as String),
          itemNameAr: $checkedConvert('itemNameAr', (v) => v as String?),
          sizeId: $checkedConvert('sizeId', (v) => v as String?),
          size: $checkedConvert('size', (v) => v as String?),
          sizeAr: $checkedConvert('sizeAr', (v) => v as String?),
          unit: $checkedConvert('unit', (v) => v as String? ?? 'item'),
          unitLabel: $checkedConvert('unitLabel', (v) => v as String?),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          unitPrice: $checkedConvert('unitPrice', (v) => (v as num).toDouble()),
          total: $checkedConvert('total', (v) => (v as num).toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$LaundryLineToJson(LaundryLine instance) =>
    <String, dynamic>{
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.categoryId case final value?) 'categoryId': value,
      if (instance.category case final value?) 'category': value,
      if (instance.serviceId case final value?) 'serviceId': value,
      'itemId': instance.itemId,
      'itemName': instance.itemName,
      if (instance.itemNameAr case final value?) 'itemNameAr': value,
      if (instance.sizeId case final value?) 'sizeId': value,
      if (instance.size case final value?) 'size': value,
      if (instance.sizeAr case final value?) 'sizeAr': value,
      'unit': instance.unit,
      if (instance.unitLabel case final value?) 'unitLabel': value,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
    };

LaundryInvoice _$LaundryInvoiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LaundryInvoice',
      json,
      ($checkedConvert) {
        final val = LaundryInvoice(
          revision: $checkedConvert('revision', (v) => v as String?),
          status: $checkedConvert('status', (v) => v as String),
          items: $checkedConvert(
              'items',
              (v) =>
                  (v as List<dynamic>?)
                      ?.map((e) =>
                          LaundryLine.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  const []),
          subtotal:
              $checkedConvert('subtotal', (v) => (v as num?)?.toDouble() ?? 0),
          minimumCharge:
              $checkedConvert('minimumCharge', (v) => (v as num?)?.toDouble()),
          pickupFee:
              $checkedConvert('pickupFee', (v) => (v as num?)?.toDouble() ?? 0),
          deliveryFee: $checkedConvert(
              'deliveryFee', (v) => (v as num?)?.toDouble() ?? 0),
          discount:
              $checkedConvert('discount', (v) => (v as num?)?.toDouble() ?? 0),
          platformFees: $checkedConvert(
              'platformFees', (v) => (v as num?)?.toDouble() ?? 0),
          total: $checkedConvert('total', (v) => (v as num?)?.toDouble() ?? 0),
          paidAt: $checkedConvert(
              'paidAt', (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$LaundryInvoiceToJson(LaundryInvoice instance) =>
    <String, dynamic>{
      if (instance.revision case final value?) 'revision': value,
      'status': instance.status,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'subtotal': instance.subtotal,
      if (instance.minimumCharge case final value?) 'minimumCharge': value,
      'pickupFee': instance.pickupFee,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'platformFees': instance.platformFees,
      'total': instance.total,
      if (instance.paidAt?.toIso8601String() case final value?) 'paidAt': value,
    };

Map<String, dynamic> _$LaundryInvoiceSelectionToJson(
        LaundryInvoiceSelection instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      if (instance.sizeId case final value?) 'sizeId': value,
      'quantity': instance.quantity,
    };

Map<String, dynamic> _$LaundryInvoiceRequestToJson(
        LaundryInvoiceRequest instance) =>
    <String, dynamic>{
      'expectedRevision': instance.expectedRevision,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'pickupFee': instance.pickupFee,
      'deliveryFee': instance.deliveryFee,
      'discount': instance.discount,
      'send': instance.send,
    };

Map<String, dynamic> _$LaundryStatusRequestToJson(
        LaundryStatusRequest instance) =>
    <String, dynamic>{
      'status': instance.status,
    };

Map<String, dynamic> _$LaundryInvoiceSendRequestToJson(
        LaundryInvoiceSendRequest instance) =>
    <String, dynamic>{
      'expectedRevision': instance.expectedRevision,
    };
