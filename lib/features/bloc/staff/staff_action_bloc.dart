import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/upload_media_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/assign_permissions_for_user.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/create_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/create_user_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_permissions_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/update_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/update_user_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaffActionBloc extends Bloc<StaffActionEvent, StaffActionState> {
  final createUsersUseCase = sl<CreateUserUseCase>();
  final assignPermissionsUseCase = sl<AssignPermissionsForUserUseCase>();
  final getAllPermissionUseCase = sl<GetAllPermissionsUseCase>();
  final uploadMediaUseCase = sl<UploadMediaUseCase>();
  final updateUserUseCase = sl<UpdateUserUseCase>();
  final createTeamUseCase = sl<CreateTeamUseCase>();
  final updateTeamUseCase = sl<UpdateTeamUseCase>();
  final _loader = sl<LoadingController>();

  StaffActionBloc() : super(StaffActionInitial()) {
    on<FetchPermissionsEvent>(_fetchPermission);
    on<CreateUserEvent>(_createUser);
    on<AssignPermissionsEvent>(_assignPermission);
    on<UploadMediaEvent>(_upload);
    on<UpdateUserEvent>(_updateUser);
    on<CreateTeamEvent>(_createTeam);
    on<UpdateTeamEvent>(_updateTeam);
  }

  FutureOr<void> _fetchPermission(
      FetchPermissionsEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await getAllPermissionUseCase.call();
      _loader.hide();
      emit(PermissionsFetched(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }

  FutureOr<void> _createUser(
      CreateUserEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await createUsersUseCase.call(event.model);
      _loader.hide();
      emit(UserCreatedState(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }

  FutureOr<void> _assignPermission(
      AssignPermissionsEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await assignPermissionsUseCase.call(event.model);
      _loader.hide();
      emit(UserPermissionUpdated(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }

  FutureOr<void> _upload(
      UploadMediaEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await uploadMediaUseCase.call(event.files);
      _loader.hide();
      emit(MediaUploaded(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }

  FutureOr<void> _updateUser(
      UpdateUserEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await updateUserUseCase.call(event.model, event.id);
      _loader.hide();
      emit(UserUpdatedState(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }

  FutureOr<void> _createTeam(
      CreateTeamEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await createTeamUseCase.call(event.model);
      _loader.hide();
      emit(TeamCreatedState(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }

  FutureOr<void> _updateTeam(
      UpdateTeamEvent event, Emitter<StaffActionState> emit) async {
    _loader.show();
    try {
      final response = await updateTeamUseCase.call(event.model, event.id);
      _loader.hide();
      emit(TeamUpdatedState(response));
    } catch (e) {
      _loader.hide();
      emit(StaffActionFailure("Request Failed $e"));
    }
  }
}
