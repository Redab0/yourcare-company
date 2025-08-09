import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:equatable/equatable.dart';

class JobActionsState extends Equatable {
  const JobActionsState();

  @override
  List<Object?> get props => [];
}

class JobActionsInitial extends JobActionsState {}

class JobStarted extends JobActionsState {}

class JobCompleted extends JobActionsState {}

class JobCanceled extends JobActionsState {}

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
