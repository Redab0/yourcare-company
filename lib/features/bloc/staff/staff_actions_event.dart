import 'dart:io';

import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/models/staff/update_user_model.dart';
import 'package:equatable/equatable.dart';

abstract class StaffActionEvent extends Equatable {
  const StaffActionEvent();
  @override
  List<Object> get props => [];
}

class FetchPermissionsEvent extends StaffActionEvent {}

class CreateUserEvent extends StaffActionEvent {
  final CreateUserModel model;
  const CreateUserEvent(this.model);
  @override
  List<Object> get props => [model];
}

class AssignPermissionsEvent extends StaffActionEvent {
  final AssignPermissionModel model;
  const AssignPermissionsEvent(this.model);
  @override
  List<Object> get props => [model];
}

class UploadMediaEvent extends StaffActionEvent {
  final List<File> files;
  const UploadMediaEvent(this.files);

  @override
  List<Object> get props => [files];
}

class UpdateUserEvent extends StaffActionEvent {
  final UpdateUserModel model;
  final String id;
  const UpdateUserEvent(this.model, this.id);
  @override
  List<Object> get props => [model, id];
}

class CreateTeamEvent extends StaffActionEvent {
  final CreateTeamModel model;

  const CreateTeamEvent(this.model);
  @override
  List<Object> get props => [model];
}

class UpdateTeamEvent extends StaffActionEvent {
  final CreateTeamModel model;
  final String id;

  const UpdateTeamEvent(this.model, this.id);
  @override
  List<Object> get props => [model, id];
}
