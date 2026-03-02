import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/domain/usecases/housekeeping/get_housekeeping_pricing_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/housekeeping/upsert_housekeeping_area_fee_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/housekeeping/upsert_housekeeping_pricing_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_areas_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HousekeepingPricingBloc
    extends Bloc<HousekeepingPricingEvent, HousekeepingPricingState> {
  final getPricingUseCase = sl<GetHousekeepingPricingUseCase>();
  final upsertPricingUseCase = sl<UpsertHousekeepingPricingUseCase>();
  final upsertAreaFeeUseCase = sl<UpsertHousekeepingAreaFeeUseCase>();
  final getAreasUseCase = sl<GetAreasUseCase>();
  final _loader = sl<LoadingController>();

  HousekeepingPricingBloc() : super(const HousekeepingPricingInitial()) {
    on<LoadHousekeepingConfig>(_onLoadConfig);
    on<UpdateBasePrice>(_onUpdateBasePrice);
    on<ToggleHousekeepingActive>(_onToggleActive);
    on<UpdateAreaFee>(_onUpdateAreaFee);
    on<SaveHousekeepingPricing>(_onSavePricing);
  }

  FutureOr<void> _onLoadConfig(
    LoadHousekeepingConfig event,
    Emitter<HousekeepingPricingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    _loader.show();
    try {
      final results = await Future.wait([
        getAreasUseCase.execute(),
        getPricingUseCase.call(),
      ]);
      final areas = (results[0] as List).cast<AreaResponse>();
      final pricing = results[1] as HousekeepingPricing?;

      final fees = <String, double>{};
      for (final fee in pricing?.areaFees ?? const <HousekeepingAreaFee>[]) {
        final id = fee.areaId ?? fee.area?.id;
        if (id == null) continue;
        fees[id] = fee.fee ?? 0;
      }
      _loader.hide();
      emit(state.copyWith(
        isLoading: false,
        areas: areas,
        basePrice: pricing?.basePricePerCleanerPerHour ?? 0,
        isActive: pricing?.isActive ?? true,
        areaFees: fees,
        error: null,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onUpdateBasePrice(
    UpdateBasePrice event,
    Emitter<HousekeepingPricingState> emit,
  ) {
    emit(state.copyWith(basePrice: event.basePrice, error: null));
  }

  FutureOr<void> _onToggleActive(
    ToggleHousekeepingActive event,
    Emitter<HousekeepingPricingState> emit,
  ) {
    emit(state.copyWith(isActive: event.isActive, error: null));
  }

  FutureOr<void> _onUpdateAreaFee(
    UpdateAreaFee event,
    Emitter<HousekeepingPricingState> emit,
  ) async {
    final previous = state.areaFees[event.areaId] ?? 0;
    final updated = Map<String, double>.from(state.areaFees)
      ..[event.areaId] = event.fee;
    emit(state.copyWith(areaFees: updated, error: null));

    try {
      await upsertAreaFeeUseCase.call(
          HousekeepingAreaFeeRequest(areaId: event.areaId, fee: event.fee));
    } catch (e) {
      final reverted = Map<String, double>.from(updated)
        ..[event.areaId] = previous;
      emit(state.copyWith(areaFees: reverted, error: e.toString()));
    }
  }

  FutureOr<void> _onSavePricing(
    SaveHousekeepingPricing event,
    Emitter<HousekeepingPricingState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null));
    _loader.show();
    try {
      final request = HousekeepingPricingRequest(
        basePricePerCleanerPerHour: state.basePrice,
        areaFees: state.areaFees.entries
            .map((entry) => HousekeepingAreaFee(
                  areaId: entry.key,
                  fee: entry.value,
                ))
            .toList(),
        isActive: state.isActive,
      );
      final pricing = await upsertPricingUseCase.call(request);
      final fees = <String, double>{};
      for (final fee in pricing.areaFees ?? const <HousekeepingAreaFee>[]) {
        final id = fee.areaId ?? fee.area?.id;
        if (id == null) continue;
        fees[id] = fee.fee ?? 0;
      }
      _loader.hide();
      emit(state.copyWith(
        isSaving: false,
        basePrice: pricing.basePricePerCleanerPerHour ?? state.basePrice,
        isActive: pricing.isActive ?? state.isActive,
        areaFees: fees.isEmpty ? state.areaFees : fees,
        error: null,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}
