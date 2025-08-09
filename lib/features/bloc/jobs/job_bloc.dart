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

  JobBloc() : super(JobInitial()) {
    on<LoadJobsEvent>(_onLoadUpcomingJobs);
  }

  Future<void> _onLoadUpcomingJobs(
      LoadJobsEvent event, Emitter<JobState> emit) async {
    _currentPage = 1;
    emit(state.copyWith(isLoading: true, error: null));
    _loader.show();
    try {
      final page = await getUpComingJobsUseCase.call(
        page: _currentPage,
        limit: _pageSize,
        status: event.status, // nullable
        type: event.type, // nullable
        sortBy: 'createdAt', // or null to accept backend default
        sortOrder: 'desc',
        allowPagination: true,
      );
      _loader.hide();
      emit(
        state.copyWith(
          all: page.docs,
          hasMore: page.hasNextPage,
          isLoading: false,
        ),
      );
    } catch (e) {
      _loader.hide();
      print("ERROR $e");
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
