import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/create_car_wash_package_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/delete_car_wash_area_fee_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/delete_car_wash_package_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/get_car_wash_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/update_car_wash_package_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/update_car_wash_pricing_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/update_car_wash_working_hours_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/car_wash/upsert_car_wash_area_fee_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_areas_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_event.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_state.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarWashBloc extends Bloc<CarWashEvent, CarWashState> {
  static const _loadTag = 'car-wash-config';
  static const _packageTag = 'car-wash-package';
  static const _pricingTag = 'car-wash-pricing';
  static const _areaFeeTag = 'car-wash-area-fee';
  static const _hoursTag = 'car-wash-hours';

  final GetCarWashConfigUseCase getConfigUseCase;
  final CreateCarWashPackageUseCase createPackageUseCase;
  final UpdateCarWashPackageUseCase updatePackageUseCase;
  final DeleteCarWashPackageUseCase deletePackageUseCase;
  final UpdateCarWashPricingUseCase updatePricingUseCase;
  final UpsertCarWashAreaFeeUseCase upsertAreaFeeUseCase;
  final DeleteCarWashAreaFeeUseCase deleteAreaFeeUseCase;
  final UpdateCarWashWorkingHoursUseCase updateWorkingHoursUseCase;
  final GetAreasUseCase getAreasUseCase;
  final LoadingController _loader;

  CarWashBloc({
    GetCarWashConfigUseCase? getConfigUseCase,
    CreateCarWashPackageUseCase? createPackageUseCase,
    UpdateCarWashPackageUseCase? updatePackageUseCase,
    DeleteCarWashPackageUseCase? deletePackageUseCase,
    UpdateCarWashPricingUseCase? updatePricingUseCase,
    UpsertCarWashAreaFeeUseCase? upsertAreaFeeUseCase,
    DeleteCarWashAreaFeeUseCase? deleteAreaFeeUseCase,
    UpdateCarWashWorkingHoursUseCase? updateWorkingHoursUseCase,
    GetAreasUseCase? getAreasUseCase,
    LoadingController? loader,
  })  : getConfigUseCase = getConfigUseCase ?? sl<GetCarWashConfigUseCase>(),
        createPackageUseCase =
            createPackageUseCase ?? sl<CreateCarWashPackageUseCase>(),
        updatePackageUseCase =
            updatePackageUseCase ?? sl<UpdateCarWashPackageUseCase>(),
        deletePackageUseCase =
            deletePackageUseCase ?? sl<DeleteCarWashPackageUseCase>(),
        updatePricingUseCase =
            updatePricingUseCase ?? sl<UpdateCarWashPricingUseCase>(),
        upsertAreaFeeUseCase =
            upsertAreaFeeUseCase ?? sl<UpsertCarWashAreaFeeUseCase>(),
        deleteAreaFeeUseCase =
            deleteAreaFeeUseCase ?? sl<DeleteCarWashAreaFeeUseCase>(),
        updateWorkingHoursUseCase =
            updateWorkingHoursUseCase ?? sl<UpdateCarWashWorkingHoursUseCase>(),
        getAreasUseCase = getAreasUseCase ?? sl<GetAreasUseCase>(),
        _loader = loader ?? sl<LoadingController>(),
        super(const CarWashInitial()) {
    on<LoadCarWashConfig>(_onLoadConfig);
    on<CreateCarWashPackage>(_onCreatePackage);
    on<UpdateCarWashPackage>(_onUpdatePackage);
    on<DeleteCarWashPackage>(_onDeletePackage);
    on<ToggleCarWashPackageAssignment>(_onTogglePackageAssignment);
    on<SaveCarWashPricing>(_onSavePricing);
    on<UpsertCarWashAreaFee>(_onUpsertAreaFee);
    on<DeleteCarWashAreaFee>(_onDeleteAreaFee);
    on<UpdateCarWashWorkingHour>(_onUpdateWorkingHour);
    on<RemoveCarWashWorkingHour>(_onRemoveWorkingHour);
    on<ApplyCarWashWorkingHourToWeek>(_onApplyWorkingHourToWeek);
    on<SaveCarWashWorkingHours>(_onSaveWorkingHours);
  }

  FutureOr<void> _onLoadConfig(
    LoadCarWashConfig event,
    Emitter<CarWashState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      successMessage: null,
    ));
    _loader.show(_loadTag);
    try {
      final configFuture = getConfigUseCase.call();
      final areasFuture = getAreasUseCase.execute().catchError(
            (_) => state.areas,
          );
      final config = await configFuture;
      final areas = await areasFuture;
      final cachedHours = _cachedWorkingHours();
      emit(_withConfiguration(
        state,
        categories: config.categories,
        configuration: config.configuration,
        areas: areas,
        workingHours: _mergeWorkingHours(
          cachedHours ?? config.hours,
          fillMissingDays: cachedHours == null && config.hours.isEmpty,
        ),
      ).copyWith(isLoading: false));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    } finally {
      _loader.hide(_loadTag);
    }
  }

  FutureOr<void> _onCreatePackage(
    CreateCarWashPackage event,
    Emitter<CarWashState> emit,
  ) async {
    await _mutatePackage(
      emit,
      mutation: () => createPackageUseCase.call(event.request),
      successMessage: 'packageCreated',
    );
  }

  FutureOr<void> _onUpdatePackage(
    UpdateCarWashPackage event,
    Emitter<CarWashState> emit,
  ) async {
    await _mutatePackage(
      emit,
      mutation: () => updatePackageUseCase.call(
        event.packageId,
        event.request,
      ),
      successMessage: 'packageUpdated',
    );
  }

  FutureOr<void> _onDeletePackage(
    DeleteCarWashPackage event,
    Emitter<CarWashState> emit,
  ) async {
    await _mutatePackage(
      emit,
      mutation: () => deletePackageUseCase.call(event.packageId),
      successMessage: 'packageDeleted',
    );
  }

  Future<void> _mutatePackage(
    Emitter<CarWashState> emit, {
    required Future<void> Function() mutation,
    required String successMessage,
  }) async {
    emit(state.copyWith(
      isSavingPackage: true,
      error: null,
      successMessage: null,
    ));
    _loader.show(_packageTag);
    try {
      await mutation();
      final config = await getConfigUseCase.call();
      emit(_withConfiguration(
        state,
        categories: config.categories,
        configuration: config.configuration,
      ).copyWith(
        isSavingPackage: false,
        successMessage: successMessage,
      ));
    } catch (error) {
      emit(state.copyWith(
        isSavingPackage: false,
        error: error.toString(),
      ));
    } finally {
      _loader.hide(_packageTag);
    }
  }

  FutureOr<void> _onTogglePackageAssignment(
    ToggleCarWashPackageAssignment event,
    Emitter<CarWashState> emit,
  ) {
    final assignments = [...state.assignments];
    var index = assignments.indexWhere(
      (assignment) => assignment.vehicleTypeId == event.vehicleTypeId,
    );
    if (index == -1) {
      assignments.add(CarWashVehiclePackageAssignment(
        vehicleTypeId: event.vehicleTypeId,
      ));
      index = assignments.length - 1;
    }

    final ids = assignments[index].packageIds.toSet();
    if (event.isAssigned) {
      ids.add(event.packageId);
    } else {
      ids.remove(event.packageId);
    }
    assignments[index] = assignments[index].copyWith(
      packageIds: ids.toList(growable: false),
    );
    emit(state.copyWith(
      assignments: assignments,
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onSavePricing(
    SaveCarWashPricing event,
    Emitter<CarWashState> emit,
  ) async {
    emit(state.copyWith(
      isSavingPricing: true,
      error: null,
      successMessage: null,
    ));
    _loader.show(_pricingTag);
    try {
      final assignments = state.assignments
          .where((assignment) => assignment.packageIds.isNotEmpty)
          .toList(growable: false);
      await updatePricingUseCase.call(
        CarWashPricingAssignmentRequest(pricing: assignments),
      );
      final config = await getConfigUseCase.call();
      emit(_withConfiguration(
        state,
        categories: config.categories,
        configuration: config.configuration,
      ).copyWith(
        isSavingPricing: false,
        successMessage: 'assignmentsSaved',
      ));
    } catch (error) {
      emit(state.copyWith(
        isSavingPricing: false,
        error: error.toString(),
      ));
    } finally {
      _loader.hide(_pricingTag);
    }
  }

  FutureOr<void> _onUpsertAreaFee(
    UpsertCarWashAreaFee event,
    Emitter<CarWashState> emit,
  ) async {
    emit(state.copyWith(
      isSavingAreaFee: true,
      error: null,
      successMessage: null,
    ));
    _loader.show(_areaFeeTag);
    try {
      await upsertAreaFeeUseCase.call(
        CarWashAreaFeeRequest(areaId: event.areaId, fee: event.fee),
      );
      final fees = Map<String, double>.from(state.areaFees)
        ..[event.areaId] = event.fee;
      emit(state.copyWith(
        isSavingAreaFee: false,
        areaFees: fees,
        successMessage: 'areaFeeSaved',
      ));
    } catch (error) {
      emit(state.copyWith(
        isSavingAreaFee: false,
        error: error.toString(),
      ));
    } finally {
      _loader.hide(_areaFeeTag);
    }
  }

  FutureOr<void> _onDeleteAreaFee(
    DeleteCarWashAreaFee event,
    Emitter<CarWashState> emit,
  ) async {
    emit(state.copyWith(
      isSavingAreaFee: true,
      error: null,
      successMessage: null,
    ));
    _loader.show(_areaFeeTag);
    try {
      await deleteAreaFeeUseCase.call(event.areaId);
      final fees = Map<String, double>.from(state.areaFees)
        ..remove(event.areaId);
      emit(state.copyWith(
        isSavingAreaFee: false,
        areaFees: fees,
        successMessage: 'areaFeeDeleted',
      ));
    } catch (error) {
      emit(state.copyWith(
        isSavingAreaFee: false,
        error: error.toString(),
      ));
    } finally {
      _loader.hide(_areaFeeTag);
    }
  }

  FutureOr<void> _onUpdateWorkingHour(
    UpdateCarWashWorkingHour event,
    Emitter<CarWashState> emit,
  ) {
    final existingIndex = state.workingHours.indexWhere(
      (hour) => hour.dayOfWeek == event.dayOfWeek,
    );
    final updated = [...state.workingHours];
    final nextHour = CarWashWorkingHour(
      dayOfWeek: event.dayOfWeek,
      startTime: event.startTime,
      endTime: event.endTime,
    );
    if (existingIndex == -1) {
      updated.add(nextHour);
    } else {
      updated[existingIndex] = nextHour;
    }
    updated.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    emit(state.copyWith(
      workingHours: updated,
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onRemoveWorkingHour(
    RemoveCarWashWorkingHour event,
    Emitter<CarWashState> emit,
  ) {
    emit(state.copyWith(
      workingHours: state.workingHours
          .where((hour) => hour.dayOfWeek != event.dayOfWeek)
          .toList(growable: false),
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onApplyWorkingHourToWeek(
    ApplyCarWashWorkingHourToWeek event,
    Emitter<CarWashState> emit,
  ) {
    emit(state.copyWith(
      workingHours: List.generate(
        7,
        (day) => event.hour.copyWith(dayOfWeek: day),
      ),
      error: null,
      successMessage: null,
    ));
  }

  FutureOr<void> _onSaveWorkingHours(
    SaveCarWashWorkingHours event,
    Emitter<CarWashState> emit,
  ) async {
    emit(state.copyWith(
      isSavingWorkingHours: true,
      error: null,
      successMessage: null,
    ));
    _loader.show(_hoursTag);
    try {
      final saved = await updateWorkingHoursUseCase.call(
        CarWashWorkingHoursRequest(hours: state.workingHours),
      );
      emit(state.copyWith(
        isSavingWorkingHours: false,
        workingHours: saved.isEmpty
            ? state.workingHours
            : _mergeWorkingHours(saved, fillMissingDays: false),
        successMessage: 'workingHoursSaved',
      ));
    } catch (error) {
      emit(state.copyWith(
        isSavingWorkingHours: false,
        error: error.toString(),
      ));
    } finally {
      _loader.hide(_hoursTag);
    }
  }

  CarWashState _withConfiguration(
    CarWashState base, {
    required CarWashCategoryResponse categories,
    required CarWashPackagesConfiguration configuration,
    List<AreaResponse>? areas,
    List<CarWashWorkingHour>? workingHours,
  }) {
    final fees = <String, double>{
      for (final fee in configuration.areaFees)
        if (fee.areaId.isNotEmpty) fee.areaId: fee.fee,
    };
    return base.copyWith(
      vehicleTypes: categories.vehicleTypes,
      packages: configuration.packages,
      assignments: _mergeAssignments(
        categories.vehicleTypes,
        configuration.assignments,
      ),
      areaFees: fees,
      areas: areas,
      workingHours: workingHours,
      error: null,
    );
  }

  List<CarWashVehiclePackageAssignment> _mergeAssignments(
    List<CarWashVehicleType> vehicles,
    List<CarWashVehiclePackageAssignment> saved,
  ) {
    final byVehicle = {
      for (final assignment in saved) assignment.vehicleTypeId: assignment,
    };
    return vehicles
        .where((vehicle) => vehicle.id.isNotEmpty)
        .map(
          (vehicle) =>
              byVehicle[vehicle.id] ??
              CarWashVehiclePackageAssignment(vehicleTypeId: vehicle.id),
        )
        .toList(growable: false);
  }

  List<CarWashWorkingHour>? _cachedWorkingHours() {
    if (!sl.isRegistered<CompanyProfileCubit>()) return null;
    return sl<CompanyProfileCubit>().state.profile?.carWashWorkingHours;
  }

  List<CarWashWorkingHour> _mergeWorkingHours(
    List<CarWashWorkingHour> saved, {
    bool fillMissingDays = true,
  }) {
    final byDay = {for (final hour in saved) hour.dayOfWeek: hour};
    if (!fillMissingDays) {
      final hours = byDay.values.toList()
        ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      return hours;
    }
    return List.generate(
      7,
      (day) =>
          byDay[day] ??
          CarWashWorkingHour(
            dayOfWeek: day,
            startTime: '09:00',
            endTime: '21:00',
          ),
    );
  }
}
