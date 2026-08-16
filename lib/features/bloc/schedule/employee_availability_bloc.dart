import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/create_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/delete_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/get_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/update_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_event.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeAvailabilityBloc
    extends Bloc<EmployeeAvailabilityEvent, EmployeeAvailabilityState> {
  final getAvailabilityUseCase = sl<GetCleanerAvailabilityUseCase>();
  final createAvailabilityUseCase = sl<CreateCleanerAvailabilityUseCase>();
  final updateAvailabilityUseCase = sl<UpdateCleanerAvailabilityUseCase>();
  final deleteAvailabilityUseCase = sl<DeleteCleanerAvailabilityUseCase>();
  final _loader = sl<LoadingController>();

  EmployeeAvailabilityBloc() : super(EmployeeAvailabilityInitial()) {
    on<LoadAvailabilityData>(_onLoadAvailabilityData);
    on<CreateAvailabilitySlot>(_onCreateAvailability);
    on<UpdateAvailabilitySlot>(_onUpdateAvailability);
    on<DeleteAvailabilitySlot>(_onDeleteAvailability);
    on<ReplaceAvailabilityDays>(_onReplaceAvailabilityDays);
  }

  FutureOr<void> _onLoadAvailabilityData(
    LoadAvailabilityData event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    emit(state.copyWith(
      slots: const [],
      serviceType: event.serviceType,
      isLoading: true,
      error: null,
    ));
    try {
      final slots = await _loadSlots(event.serviceType);
      emit(state.copyWith(
        slots: slots,
        serviceType: event.serviceType,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onCreateAvailability(
    CreateAvailabilitySlot event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    _loader.show();
    try {
      await createAvailabilityUseCase.call(event.request);
      final slots = await _loadSlots(event.request.serviceType);
      emit(state.copyWith(
        slots: slots,
        serviceType: event.request.serviceType,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      _loader.hide();
    }
  }

  FutureOr<void> _onUpdateAvailability(
    UpdateAvailabilitySlot event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    _loader.show();
    try {
      await updateAvailabilityUseCase.call(event.id, event.request);
      final slots = await _loadSlots(event.request.serviceType);
      emit(state.copyWith(
        slots: slots,
        serviceType: event.request.serviceType,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      _loader.hide();
    }
  }

  FutureOr<void> _onDeleteAvailability(
    DeleteAvailabilitySlot event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    _loader.show();
    try {
      await deleteAvailabilityUseCase.call(event.id);
      final slots = await _loadSlots(event.serviceType);
      emit(state.copyWith(
        slots: slots,
        serviceType: event.serviceType,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      _loader.hide();
    }
  }

  FutureOr<void> _onReplaceAvailabilityDays(
    ReplaceAvailabilityDays event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    if (event.scheduleByDay.isEmpty) return;
    _loader.show();
    try {
      final targetDays = event.scheduleByDay.keys.toSet();
      final existingSlots = await _loadSlots(event.serviceType);
      final slotsToDelete = existingSlots.where((slot) {
        final id = slot.id;
        final day = slot.dayOfWeek;
        return id != null && day != null && targetDays.contains(day);
      }).toList();

      for (final slot in slotsToDelete) {
        await deleteAvailabilityUseCase.call(slot.id!);
      }

      for (final entry in event.scheduleByDay.entries) {
        for (final request in entry.value) {
          await createAvailabilityUseCase.call(request);
        }
      }

      final slots = await _loadSlots(event.serviceType);
      emit(state.copyWith(
        slots: slots,
        serviceType: event.serviceType,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      _loader.hide();
    }
  }

  Future<List<CleanerAvailabilitySlot>> _loadSlots(
    AvailabilityServiceType serviceType,
  ) async {
    return getAvailabilityUseCase.call(serviceType);
  }
}
