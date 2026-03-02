import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_employee_calendar_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_teams_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_event.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeCalendarBloc
    extends Bloc<EmployeeCalendarEvent, EmployeeCalendarState> {
  final getEmployeeCalendarUseCase = sl<GetEmployeeCalendarUseCase>();
  final getUsersUseCase = sl<GetAllUsersUseCase>();
  final getTeamsUseCase = sl<GetTeamsUseCase>();
  final _loader = sl<LoadingController>();

  EmployeeCalendarBloc() : super(EmployeeCalendarInitial()) {
    on<FetchEmployeeCalendar>(_onFetchCalendar);
    on<LoadEmployeeCalendarFilters>(_onLoadFilters);
  }

  FutureOr<void> _onFetchCalendar(
    FetchEmployeeCalendar event,
    Emitter<EmployeeCalendarState> emit,
  ) async {
    _loader.show();
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await getEmployeeCalendarUseCase.call(
        startDate: event.startDate,
        endDate: event.endDate,
        employeeId: event.employeeId,
        teamId: event.teamId,
        requestType: event.requestType,
        requestStatus: event.requestStatus,
      );
      _loader.hide();
      emit(state.copyWith(data: response, isLoading: false, error: null));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onLoadFilters(
    LoadEmployeeCalendarFilters event,
    Emitter<EmployeeCalendarState> emit,
  ) async {
    _loader.show();
    emit(state.copyWith(isLoadingFilters: true, error: null));
    try {
      final usersPage = await getUsersUseCase.call(1, 100);
      final teams = await getTeamsUseCase.call();
      _loader.hide();
      emit(
        state.copyWith(
          users: usersPage.docs,
          teams: teams,
          isLoadingFilters: false,
          error: null,
        ),
      );
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoadingFilters: false, error: e.toString()));
    }
  }
}
