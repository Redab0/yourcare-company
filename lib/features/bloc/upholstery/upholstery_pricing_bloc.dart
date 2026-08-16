import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/get_upholstery_pricing_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/update_upholstery_pricing_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class UpholsteryPricingBloc
    extends Bloc<UpholsteryPricingEvent, UpholsteryPricingState> {
  final GetUpholsteryPricingConfigUseCase _getConfigUseCase;
  final UpdateUpholsteryPricingUseCase _updatePricingUseCase;
  final LoadingController _loader;
  final Uuid _uuid;

  UpholsteryPricingBloc({
    GetUpholsteryPricingConfigUseCase? getConfigUseCase,
    UpdateUpholsteryPricingUseCase? updatePricingUseCase,
    LoadingController? loader,
    Uuid uuid = const Uuid(),
  })  : _getConfigUseCase =
            getConfigUseCase ?? sl<GetUpholsteryPricingConfigUseCase>(),
        _updatePricingUseCase =
            updatePricingUseCase ?? sl<UpdateUpholsteryPricingUseCase>(),
        _loader = loader ?? sl<LoadingController>(),
        _uuid = uuid,
        super(const UpholsteryPricingInitial()) {
    on<LoadUpholsteryPricingConfig>(_onLoadConfig);
    on<ToggleUpholsteryType>(_onToggleType);
    on<UpdateUpholsteryPackagePrice>(_onUpdatePackagePrice);
    on<UpdateUpholsteryPackageDiscount>(_onUpdatePackageDiscount);
    on<UpdateUpholsteryPackageDetails>(_onUpdatePackageDetails);
    on<AddUpholsteryPackage>(_onAddPackage);
    on<RemoveUpholsteryPackage>(_onRemovePackage);
    on<SaveUpholsteryPricing>(_onSavePricing);
  }

  FutureOr<void> _onToggleType(
    ToggleUpholsteryType event,
    Emitter<UpholsteryPricingState> emit,
  ) {
    emit(state.copyWith(
      pricing: state.pricing
          .map((group) => group.upholsteryTypeId == event.upholsteryTypeId
              ? group.copyWith(isEnabled: event.isEnabled)
              : group)
          .toList(growable: false),
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onLoadConfig(
    LoadUpholsteryPricingConfig event,
    Emitter<UpholsteryPricingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    _loader.show();
    try {
      final config = await _getConfigUseCase.call();
      emit(state.copyWith(
        isLoading: false,
        types: config.types,
        pricing: _mergePricing(config.types, config.pricing),
        error: null,
        successMessage: null,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    } finally {
      _loader.hide();
    }
  }

  FutureOr<void> _onUpdatePackagePrice(
    UpdateUpholsteryPackagePrice event,
    Emitter<UpholsteryPricingState> emit,
  ) {
    emit(state.copyWith(
      pricing: _updatePackage(
        event.upholsteryTypeId,
        event.packageRowKey,
        (package) => package.copyWith(price: event.price),
      ),
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onUpdatePackageDiscount(
    UpdateUpholsteryPackageDiscount event,
    Emitter<UpholsteryPricingState> emit,
  ) {
    emit(state.copyWith(
      pricing: _updatePackage(
        event.upholsteryTypeId,
        event.packageRowKey,
        (package) => package.copyWith(
          discountPercentage: event.discountPercentage,
        ),
      ),
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onUpdatePackageDetails(
    UpdateUpholsteryPackageDetails event,
    Emitter<UpholsteryPricingState> emit,
  ) {
    emit(state.copyWith(
      pricing: _updatePackage(
        event.upholsteryTypeId,
        event.packageRowKey,
        (package) => package.copyWith(
          titleEn: event.titleEn ?? package.titleEn,
          titleAr: event.titleAr ?? package.titleAr,
          descriptionEn: event.descriptionEn ?? package.descriptionEn,
          descriptionAr: event.descriptionAr ?? package.descriptionAr,
        ),
      ),
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onAddPackage(
    AddUpholsteryPackage event,
    Emitter<UpholsteryPricingState> emit,
  ) {
    final updated = state.pricing.map((group) {
      if (group.upholsteryTypeId != event.upholsteryTypeId) return group;
      return group.copyWith(
        packages: [
          ...group.packages,
          UpholsteryPricingPackage(localId: _uuid.v4()),
        ],
      );
    }).toList(growable: false);
    emit(state.copyWith(
      pricing: updated,
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onRemovePackage(
    RemoveUpholsteryPackage event,
    Emitter<UpholsteryPricingState> emit,
  ) {
    final updated = state.pricing.map((group) {
      if (group.upholsteryTypeId != event.upholsteryTypeId) return group;
      return group.copyWith(
        packages: group.packages
            .where((package) => package.rowKey != event.packageRowKey)
            .toList(growable: false),
      );
    }).toList(growable: false);
    emit(state.copyWith(
      pricing: updated,
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onSavePricing(
    SaveUpholsteryPricing event,
    Emitter<UpholsteryPricingState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    _loader.show();
    try {
      final requestPricing = state.pricing
          .where((group) => group.isEnabled && group.packages.isNotEmpty)
          .toList(growable: false);
      final saved = await _updatePricingUseCase.call(
        UpholsteryPricingRequest(pricing: requestPricing),
      );
      emit(state.copyWith(
        isSaving: false,
        pricing: _mergePricing(
          state.types,
          saved.isEmpty ? requestPricing : saved,
        ),
        successMessage: 'saved',
        error: null,
      ));
    } catch (error) {
      emit(state.copyWith(isSaving: false, error: error.toString()));
    } finally {
      _loader.hide();
    }
  }

  List<UpholsteryPricingGroup> _updatePackage(
    String upholsteryTypeId,
    String packageRowKey,
    UpholsteryPricingPackage Function(UpholsteryPricingPackage package) update,
  ) {
    return state.pricing.map((group) {
      if (group.upholsteryTypeId != upholsteryTypeId) return group;
      return group.copyWith(
        packages: group.packages
            .map((package) =>
                package.rowKey == packageRowKey ? update(package) : package)
            .toList(growable: false),
      );
    }).toList(growable: false);
  }

  List<UpholsteryPricingGroup> _mergePricing(
    List<UpholsteryType> types,
    List<UpholsteryPricingGroup> saved,
  ) {
    final savedByType = <String, List<UpholsteryPricingPackage>>{};
    for (final group in saved) {
      savedByType[group.upholsteryTypeId] = group.packages;
    }

    return types.where((type) => type.id.isNotEmpty).map((type) {
      final savedPackages = [
        ...(savedByType[type.id] ?? const <UpholsteryPricingPackage>[]),
      ];
      final hasSavedPackages = savedPackages.isNotEmpty;
      final sizePackages = type.sizes.where((size) => size.id.isNotEmpty).map(
        (size) {
          // The pricing API has no sizeId, so persisted size packages are
          // reconciled by their bilingual titles from the active category.
          final matchIndex = savedPackages.indexWhere(
            (package) => _matchesSize(package, size),
          );
          final savedPackage =
              matchIndex < 0 ? null : savedPackages.removeAt(matchIndex);
          return UpholsteryPricingPackage(
            packageId: savedPackage?.packageId,
            localId: 'size:${size.id}',
            sizeId: size.id,
            titleEn: size.titleEn ?? size.titleAr ?? size.title,
            titleAr: size.titleAr ?? size.titleEn ?? size.title,
            descriptionEn:
                size.descriptionEn ?? size.descriptionAr ?? size.description,
            descriptionAr:
                size.descriptionAr ?? size.descriptionEn ?? size.description,
            price: savedPackage?.price ?? size.price,
            discountPercentage: savedPackage?.discountPercentage ?? 0,
          );
        },
      ).toList(growable: false);
      final unmatchedPackages = savedPackages.map((package) {
        if (package.rowKey.isNotEmpty) return package;
        return package.copyWith(localId: _uuid.v4());
      }).toList(growable: false);

      return UpholsteryPricingGroup(
        upholsteryTypeId: type.id,
        packages: [...sizePackages, ...unmatchedPackages],
        isEnabled: hasSavedPackages,
      );
    }).toList(growable: false);
  }

  bool _matchesSize(
    UpholsteryPricingPackage package,
    UpholsterySize size,
  ) {
    final packageTitles = {
      _normalizeTitle(package.titleEn),
      _normalizeTitle(package.titleAr),
    }..remove('');
    final sizeTitles = {
      _normalizeTitle(size.titleEn),
      _normalizeTitle(size.titleAr),
      _normalizeTitle(size.title),
    }..remove('');
    return packageTitles.any(sizeTitles.contains);
  }

  String _normalizeTitle(String? value) =>
      value?.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ?? '';
}
