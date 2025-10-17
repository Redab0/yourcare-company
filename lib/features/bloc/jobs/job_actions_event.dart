import 'dart:io';

import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/complete_job_media_request.dart';
import 'package:equatable/equatable.dart';

abstract class JobActionsEvent extends Equatable {
  const JobActionsEvent();

  @override
  List<Object?> get props => [];
}

class StartJobEvent extends JobActionsEvent {
  final String id;

  const StartJobEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CompleteJobEvent extends JobActionsEvent {
  final String id;
  final CompleteJobRequest? completeJobRequest;

  const CompleteJobEvent(this.id, this.completeJobRequest);

  @override
  List<Object?> get props => [id];
}

class CancelJobEvent extends JobActionsEvent {
  final String id;

  const CancelJobEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AssignWorkersEvent extends JobActionsEvent {
  final String id;
  final AcceptHouseKeepingModel model;

  const AssignWorkersEvent(this.id, this.model);

  @override
  List<Object?> get props => [id, model];
}

class AssignTeamEvent extends JobActionsEvent {
  final String id;
  final String teamId;

  const AssignTeamEvent(this.id, this.teamId);

  @override
  List<Object?> get props => [id, teamId];
}

class FetchWorkersEvent extends JobActionsEvent {}

class FetchTeamsEvent extends JobActionsEvent {}

class UploadMediaEvent extends JobActionsEvent {
  final List<File> files;
  const UploadMediaEvent(this.files);

  @override
  List<Object> get props => [files];
}
