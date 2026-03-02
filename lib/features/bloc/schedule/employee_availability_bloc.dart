import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/create_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/delete_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/get_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/update_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_event.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeAvailabilityBloc
    extends Bloc<EmployeeAvailabilityEvent, EmployeeAvailabilityState> {
  final getAvailabilityUseCase = sl<GetCleanerAvailabilityUseCase>();
  final createAvailabilityUseCase = sl<CreateCleanerAvailabilityUseCase>();
  final updateAvailabilityUseCase = sl<UpdateCleanerAvailabilityUseCase>();
  final deleteAvailabilityUseCase = sl<DeleteCleanerAvailabilityUseCase>();
  final getUsersUseCase = sl<GetAllUsersUseCase>();
  final _loader = sl<LoadingController>();

  EmployeeAvailabilityBloc() : super(EmployeeAvailabilityInitial()) {
    on<LoadAvailabilityData>(_onLoadAvailabilityData);
    on<CreateAvailabilitySlot>(_onCreateAvailability);
    on<UpdateAvailabilitySlot>(_onUpdateAvailability);
    on<DeleteAvailabilitySlot>(_onDeleteAvailability);
  }

  FutureOr<void> _onLoadAvailabilityData(
    LoadAvailabilityData event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final slots = await getAvailabilityUseCase.call();
      final usersPage = await getUsersUseCase.call(1, 200);
      emit(state.copyWith(
        slots: slots,
        employees: usersPage.docs,
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
      final slots = await getAvailabilityUseCase.call();
      _loader.hide();
      emit(state.copyWith(slots: slots, error: null));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(error: e.toString()));
    }
  }

  FutureOr<void> _onUpdateAvailability(
    UpdateAvailabilitySlot event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    _loader.show();
    try {
      await updateAvailabilityUseCase.call(event.id, event.request);
      final slots = await getAvailabilityUseCase.call();
      _loader.hide();
      emit(state.copyWith(slots: slots, error: null));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(error: e.toString()));
    }
  }

  FutureOr<void> _onDeleteAvailability(
    DeleteAvailabilitySlot event,
    Emitter<EmployeeAvailabilityState> emit,
  ) async {
    _loader.show();
    try {
      await deleteAvailabilityUseCase.call(event.id);
      final slots = await getAvailabilityUseCase.call();
      _loader.hide();
      emit(state.copyWith(slots: slots, error: null));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(error: e.toString()));
    }
  }
}
