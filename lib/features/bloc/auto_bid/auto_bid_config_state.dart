import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:equatable/equatable.dart';

class AutoBidConfigState extends Equatable {
  final bool isLoadingDeep;
  final bool isLoadingUpholstery;
  final bool isSavingDeep;
  final bool isSavingUpholstery;
  final AutoBidDeepCleaningPricing deepCleaningPricing;
  final AutoBidDeepCleaningCategories deepCategories;
  final AutoBidUpholsteryPricing upholsteryPricing;
  final AutoBidUpholsteryCategories upholsteryCategories;
  final bool deepEnabled;
  final bool upholsteryEnabled;
  final String? error;

  const AutoBidConfigState({
    required this.isLoadingDeep,
    required this.isLoadingUpholstery,
    required this.isSavingDeep,
    required this.isSavingUpholstery,
    required this.deepCleaningPricing,
    required this.deepCategories,
    required this.upholsteryPricing,
    required this.upholsteryCategories,
    required this.deepEnabled,
    required this.upholsteryEnabled,
    this.error,
  });

  factory AutoBidConfigState.initial() {
    return AutoBidConfigState(
      isLoadingDeep: false,
      isLoadingUpholstery: false,
      isSavingDeep: false,
      isSavingUpholstery: false,
      deepCleaningPricing: AutoBidDeepCleaningPricing.empty(),
      deepCategories: AutoBidDeepCleaningCategories.empty(),
      upholsteryPricing: AutoBidUpholsteryPricing.empty(),
      upholsteryCategories: AutoBidUpholsteryCategories.empty(),
      deepEnabled: true,
      upholsteryEnabled: true,
      error: null,
    );
  }

  AutoBidConfigState copyWith({
    bool? isLoadingDeep,
    bool? isLoadingUpholstery,
    bool? isSavingDeep,
    bool? isSavingUpholstery,
    AutoBidDeepCleaningPricing? deepCleaningPricing,
    AutoBidDeepCleaningCategories? deepCategories,
    AutoBidUpholsteryPricing? upholsteryPricing,
    AutoBidUpholsteryCategories? upholsteryCategories,
    bool? deepEnabled,
    bool? upholsteryEnabled,
    String? error,
  }) {
    return AutoBidConfigState(
      isLoadingDeep: isLoadingDeep ?? this.isLoadingDeep,
      isLoadingUpholstery: isLoadingUpholstery ?? this.isLoadingUpholstery,
      isSavingDeep: isSavingDeep ?? this.isSavingDeep,
      isSavingUpholstery: isSavingUpholstery ?? this.isSavingUpholstery,
      deepCleaningPricing: deepCleaningPricing ?? this.deepCleaningPricing,
      deepCategories: deepCategories ?? this.deepCategories,
      upholsteryPricing: upholsteryPricing ?? this.upholsteryPricing,
      upholsteryCategories: upholsteryCategories ?? this.upholsteryCategories,
      deepEnabled: deepEnabled ?? this.deepEnabled,
      upholsteryEnabled: upholsteryEnabled ?? this.upholsteryEnabled,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoadingDeep,
        isLoadingUpholstery,
        isSavingDeep,
        isSavingUpholstery,
        deepCleaningPricing,
        deepCategories,
        upholsteryPricing,
        upholsteryCategories,
        deepEnabled,
        upholsteryEnabled,
        error,
      ];
}
