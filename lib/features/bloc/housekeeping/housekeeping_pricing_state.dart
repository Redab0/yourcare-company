import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:equatable/equatable.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';

class HousekeepingPricingState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<AreaResponse> areas;
  final Map<String, double> areaFees;
  final double basePrice;
  final double cleaningProductsPrice;
  final bool singlePricingModelActive;
  final bool multiplePricingModelActive;
  final List<HousekeepingPricingOption> multiplePricingOptions;

  const HousekeepingPricingState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.areas = const [],
    this.areaFees = const {},
    this.basePrice = 0,
    this.cleaningProductsPrice = 0,
    this.singlePricingModelActive = false,
    this.multiplePricingModelActive = false,
    this.multiplePricingOptions = const [],
  });

  HousekeepingPricingState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    List<AreaResponse>? areas,
    Map<String, double>? areaFees,
    double? basePrice,
    double? cleaningProductsPrice,
    bool? singlePricingModelActive,
    bool? multiplePricingModelActive,
    List<HousekeepingPricingOption>? multiplePricingOptions,
  }) {
    return HousekeepingPricingState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      areas: areas ?? this.areas,
      areaFees: areaFees ?? this.areaFees,
      basePrice: basePrice ?? this.basePrice,
      cleaningProductsPrice: cleaningProductsPrice ?? this.cleaningProductsPrice,
      singlePricingModelActive:
          singlePricingModelActive ?? this.singlePricingModelActive,
      multiplePricingModelActive:
          multiplePricingModelActive ?? this.multiplePricingModelActive,
      multiplePricingOptions:
          multiplePricingOptions ?? this.multiplePricingOptions,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        error,
        areas,
        areaFees,
        basePrice,
        cleaningProductsPrice,
        singlePricingModelActive,
        multiplePricingModelActive,
        multiplePricingOptions,
      ];
}

class HousekeepingPricingInitial extends HousekeepingPricingState {
  const HousekeepingPricingInitial();
}
