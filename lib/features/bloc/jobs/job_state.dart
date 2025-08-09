import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:equatable/equatable.dart';

class JobState extends Equatable {
  final List<CleaningRequest> all;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  const JobState({
    this.all = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  JobState copyWith({
    List<CleaningRequest>? all,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return JobState(
      all: all ?? this.all,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [all, hasMore, isLoading, error];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class UpcomingJobsLoaded extends JobState {
  final List<CleaningRequest> jobs;

  const UpcomingJobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class CompletedJobsLoaded extends JobState {
  final List<CleaningRequest> jobs;

  const CompletedJobsLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobStarted extends JobState {
  final CleaningRequest job;

  const JobStarted(this.job);

  @override
  List<Object?> get props => [job];
}

class JobCompleted extends JobState {
  final CleaningRequest job;

  const JobCompleted(this.job);

  @override
  List<Object?> get props => [job];
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
