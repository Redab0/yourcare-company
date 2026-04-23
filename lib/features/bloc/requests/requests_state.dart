import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:equatable/equatable.dart';

class RequestsState extends Equatable {
  final List<CleaningRequest> all;
  final bool hasMoreAll;
  final bool isLoadingAll;
  final String? error;

  const RequestsState({
    this.all = const [],
    this.hasMoreAll = true,
    this.isLoadingAll = false,
    this.error,
  });

  RequestsState copyWith({
    List<CleaningRequest>? all,
    bool? hasMoreAll,
    bool? isLoadingAll,
    String? error,
  }) {
    return RequestsState(
      all: all ?? this.all,
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      error: error,
    );
  }

  @override
  List<Object?> get props => [all, hasMoreAll, isLoadingAll, error];
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
