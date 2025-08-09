import 'package:equatable/equatable.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobsEvent extends JobEvent {
  final String? type;
  final String? sortBy;
  final String? sortOrder;
  final String? status;

  const LoadJobsEvent({
    this.type,
    this.sortBy,
    this.sortOrder,
    this.status,
  });

  @override
  List<Object?> get props => [type, sortOrder, status, sortBy];
}

class LoadCompletedJobsEvent extends JobEvent {}

class LoadJobDetailsEvent extends JobEvent {
  final String jobId;

  const LoadJobDetailsEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Load page #1 (or refresh)
class FetchFirstPageRequests extends JobEvent {}

/// Load the next page, if any
class FetchNextPageRequests extends JobEvent {}
