import 'package:json_annotation/json_annotation.dart';

part 'laundry_models.g.dart';

Object? laundryId(Map json, String key) => json['_id'] ?? json['id'];

@JsonSerializable(checked: true)
class LaundryCategory {
  @JsonKey(name: '_id', readValue: laundryId)
  final String id;
  final String nameEn;
  final String nameAr;
  final bool active;
  const LaundryCategory(
      {required this.id,
      required this.nameEn,
      required this.nameAr,
      this.active = true});
  factory LaundryCategory.fromJson(Map<String, dynamic> json) =>
      _$LaundryCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryCategoryToJson(this);
  String name(bool arabic) => arabic ? nameAr : nameEn;
}

@JsonSerializable(checked: true, includeIfNull: false)
class LaundrySize {
  @JsonKey(name: '_id', readValue: laundryId)
  final String? id;
  final String nameEn;
  final String nameAr;
  final double price;
  @JsonKey(includeToJson: false)
  final double? defaultPrice;
  @JsonKey(includeToJson: false)
  final bool usesDefaultPrice;

  const LaundrySize(
      {this.id,
      required this.nameEn,
      required this.nameAr,
      required this.price,
      this.defaultPrice,
      this.usesDefaultPrice = true});
  factory LaundrySize.fromJson(Map<String, dynamic> json) =>
      _$LaundrySizeFromJson(json);
  Map<String, dynamic> toJson() => _$LaundrySizeToJson(this);
  String name(bool arabic) => arabic ? nameAr : nameEn;
}

@JsonSerializable(checked: true)
class LaundryServiceDefinition {
  @JsonKey(name: '_id', readValue: laundryId)
  final String id;
  final String nameEn;
  final String nameAr;
  final bool active;
  const LaundryServiceDefinition(
      {required this.id,
      required this.nameEn,
      required this.nameAr,
      this.active = true});
  factory LaundryServiceDefinition.fromJson(Map<String, dynamic> json) =>
      _$LaundryServiceDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryServiceDefinitionToJson(this);
}

@JsonSerializable(checked: true, includeIfNull: false)
class LaundryItemService {
  final String serviceId;
  final String nameEn;
  final String nameAr;
  final bool serviceActive;
  final bool companyActive;
  final bool active;
  final double? defaultPrice;
  final double? price;
  final bool usesDefaultPrice;
  const LaundryItemService(
      {required this.serviceId,
      required this.nameEn,
      required this.nameAr,
      this.serviceActive = true,
      this.companyActive = false,
      this.active = false,
      this.defaultPrice,
      this.price,
      this.usesDefaultPrice = true});
  factory LaundryItemService.fromJson(Map<String, dynamic> json) =>
      _$LaundryItemServiceFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryItemServiceToJson(this);
  String name(bool arabic) => arabic ? nameAr : nameEn;
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class LaundryServiceConfig {
  final String serviceId;
  final bool active;
  final double? price;
  const LaundryServiceConfig(
      {required this.serviceId, required this.active, this.price});
  factory LaundryServiceConfig.fromService(LaundryItemService service) =>
      LaundryServiceConfig(
          serviceId: service.serviceId,
          active: service.companyActive,
          price: service.usesDefaultPrice ? null : service.price);
  Map<String, dynamic> toJson() => _$LaundryServiceConfigToJson(this);
}

@JsonSerializable(checked: true, explicitToJson: true, includeIfNull: false)
class LaundryCatalogItem {
  final String? imageUrl;
  final String? categoryId;
  final LaundryCategory? category;
  @JsonKey(name: '_id', readValue: laundryId)
  final String id;
  final String nameEn;
  final String nameAr;
  final String unit;
  final String? unitLabel;
  final double? price;
  final List<LaundrySize> sizes;
  final List<LaundryItemService> services;
  final bool active;
  final String source;
  final String? productId;
  final bool productActive;
  final bool? companyActive;
  final bool configured;
  final double? defaultPrice;
  final bool usesDefaultPrice;

  const LaundryCatalogItem(
      {this.imageUrl,
      this.categoryId,
      this.category,
      required this.id,
      required this.nameEn,
      required this.nameAr,
      this.unit = 'item',
      this.unitLabel,
      this.price,
      this.sizes = const [],
      this.services = const [],
      this.active = true,
      this.source = 'company',
      this.productId,
      this.productActive = true,
      this.companyActive,
      this.configured = true,
      this.defaultPrice,
      this.usesDefaultPrice = true});
  factory LaundryCatalogItem.fromJson(Map<String, dynamic> json) =>
      _$LaundryCatalogItemFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryCatalogItemToJson(this);
  String name(bool arabic) => arabic ? nameAr : nameEn;
  bool get isManaged => source == 'admin' && productId != null;
  bool get enabledForCompany => companyActive ?? active;

  /// Invoice selections use service IDs just like existing option IDs.
  List<LaundrySize> get invoiceChoices => [
        ...sizes.where(
            (size) => size.id != null && size.price.isFinite && size.price > 0),
        ...services
            .where((service) =>
                service.active &&
                service.price != null &&
                service.price!.isFinite &&
                service.price! > 0)
            .map((service) => LaundrySize(
                id: service.serviceId,
                nameEn: service.nameEn,
                nameAr: service.nameAr,
                price: service.price!)),
      ];
  bool get canInvoice =>
      active &&
      (invoiceChoices.isNotEmpty ||
          (sizes.isEmpty && price != null && price!.isFinite && price! > 0));
}

@JsonSerializable(createFactory: false)
class LaundryProductSizePrice {
  final String sizeId;
  final double price;
  const LaundryProductSizePrice({required this.sizeId, required this.price});
  Map<String, dynamic> toJson() => _$LaundryProductSizePriceToJson(this);
}

@JsonSerializable(
    createFactory: false, explicitToJson: true, includeIfNull: false)
class LaundryProductConfig {
  @JsonKey(includeToJson: false)
  final bool availabilityOnly;
  final bool active;
  final double? price;
  final List<LaundryProductSizePrice> sizes;
  final List<LaundryServiceConfig>? services;
  const LaundryProductConfig(
      {required this.active,
      this.price,
      this.sizes = const [],
      this.services,
      this.availabilityOnly = false});
  Map<String, dynamic> toJson() => availabilityOnly
      ? {'active': active}
      : _$LaundryProductConfigToJson(this);

  /// Preserve all company overrides when changing only availability.
  factory LaundryProductConfig.fromItem(LaundryCatalogItem item,
          {bool? active}) =>
      LaundryProductConfig(
          active: active ?? item.enabledForCompany, availabilityOnly: true);
}

/// One price and/or company availability update.
@JsonSerializable(
    createFactory: false, explicitToJson: true, includeIfNull: false)
class LaundryItemPriceUpdate {
  final String? productId;
  final String? itemId;
  final bool? active;
  final double? price;
  final List<LaundryProductSizePrice>? sizes;
  final List<LaundryServiceConfig>? services;
  const LaundryItemPriceUpdate(
      {this.productId,
      this.itemId,
      this.active,
      this.price,
      this.sizes,
      this.services})
      : assert((productId == null) != (itemId == null));
  Map<String, dynamic> toJson() => _$LaundryItemPriceUpdateToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class LaundryBulkPricesRequest {
  final List<LaundryItemPriceUpdate> items;
  const LaundryBulkPricesRequest({required this.items});
  Map<String, dynamic> toJson() => _$LaundryBulkPricesRequestToJson(this);
}

@JsonSerializable(
    createFactory: false, explicitToJson: true, includeIfNull: false)
class LaundryCatalogMutation {
  final String? categoryId;
  @JsonKey(includeToJson: false)
  final bool removeCategory;
  final String nameEn;
  final String nameAr;
  final String unit;
  final String? unitLabel;
  final double? price;
  final List<LaundrySize> sizes;
  final List<LaundryServiceConfig>? services;
  final bool active;

  const LaundryCatalogMutation(
      {this.categoryId,
      this.removeCategory = false,
      required this.nameEn,
      required this.nameAr,
      required this.unit,
      this.unitLabel,
      this.price,
      this.sizes = const [],
      this.services,
      required this.active});
  Map<String, dynamic> toJson() => {
        ..._$LaundryCatalogMutationToJson(this),
        if (removeCategory) 'categoryId': null,
      };
}

@JsonSerializable(checked: true, includeIfNull: false)
class LaundryLine {
  final String? imageUrl;
  final String? categoryId;
  final LaundryCategory? category;
  final String? serviceId;
  final String itemId;
  final String itemName;
  final String? itemNameAr;
  final String? sizeId;
  final String? size;
  final String? sizeAr;
  final String unit;
  final String? unitLabel;
  final double quantity;
  final double unitPrice;
  final double total;

  const LaundryLine(
      {this.imageUrl,
      this.categoryId,
      this.category,
      this.serviceId,
      required this.itemId,
      required this.itemName,
      this.itemNameAr,
      this.sizeId,
      this.size,
      this.sizeAr,
      this.unit = 'item',
      this.unitLabel,
      required this.quantity,
      required this.unitPrice,
      required this.total});
  factory LaundryLine.fromJson(Map<String, dynamic> json) =>
      _$LaundryLineFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryLineToJson(this);
  String name(bool arabic) => arabic ? itemNameAr ?? itemName : itemName;
  String? sizeName(bool arabic) => arabic ? sizeAr ?? size : size;
}

@JsonSerializable(checked: true, explicitToJson: true, includeIfNull: false)
class LaundryInvoice {
  final String? revision;
  final String status;
  final List<LaundryLine> items;
  final double subtotal;
  final double? minimumCharge;
  final double pickupFee;
  final double deliveryFee;
  final double discount;
  final double platformFees;
  final double total;
  final DateTime? paidAt;

  const LaundryInvoice(
      {this.revision,
      required this.status,
      this.items = const [],
      this.subtotal = 0,
      this.minimumCharge,
      this.pickupFee = 0,
      this.deliveryFee = 0,
      this.discount = 0,
      this.platformFees = 0,
      this.total = 0,
      this.paidAt});
  factory LaundryInvoice.fromJson(Map<String, dynamic> json) =>
      _$LaundryInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$LaundryInvoiceToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class LaundryInvoiceSelection {
  final String itemId;
  final String? sizeId;
  final double quantity;

  const LaundryInvoiceSelection(
      {required this.itemId, this.sizeId, required this.quantity});
  Map<String, dynamic> toJson() => _$LaundryInvoiceSelectionToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class LaundryInvoiceRequest {
  final String? expectedRevision;
  final List<LaundryInvoiceSelection> items;
  final double pickupFee;
  final double deliveryFee;
  final double discount;
  final bool send;

  const LaundryInvoiceRequest(
      {this.expectedRevision,
      required this.items,
      this.pickupFee = 0,
      this.deliveryFee = 0,
      this.discount = 0,
      required this.send});
  Map<String, dynamic> toJson() => _$LaundryInvoiceRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class LaundryStatusRequest {
  final String status;
  const LaundryStatusRequest(this.status);
  Map<String, dynamic> toJson() => _$LaundryStatusRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class LaundryInvoiceSendRequest {
  final String? expectedRevision;
  const LaundryInvoiceSendRequest({this.expectedRevision});
  Map<String, dynamic> toJson() => _$LaundryInvoiceSendRequestToJson(this);
}
