import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/get_auto_bid_categories_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/get_auto_bid_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/upsert_auto_bid_config_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_event.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AutoBidConfigBloc extends Bloc<AutoBidConfigEvent, AutoBidConfigState> {
  static const deepCleaning = 'deepCleaning';
  static const upholsteryCleaning = 'upholsteryCleaning';

  final getCategoriesUseCase = sl<GetAutoBidCategoriesUseCase>();
  final getConfigUseCase = sl<GetAutoBidConfigUseCase>();
  final upsertConfigUseCase = sl<UpsertAutoBidConfigUseCase>();
  final _loader = sl<LoadingController>();

  AutoBidConfigBloc() : super(AutoBidConfigState.initial()) {
    on<LoadAutoBidConfigs>(_onLoadConfigs);
    on<ToggleAutoBidEnabled>(_onToggleEnabled);
    on<UpdateDeepCleaningPrice>(_onUpdateDeepPrice);
    on<UpdateDeepCleaningExpectedTime>(_onUpdateDeepExpectedTime);
    on<UpdateUpholsteryPrice>(_onUpdateUpholsteryPrice);
    on<UpdateUpholsteryExpectedTime>(_onUpdateUpholsteryExpectedTime);
    on<SaveAutoBidConfig>(_onSaveConfig);
  }

  FutureOr<void> _onLoadConfigs(
    LoadAutoBidConfigs event,
    Emitter<AutoBidConfigState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingDeep: true,
      isLoadingUpholstery: true,
      error: null,
    ));
    try {
      final results = await Future.wait([
        getCategoriesUseCase.getDeepCleaning(deepCleaning),
        getCategoriesUseCase.getUpholstery(upholsteryCleaning),
        getConfigUseCase.call(deepCleaning),
        getConfigUseCase.call(upholsteryCleaning),
      ]);
      final deepCategories = results[0] as AutoBidDeepCleaningCategories?;
      final upholsteryCategories = results[1] as AutoBidUpholsteryCategories?;
      final deepConfig = results[2] as AutoBidConfig?;
      final upholsteryConfig = results[3] as AutoBidConfig?;

      emit(state.copyWith(
        isLoadingDeep: false,
        isLoadingUpholstery: false,
        deepCategories:
            deepCategories ?? AutoBidDeepCleaningCategories.empty(),
        upholsteryCategories:
            upholsteryCategories ?? AutoBidUpholsteryCategories.empty(),
        deepCleaningPricing:
            deepConfig?.deepCleaningPricing ?? AutoBidDeepCleaningPricing.empty(),
        upholsteryPricing:
            upholsteryConfig?.upholsteryPricing ??
                AutoBidUpholsteryPricing.empty(),
        deepEnabled: deepConfig?.isEnabled ?? true,
        upholsteryEnabled: upholsteryConfig?.isEnabled ?? true,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDeep: false,
        isLoadingUpholstery: false,
        error: e.toString(),
      ));
    }
  }

  List<AutoBidOption> _upsertOption(
    List<AutoBidOption> items,
    String optionId, {
    double? price,
    int? expectedTimeInDays,
  }) {
    AutoBidOption? existing;
    for (final item in items) {
      if (item.categoryOptionId == optionId) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      return [
        ...items,
        AutoBidOption(
          categoryOptionId: optionId,
          price: price ?? 0,
          expectedTimeInDays: expectedTimeInDays,
        ),
      ];
    }
    return items
        .map((item) => item.categoryOptionId == optionId
            ? item.copyWith(
                price: price ?? item.price,
                expectedTimeInDays:
                    expectedTimeInDays ?? item.expectedTimeInDays,
              )
            : item)
        .toList();
  }

  FutureOr<void> _onToggleEnabled(
    ToggleAutoBidEnabled event,
    Emitter<AutoBidConfigState> emit,
  ) {
    if (event.serviceType == deepCleaning) {
      emit(state.copyWith(deepEnabled: event.isEnabled, error: null));
    } else if (event.serviceType == upholsteryCleaning) {
      emit(state.copyWith(upholsteryEnabled: event.isEnabled, error: null));
    }
  }

  FutureOr<void> _onUpdateDeepPrice(
    UpdateDeepCleaningPrice event,
    Emitter<AutoBidConfigState> emit,
  ) {
    final pricing = state.deepCleaningPricing;

    AutoBidDeepCleaningPricing updated;
    switch (event.section) {
      case 'departmentTypes':
        updated = pricing.copyWith(
          departmentTypes: _upsertOption(
              pricing.departmentTypes, event.optionId, price: event.price),
        );
        break;
      case 'bedrooms':
        updated = pricing.copyWith(
          bedrooms: _upsertOption(pricing.bedrooms, event.optionId, price: event.price),
        );
        break;
      case 'bathrooms':
        updated = pricing.copyWith(
          bathrooms:
              _upsertOption(pricing.bathrooms, event.optionId, price: event.price),
        );
        break;
      case 'kitchens':
        updated = pricing.copyWith(
          kitchens: _upsertOption(pricing.kitchens, event.optionId, price: event.price),
        );
        break;
      case 'livingRooms':
        updated = pricing.copyWith(
          livingRooms:
              _upsertOption(pricing.livingRooms, event.optionId, price: event.price),
        );
        break;
      case 'numberOfFloors':
        updated = pricing.copyWith(
          numberOfFloors: _upsertOption(
              pricing.numberOfFloors, event.optionId, price: event.price),
        );
        break;
      case 'sizeOptions':
        updated = pricing.copyWith(
          sizeOptions:
              _upsertOption(pricing.sizeOptions, event.optionId, price: event.price),
        );
        break;
      default:
        updated = pricing;
    }

    emit(state.copyWith(deepCleaningPricing: updated, error: null));
  }


  FutureOr<void> _onUpdateDeepExpectedTime(
    UpdateDeepCleaningExpectedTime event,
    Emitter<AutoBidConfigState> emit,
  ) {
    final pricing = state.deepCleaningPricing;

    AutoBidDeepCleaningPricing updated;
    switch (event.section) {
      case 'departmentTypes':
        updated = pricing.copyWith(
          departmentTypes: _upsertOption(
            pricing.departmentTypes,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      case 'bedrooms':
        updated = pricing.copyWith(
          bedrooms: _upsertOption(
            pricing.bedrooms,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      case 'bathrooms':
        updated = pricing.copyWith(
          bathrooms: _upsertOption(
            pricing.bathrooms,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      case 'kitchens':
        updated = pricing.copyWith(
          kitchens: _upsertOption(
            pricing.kitchens,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      case 'livingRooms':
        updated = pricing.copyWith(
          livingRooms: _upsertOption(
            pricing.livingRooms,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      case 'numberOfFloors':
        updated = pricing.copyWith(
          numberOfFloors: _upsertOption(
            pricing.numberOfFloors,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      case 'sizeOptions':
        updated = pricing.copyWith(
          sizeOptions: _upsertOption(
            pricing.sizeOptions,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
        break;
      default:
        updated = pricing;
    }

    emit(state.copyWith(deepCleaningPricing: updated, error: null));
  }

  FutureOr<void> _onUpdateUpholsteryPrice(
    UpdateUpholsteryPrice event,
    Emitter<AutoBidConfigState> emit,
  ) {
    final updatedOverrides =
        state.upholsteryPricing.typeOverrides.map((typeOverride) {
      if (typeOverride.categoryTypeId != event.categoryTypeId) {
        return typeOverride;
      }

      if (event.section == 'sizes') {
        return typeOverride.copyWith(
          sizes: _upsertOption(typeOverride.sizes, event.optionId, price: event.price),
        );
      }
      if (event.section == 'materials') {
        return typeOverride.copyWith(
          materials:
              _upsertOption(typeOverride.materials, event.optionId, price: event.price),
        );
      }
      if (event.section == 'conditions') {
        return typeOverride.copyWith(
          conditions: _upsertOption(
              typeOverride.conditions, event.optionId, price: event.price),
        );
      }
      return typeOverride;
    }).toList();

    final hasOverride = updatedOverrides
        .any((override) => override.categoryTypeId == event.categoryTypeId);
    if (!hasOverride) {
      final newOption = AutoBidOption(
        categoryOptionId: event.optionId,
        price: event.price,
      );
      updatedOverrides.add(AutoBidTypeOverride(
        categoryTypeId: event.categoryTypeId,
        sizes: event.section == 'sizes' ? [newOption] : const [],
        materials: event.section == 'materials' ? [newOption] : const [],
        conditions: event.section == 'conditions' ? [newOption] : const [],
      ));
    }

    emit(state.copyWith(
      upholsteryPricing:
          state.upholsteryPricing.copyWith(typeOverrides: updatedOverrides),
      error: null,
    ));
  }


  FutureOr<void> _onUpdateUpholsteryExpectedTime(
    UpdateUpholsteryExpectedTime event,
    Emitter<AutoBidConfigState> emit,
  ) {
    final updatedOverrides =
        state.upholsteryPricing.typeOverrides.map((typeOverride) {
      if (typeOverride.categoryTypeId != event.categoryTypeId) {
        return typeOverride;
      }

      if (event.section == 'sizes') {
        return typeOverride.copyWith(
          sizes: _upsertOption(
            typeOverride.sizes,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
      }
      if (event.section == 'materials') {
        return typeOverride.copyWith(
          materials: _upsertOption(
            typeOverride.materials,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
      }
      if (event.section == 'conditions') {
        return typeOverride.copyWith(
          conditions: _upsertOption(
            typeOverride.conditions,
            event.optionId,
            expectedTimeInDays: event.expectedTimeInDays,
          ),
        );
      }
      return typeOverride;
    }).toList();

    final hasOverride = updatedOverrides
        .any((override) => override.categoryTypeId == event.categoryTypeId);
    if (!hasOverride) {
      final newOption = AutoBidOption(
        categoryOptionId: event.optionId,
        expectedTimeInDays: event.expectedTimeInDays,
      );
      updatedOverrides.add(AutoBidTypeOverride(
        categoryTypeId: event.categoryTypeId,
        sizes: event.section == 'sizes' ? [newOption] : const [],
        materials: event.section == 'materials' ? [newOption] : const [],
        conditions: event.section == 'conditions' ? [newOption] : const [],
      ));
    }

    emit(state.copyWith(
      upholsteryPricing:
          state.upholsteryPricing.copyWith(typeOverrides: updatedOverrides),
      error: null,
    ));
  }

  FutureOr<void> _onSaveConfig(
    SaveAutoBidConfig event,
    Emitter<AutoBidConfigState> emit,
  ) async {
    final isDeep = event.serviceType == deepCleaning;
    emit(state.copyWith(
      isSavingDeep: isDeep ? true : state.isSavingDeep,
      isSavingUpholstery: !isDeep ? true : state.isSavingUpholstery,
      error: null,
    ));
    _loader.show();
    try {
      final request = AutoBidConfigRequest(
        serviceType: event.serviceType,
        isEnabled: isDeep ? state.deepEnabled : state.upholsteryEnabled,
        deepCleaningPricing: isDeep ? state.deepCleaningPricing : null,
        upholsteryPricing: !isDeep ? state.upholsteryPricing : null,
      );
      final config = await upsertConfigUseCase.call(request);
      _loader.hide();
      emit(state.copyWith(
        isSavingDeep: isDeep ? false : state.isSavingDeep,
        isSavingUpholstery: !isDeep ? false : state.isSavingUpholstery,
        deepCleaningPricing:
            config.deepCleaningPricing ?? state.deepCleaningPricing,
        upholsteryPricing: config.upholsteryPricing ?? state.upholsteryPricing,
        deepEnabled:
            isDeep ? (config.isEnabled ?? state.deepEnabled) : state.deepEnabled,
        upholsteryEnabled: !isDeep
            ? (config.isEnabled ?? state.upholsteryEnabled)
            : state.upholsteryEnabled,
        error: null,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(
        isSavingDeep: isDeep ? false : state.isSavingDeep,
        isSavingUpholstery: !isDeep ? false : state.isSavingUpholstery,
        error: e.toString(),
      ));
    }
  }
}
