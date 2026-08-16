import 'package:equatable/equatable.dart';

abstract class UpholsteryPricingEvent extends Equatable {
  const UpholsteryPricingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUpholsteryPricingConfig extends UpholsteryPricingEvent {
  const LoadUpholsteryPricingConfig();
}

class ToggleUpholsteryType extends UpholsteryPricingEvent {
  final String upholsteryTypeId;
  final bool isEnabled;

  const ToggleUpholsteryType({
    required this.upholsteryTypeId,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [upholsteryTypeId, isEnabled];
}

class UpdateUpholsteryPackagePrice extends UpholsteryPricingEvent {
  final String upholsteryTypeId;
  final String packageRowKey;
  final double price;

  const UpdateUpholsteryPackagePrice({
    required this.upholsteryTypeId,
    required this.packageRowKey,
    required this.price,
  });

  @override
  List<Object?> get props => [upholsteryTypeId, packageRowKey, price];
}

class UpdateUpholsteryPackageDiscount extends UpholsteryPricingEvent {
  final String upholsteryTypeId;
  final String packageRowKey;
  final double discountPercentage;

  const UpdateUpholsteryPackageDiscount({
    required this.upholsteryTypeId,
    required this.packageRowKey,
    required this.discountPercentage,
  });

  @override
  List<Object?> get props => [
        upholsteryTypeId,
        packageRowKey,
        discountPercentage,
      ];
}

class UpdateUpholsteryPackageDetails extends UpholsteryPricingEvent {
  final String upholsteryTypeId;
  final String packageRowKey;
  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;

  const UpdateUpholsteryPackageDetails({
    required this.upholsteryTypeId,
    required this.packageRowKey,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
  });

  @override
  List<Object?> get props => [
        upholsteryTypeId,
        packageRowKey,
        titleEn,
        titleAr,
        descriptionEn,
        descriptionAr,
      ];
}

class AddUpholsteryPackage extends UpholsteryPricingEvent {
  final String upholsteryTypeId;

  const AddUpholsteryPackage({required this.upholsteryTypeId});

  @override
  List<Object?> get props => [upholsteryTypeId];
}

class RemoveUpholsteryPackage extends UpholsteryPricingEvent {
  final String upholsteryTypeId;
  final String packageRowKey;

  const RemoveUpholsteryPackage({
    required this.upholsteryTypeId,
    required this.packageRowKey,
  });

  @override
  List<Object?> get props => [upholsteryTypeId, packageRowKey];
}

class SaveUpholsteryPricing extends UpholsteryPricingEvent {
  const SaveUpholsteryPricing();
}
