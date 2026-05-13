import 'package:equatable/equatable.dart';

abstract class HousekeepingPricingEvent extends Equatable {
  const HousekeepingPricingEvent();

  @override
  List<Object?> get props => [];
}

class LoadHousekeepingConfig extends HousekeepingPricingEvent {
  const LoadHousekeepingConfig();
}

class UpdateBasePrice extends HousekeepingPricingEvent {
  final double basePrice;

  const UpdateBasePrice(this.basePrice);

  @override
  List<Object?> get props => [basePrice];
}

class ToggleSinglePricingModelActive extends HousekeepingPricingEvent {
  final bool isActive;

  const ToggleSinglePricingModelActive(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class ToggleMultiplePricingModelActive extends HousekeepingPricingEvent {
  final bool isActive;

  const ToggleMultiplePricingModelActive(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class UpdateAreaFee extends HousekeepingPricingEvent {
  final String areaId;
  final double fee;

  const UpdateAreaFee({required this.areaId, required this.fee});

  @override
  List<Object?> get props => [areaId, fee];
}

class UpdateMultipleOptionPrice extends HousekeepingPricingEvent {
  final String optionId;
  final double price;

  const UpdateMultipleOptionPrice(
      {required this.optionId, required this.price});

  @override
  List<Object?> get props => [optionId, price];
}

class UpdateCleaningProductsPrice extends HousekeepingPricingEvent {
  final double cleaningProductsPrice;

  const UpdateCleaningProductsPrice(this.cleaningProductsPrice);

  @override
  List<Object?> get props => [cleaningProductsPrice];
}

class UpdateServiceFrequencyDiscount extends HousekeepingPricingEvent {
  final String optionId;
  final double discountPercentage;

  const UpdateServiceFrequencyDiscount({
    required this.optionId,
    required this.discountPercentage,
  });

  @override
  List<Object?> get props => [optionId, discountPercentage];
}

class SaveHousekeepingPricing extends HousekeepingPricingEvent {
  const SaveHousekeepingPricing();
}
