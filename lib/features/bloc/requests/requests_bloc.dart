import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_available_requests_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final getRequestsUseCase = sl<GetAvailableRequestsUseCase>();

  static const _pageSize = 20;
  int _allPage = 1;

  RequestsBloc() : super(RequestsInitial()) {
    on<FetchFirstPageRequests>(_onFirstPage);
    on<FetchNextPageRequests>(_onNextPage);
  }

  FutureOr<void> _onFirstPage(
      FetchFirstPageRequests event, Emitter<RequestsState> emit) async {
    _allPage = 1;
    emit(state.copyWith(isLoadingAll: true, error: null));
    // _loader.show();
    try {
      final page = await getRequestsUseCase.call(_allPage, _pageSize);
      // _loader.hide();
      emit(state.copyWith(
        all: page.docs,
        hasMoreAll: page.hasNextPage,
        isLoadingAll: false,
      ));
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoadingAll: false, error: e.toString()));
    }
  }

  FutureOr<void> _onNextPage(
      FetchNextPageRequests event, Emitter<RequestsState> emit) async {
    if (!state.hasMoreAll || state.isLoadingAll) return;
    emit(state.copyWith(isLoadingAll: true));
    // _loader.show();
    try {
      _allPage++;
      final page = await getRequestsUseCase.call(_allPage, _pageSize);
      // _loader.hide();
      final merged = [...state.all, ...page.docs];
      emit(state.copyWith(
        all: merged,
        hasMoreAll: page.hasNextPage,
        isLoadingAll: false,
      ));
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoadingAll: false, error: e.toString()));
    }
  }
}
