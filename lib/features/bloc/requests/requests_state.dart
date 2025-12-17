import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:equatable/equatable.dart';

class RequestsState extends Equatable {
  final List<CleaningRequest> all;
  final List<CleaningRequest> exclusive;
  final bool hasMoreAll;
  final bool hasMoreExclusive;
  final bool isLoadingAll;
  final bool isLoadingExclusive;
  final String? error;

  const RequestsState({
    this.all = const [],
    this.exclusive = const [],
    this.hasMoreAll = true,
    this.hasMoreExclusive = true,
    this.isLoadingAll = false,
    this.isLoadingExclusive = false,
    this.error,
  });

  RequestsState copyWith({
    List<CleaningRequest>? all,
    List<CleaningRequest>? exclusive,
    bool? hasMoreAll,
    bool? hasMoreExclusive,
    bool? isLoadingAll,
    bool? isLoadingExclusive,
    String? error,
  }) {
    return RequestsState(
      all: all ?? this.all,
      exclusive: exclusive ?? this.exclusive,
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      hasMoreExclusive: hasMoreExclusive ?? this.hasMoreExclusive,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      isLoadingExclusive: isLoadingExclusive ?? this.isLoadingExclusive,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        all,
        exclusive,
        hasMoreAll,
        hasMoreExclusive,
        isLoadingAll,
        isLoadingExclusive,
        error
      ];
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
