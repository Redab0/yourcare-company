import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_teams_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final getUsersUseCase = sl<GetAllUsersUseCase>();
  final getTeamsUseCase = sl<GetTeamsUseCase>();
  final _loader = sl<LoadingController>();

  static const _pageSize = 20;
  int _currentPage = 1;

  StaffBloc() : super(StaffInitial()) {
    on<FetchFirstPageStaff>(_onFirstPage);
    on<FetchNextPageStaff>(_onNextPage);
    on<FetchTeams>(_onFetchTeams);
  }

  FutureOr<void> _onFirstPage(
      FetchFirstPageStaff event, Emitter<StaffState> emit) async {
    _currentPage = 1;
    emit(state.copyWith(isLoading: true, error: null));
    _loader.show();
    try {
      final page = await getUsersUseCase.call(_currentPage, _pageSize);
      _loader.hide();
      emit(state.copyWith(
        all: page.docs,
        hasMore: page.hasNextPage,
        isLoading: false,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onNextPage(
      FetchNextPageStaff event, Emitter<StaffState> emit) async {
    if (!state.hasMore || state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    _loader.show();
    try {
      _currentPage++;
      final page = await getUsersUseCase.call(_currentPage, _pageSize);
      _loader.hide();
      emit(state.copyWith(
        all: [...state.all, ...page.docs],
        hasMore: page.hasNextPage,
        isLoading: false,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onFetchTeams(
      FetchTeams event, Emitter<StaffState> emit) async {
    _loader.show();
    try {
      final response = await getTeamsUseCase.call();
      _loader.hide();
      emit(TeamsFetched(response));
    } catch (e) {
      _loader.hide();
      emit(StaffFailure("Request Failed $e"));
    }
  }
}
