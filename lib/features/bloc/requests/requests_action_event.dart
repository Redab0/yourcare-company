import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:equatable/equatable.dart';

abstract class RequestsActionEvent extends Equatable {
  const RequestsActionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitOffer extends RequestsActionEvent {
  final String requestId;
  final double totalPrice;
  final String description;
  final String timeline;

  const SubmitOffer(
      this.description, this.totalPrice, this.requestId, this.timeline);
  @override
  List<Object> get props => [requestId, totalPrice, description, timeline];
}

class SubmitUpholsteryOffer extends RequestsActionEvent {
  final String requestId;
  final double totalPrice;
  final String description;
  final String timeline;

  const SubmitUpholsteryOffer(
      this.description, this.totalPrice, this.requestId, this.timeline);
  @override
  List<Object> get props => [requestId, totalPrice, description, timeline];
}

class ObtainHouseKeepingRequest extends RequestsActionEvent {
  final AcceptHouseKeepingModel? acceptHouseKeepingModel;
  final String requestId;

  const ObtainHouseKeepingRequest(
      {required this.requestId, this.acceptHouseKeepingModel});

  @override
  List<Object?> get props => [requestId, acceptHouseKeepingModel];
}

class AcceptExclusiveRequestEvent extends RequestsActionEvent {
  final String requestId;

  const AcceptExclusiveRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class FetchWorkersEvent extends RequestsActionEvent {}
