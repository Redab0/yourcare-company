import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/get_up_coming_jobs_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../jobs/job_state.dart';
import 'job_event.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final getUpComingJobsUseCase = sl<GetUpComingJobsUseCase>();
  final _loader = sl<LoadingController>();

  static const _pageSize = 20;
  int _currentPage = 1;
  String? _lastStatus;
  String? _lastType;
  String? _lastSortBy;
  String? _lastSortOrder;

  JobBloc() : super(JobInitial()) {
    on<LoadJobsEvent>(_onLoadUpcomingJobs);
    on<FetchNextPageRequests>(_onLoadNextUpcomingJobs);
  }

  Future<void> _onLoadUpcomingJobs(
      LoadJobsEvent event, Emitter<JobState> emit) async {
    _currentPage = 1;
    _lastStatus = event.status;
    _lastType = event.type;
    _lastSortBy = event.sortBy ?? 'createdAt';
    _lastSortOrder = event.sortOrder ?? 'desc';
    emit(state.copyWith(isLoading: true, error: null));
    // _loader.show();
    try {
      final page = await getUpComingJobsUseCase.call(
        page: _currentPage,
        limit: _pageSize,
        status: _lastStatus, // nullable
        type: _lastType, // nullable
        sortBy: _lastSortBy, // or null to accept backend default
        sortOrder: _lastSortOrder,
        allowPagination: true,
      );
      // _loader.hide();
      emit(
        state.copyWith(
          all: page.docs,
          hasMore: page.hasNextPage,
          isLoading: false,
        ),
      );
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  FutureOr<void> _onLoadNextUpcomingJobs(
      FetchNextPageRequests event, Emitter<JobState> emit) async {
    final nextPage = _currentPage + 1;
    emit(state.copyWith(isLoading: true, error: null));
    // _loader.show();
    try {
      final page = await getUpComingJobsUseCase.call(
        page: nextPage,
        limit: _pageSize,
        status: _lastStatus,
        type: _lastType,
        sortBy: _lastSortBy,
        sortOrder: _lastSortOrder,
        allowPagination: true,
      );
      // _loader.hide();
      _currentPage = nextPage;
      emit(
        state.copyWith(
          all: [...state.all, ...page.docs],
          hasMore: page.hasNextPage,
          isLoading: false,
        ),
      );
    } catch (e) {
      // _loader.hide();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
