import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:equatable/equatable.dart';

class JobActionsState extends Equatable {
  const JobActionsState();

  @override
  List<Object?> get props => [];
}

class JobActionsInitial extends JobActionsState {}

class JobStarted extends JobActionsState {
  final CleaningRequest model;
  const JobStarted(this.model);
  @override
  List<Object> get props => [model];
}

class JobCompleted extends JobActionsState {
  final CleaningRequest model;
  const JobCompleted(this.model);
  @override
  List<Object> get props => [model];
}

class JobCanceled extends JobActionsState {}

class MediaUploading extends JobActionsState {}

class JobActionFailed extends JobActionsState {
  final String message;

  const JobActionFailed(this.message);

  @override
  List<Object> get props => [message];
}

class WorkersAssigned extends JobActionsState {
  final CleaningRequest model;

  const WorkersAssigned(this.model);
  @override
  List<Object> get props => [model];
}

class TeamAssigned extends JobActionsState {
  final CleaningRequest model;

  const TeamAssigned(this.model);
  @override
  List<Object> get props => [model];
}

class WorkersFetchedState extends JobActionsState {
  final List<User> workers;
  const WorkersFetchedState(this.workers);

  @override
  List<Object> get props => [workers];
}

class TeamsFetchedState extends JobActionsState {
  final List<TeamModel> teams;
  const TeamsFetchedState(this.teams);

  @override
  List<Object> get props => [teams];
}

class MediaUploaded extends JobActionsState {
  final List<MediaUploadResponse> media;
  const MediaUploaded(this.media);

  @override
  List<Object> get props => [media];
}

class RequestFrequencyUpdated extends JobActionsState {
  final CleaningRequest response;
  const RequestFrequencyUpdated(this.response);
  @override
  List<Object> get props => [response];
}

class ExtraFeesAdded extends JobActionsState {
  final AddExtraFeesRequest request;
  final CleaningRequest? updatedRequest;

  const ExtraFeesAdded({
    required this.request,
    this.updatedRequest,
  });

  @override
  List<Object?> get props => [request, updatedRequest];
}
