import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_available_requests_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final getRequestsUseCase = sl<GetAvailableRequestsUseCase>();

  final _loader = sl<LoadingController>();

  static const _pageSize = 20;
  int _currentPage = 1;

  RequestsBloc() : super(RequestsInitial()) {
    on<FetchFirstPageRequests>(_onFirstPage);
    on<FetchNextPageRequests>(_onNextPage);
  }

  FutureOr<void> _onFirstPage(
      FetchFirstPageRequests event, Emitter<RequestsState> emit) async {
    _currentPage = 1;
    emit(state.copyWith(isLoading: true, error: null));
    _loader.show();
    try {
      final page = await getRequestsUseCase.call(_currentPage, _pageSize);
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
      FetchNextPageRequests event, Emitter<RequestsState> emit) async {
    if (!state.hasMore || state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    _loader.show();
    try {
      _currentPage++;
      final page = await getRequestsUseCase.call(_currentPage, _pageSize);
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
}
