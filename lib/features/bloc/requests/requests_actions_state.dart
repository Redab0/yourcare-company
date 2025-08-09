import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:equatable/equatable.dart';

class RequestsActionState extends Equatable {
  const RequestsActionState();

  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsActionState {}

class OfferSubmitted extends RequestsActionState {}

class HouseKeepingRequestObtained extends RequestsActionState {
  final CleaningRequest request;

  const HouseKeepingRequestObtained(this.request);
  @override
  List<Object> get props => [request];
}

class RequestsActionFailed extends RequestsActionState {
  final String message;

  const RequestsActionFailed(this.message);

  @override
  List<Object> get props => [message];
}

class WorkersFetchedState extends RequestsActionState {
  final List<User> workers;
  const WorkersFetchedState(this.workers);

  @override
  List<Object> get props => [workers];
}
