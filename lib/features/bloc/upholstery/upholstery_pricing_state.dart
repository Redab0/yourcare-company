import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:equatable/equatable.dart';

class UpholsteryPricingState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final List<UpholsteryType> types;
  final List<UpholsteryPricingGroup> pricing;

  const UpholsteryPricingState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.types = const [],
    this.pricing = const [],
  });

  UpholsteryPricingState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    List<UpholsteryType>? types,
    List<UpholsteryPricingGroup>? pricing,
  }) {
    return UpholsteryPricingState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      types: types ?? this.types,
      pricing: pricing ?? this.pricing,
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
      ];
}

class UpholsteryPricingInitial extends UpholsteryPricingState {
  const UpholsteryPricingInitial();
}
