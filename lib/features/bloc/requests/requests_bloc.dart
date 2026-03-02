import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
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

  List<CleaningRequest> _excludeExclusive(
      List<CleaningRequest> all, List<CleaningRequest> exclusive) {
    if (exclusive.isEmpty) return all;
    final ids = <String>{};
    for (final req in exclusive) {
      final id = req.id;
      if (id != null) ids.add(id);
    }
    if (ids.isEmpty) return all;
    return all.where((req) => req.id == null || !ids.contains(req.id)).toList();
  }

  FutureOr<void> _onFirstPage(
      FetchFirstPageRequests event, Emitter<RequestsState> emit) async {
    _allPage = 1;
    emit(state.copyWith(isLoadingAll: true, error: null));
    // _loader.show();
    try {
      final page = await getRequestsUseCase.call(_allPage, _pageSize);
      // _loader.hide();
      final filtered = _excludeExclusive(page.docs, state.exclusive);
      emit(state.copyWith(
        all: filtered,
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
      final filtered = _excludeExclusive(merged, state.exclusive);
      emit(state.copyWith(
        all: filtered,
        hasMoreAll: page.hasNextPage,
        isLoadingAll: false,
      ));
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoadingAll: false, error: e.toString()));
    }
  }

  FutureOr<void> _onExclusiveFirstPage(FetchExclusivesFirstPageRequests event,
      Emitter<RequestsState> emit) async {
    _exclusivePage = 1;
    emit(state.copyWith(isLoadingExclusive: true, error: null));
    // _loader.show();
    try {
      final page = await getExclusivesUseCase.call(_exclusivePage, _pageSize);
      // _loader.hide();
      final filteredAll = _excludeExclusive(state.all, page.docs);
      emit(state.copyWith(
        exclusive: page.docs,
        all: filteredAll,
        hasMoreExclusive: page.hasNextPage,
        isLoadingExclusive: false,
      ));
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoadingExclusive: false, error: e.toString()));
    }
  }

  FutureOr<void> _onExclusivesNextPage(FetchExclusivesNextPageRequests event,
      Emitter<RequestsState> emit) async {
    if (!state.hasMoreExclusive || state.isLoadingExclusive) return;
    emit(state.copyWith(isLoadingExclusive: true));
    // _loader.show();
    try {
      _exclusivePage++;
      final page = await getExclusivesUseCase.call(_exclusivePage, _pageSize);
      // _loader.hide();
      final updatedExclusive = [...state.exclusive, ...page.docs];
      final filteredAll = _excludeExclusive(state.all, updatedExclusive);
      emit(state.copyWith(
        exclusive: updatedExclusive,
        all: filteredAll,
        hasMoreExclusive: page.hasNextPage,
        isLoadingExclusive: false,
      ));
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoadingExclusive: false, error: e.toString()));
    }
  }
}
