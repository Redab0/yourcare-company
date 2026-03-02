import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:equatable/equatable.dart';

class HousekeepingPricingState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<AreaResponse> areas;
  final Map<String, double> areaFees;
  final double basePrice;
  final bool isActive;

  const HousekeepingPricingState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.areas = const [],
    this.areaFees = const {},
    this.basePrice = 0,
    this.isActive = true,
  });

  HousekeepingPricingState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    List<AreaResponse>? areas,
    Map<String, double>? areaFees,
    double? basePrice,
    bool? isActive,
  }) {
    return HousekeepingPricingState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      areas: areas ?? this.areas,
      areaFees: areaFees ?? this.areaFees,
      basePrice: basePrice ?? this.basePrice,
      isActive: isActive ?? this.isActive,
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
        isActive,
      ];
}

class HousekeepingPricingInitial extends HousekeepingPricingState {
  const HousekeepingPricingInitial();
}
