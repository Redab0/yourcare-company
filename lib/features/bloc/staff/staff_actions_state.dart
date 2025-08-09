import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_response.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:equatable/equatable.dart';

class StaffActionState extends Equatable {
  const StaffActionState();
  @override
  List<Object?> get props => [];
}

class PermissionsFetched extends StaffActionState {
  final List<PermissionModel> permission;
  const PermissionsFetched(this.permission);
  @override
  List<Object> get props => [permission];
}

class UserPermissionUpdated extends StaffActionState {
  final User user;
  const UserPermissionUpdated(this.user);
  @override
  List<Object> get props => [user];
}

class UserCreatedState extends StaffActionState {
  final User user;
  const UserCreatedState(this.user);
  @override
  List<Object> get props => [user];
}

class StaffActionInitial extends StaffActionState {}

class StaffActionFailure extends StaffActionState {
  final String message;

  const StaffActionFailure(this.message);

  @override
  List<Object> get props => [message];
}

class MediaUploaded extends StaffActionState {
  final List<MediaUploadResponse> media;
  const MediaUploaded(this.media);

  @override
  List<Object> get props => [media];
}

class UserUpdatedState extends StaffActionState {
  final User user;
  const UserUpdatedState(this.user);
  @override
  List<Object> get props => [user];
}

class TeamCreatedState extends StaffActionState {
  final CreateTeamResponse response;

  const TeamCreatedState(this.response);
  @override
  List<Object> get props => [response];
}

class TeamUpdatedState extends StaffActionState {
  final CreateTeamResponse response;

  const TeamUpdatedState(this.response);
  @override
  List<Object> get props => [response];
}
