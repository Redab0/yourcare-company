import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:equatable/equatable.dart';

class RequestsState extends Equatable {
  final List<CleaningRequest> all;
  final List<CleaningRequest> exclusive;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  const RequestsState({
    this.all = const [],
    this.exclusive = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  RequestsState copyWith({
    List<CleaningRequest>? all,
    List<CleaningRequest>? exclusive,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return RequestsState(
      all: all ?? this.all,
      exclusive: exclusive ?? this.exclusive,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [all, exclusive, hasMore, isLoading, error];
}

class RequestsInitial extends RequestsState {}

class RequestsFailed extends RequestsState {
  final String message;

  const RequestsFailed(this.message);

  @override
  List<Object> get props => [message];
}

class RequestsFetched extends RequestsState {
  final List<CleaningRequest> cleaningRequest;

  const RequestsFetched(this.cleaningRequest);

  @override
  List<Object> get props => [cleaningRequest];
}

class ExclusiveRequestsFetched extends RequestsState {
  final List<CleaningRequest> cleaningRequest;

  const ExclusiveRequestsFetched(this.cleaningRequest);

  @override
  List<Object> get props => [cleaningRequest];
}
