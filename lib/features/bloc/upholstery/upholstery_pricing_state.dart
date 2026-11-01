import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:equatable/equatable.dart';

class UpholsteryPricingState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final List<UpholsteryType> types;
  final List<UpholsteryPricingGroup> pricing;
  final bool? available;
  final bool isAvailabilityLoading;
  final bool isAvailabilitySaving;
  final String? availabilityError;

  const UpholsteryPricingState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.types = const [],
    this.pricing = const [],
    this.available,
    this.isAvailabilityLoading = false,
    this.isAvailabilitySaving = false,
    this.availabilityError,
  });

  UpholsteryPricingState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    List<UpholsteryType>? types,
    List<UpholsteryPricingGroup>? pricing,
    bool? available,
    bool? isAvailabilityLoading,
    bool? isAvailabilitySaving,
    String? availabilityError,
    bool clearAvailabilityError = false,
  }) {
    return UpholsteryPricingState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      types: types ?? this.types,
      pricing: pricing ?? this.pricing,
      available: available ?? this.available,
      isAvailabilityLoading:
          isAvailabilityLoading ?? this.isAvailabilityLoading,
      isAvailabilitySaving: isAvailabilitySaving ?? this.isAvailabilitySaving,
      availabilityError: clearAvailabilityError
          ? null
          : availabilityError ?? this.availabilityError,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        error,
        successMessage,
        types,
        pricing,
        available,
        isAvailabilityLoading,
        isAvailabilitySaving,
        availabilityError,
      ];
}

class UpholsteryPricingInitial extends UpholsteryPricingState {
  const UpholsteryPricingInitial();
}
