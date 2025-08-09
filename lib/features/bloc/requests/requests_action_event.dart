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

  const SubmitOffer(this.description, this.totalPrice, this.requestId);
  @override
  List<Object> get props => [requestId, totalPrice, description];
}

class ObtainHouseKeepingRequest extends RequestsActionEvent {
  final AcceptHouseKeepingModel? acceptHouseKeepingModel;
  final String requestId;

  const ObtainHouseKeepingRequest(
      {required this.requestId, this.acceptHouseKeepingModel});

  @override
  List<Object?> get props => [requestId, acceptHouseKeepingModel];
}

class FetchWorkersEvent extends RequestsActionEvent {}
