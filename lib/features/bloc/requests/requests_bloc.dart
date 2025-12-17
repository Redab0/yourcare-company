import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_available_requests_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_exclusives_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final getRequestsUseCase = sl<GetAvailableRequestsUseCase>();
  final getExclusivesUseCase = sl<GetExclusivesUseCase>();

  final _loader = sl<LoadingController>();

  static const _pageSize = 20;
  int _allPage = 1;
  int _exclusivePage = 1;

  RequestsBloc() : super(RequestsInitial()) {
    on<FetchFirstPageRequests>(_onFirstPage);
    on<FetchNextPageRequests>(_onNextPage);
    on<FetchExclusivesFirstPageRequests>(_onExclusiveFirstPage);
    on<FetchExclusivesNextPageRequests>(_onExclusivesNextPage);
  }

  FutureOr<void> _onFirstPage(
      FetchFirstPageRequests event, Emitter<RequestsState> emit) async {
    _allPage = 1;
    emit(state.copyWith(isLoadingAll: true, error: null));
    _loader.show();
    try {
      final page = await getRequestsUseCase.call(_allPage, _pageSize);
      _loader.hide();
      emit(state.copyWith(
        all: page.docs,
        hasMoreAll: page.hasNextPage,
        isLoadingAll: false,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoadingAll: false, error: e.toString()));
    }
  }

  FutureOr<void> _onNextPage(
      FetchNextPageRequests event, Emitter<RequestsState> emit) async {
    if (!state.hasMoreAll || state.isLoadingAll) return;
    emit(state.copyWith(isLoadingAll: true));
    _loader.show();
    try {
      _allPage++;
      final page = await getRequestsUseCase.call(_allPage, _pageSize);
      _loader.hide();
      emit(state.copyWith(
        all: [...state.all, ...page.docs],
        hasMoreAll: page.hasNextPage,
        isLoadingAll: false,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoadingAll: false, error: e.toString()));
    }
  }

  FutureOr<void> _onExclusiveFirstPage(FetchExclusivesFirstPageRequests event,
      Emitter<RequestsState> emit) async {
    _exclusivePage = 1;
    emit(state.copyWith(isLoadingExclusive: true, error: null));
    _loader.show();
    try {
      final page = await getExclusivesUseCase.call(_exclusivePage, _pageSize);
      _loader.hide();
      emit(state.copyWith(
        exclusive: page.docs,
        hasMoreExclusive: page.hasNextPage,
        isLoadingExclusive: false,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoadingExclusive: false, error: e.toString()));
    }
  }

  FutureOr<void> _onExclusivesNextPage(FetchExclusivesNextPageRequests event,
      Emitter<RequestsState> emit) async {
    if (!state.hasMoreExclusive || state.isLoadingExclusive) return;
    emit(state.copyWith(isLoadingExclusive: true));
    _loader.show();
    try {
      _exclusivePage++;
      final page = await getExclusivesUseCase.call(_exclusivePage, _pageSize);
      _loader.hide();
      emit(state.copyWith(
        exclusive: [...state.exclusive, ...page.docs],
        hasMoreExclusive: page.hasNextPage,
        isLoadingExclusive: false,
      ));
    } catch (e) {
      _loader.hide();
      emit(state.copyWith(isLoadingExclusive: false, error: e.toString()));
    }
  }
}
