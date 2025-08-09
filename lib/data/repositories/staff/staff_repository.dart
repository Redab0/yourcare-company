import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_response.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/update_user_model.dart';
import 'package:cleaning_service_driver/data/services/staff/staff_service.dart';

class StaffRepository {
  final StaffService _staffService;

  StaffRepository(this._staffService);

  Future<List<PermissionModel>> getPermissions() async {
    final response = await _staffService.getPermissions();
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> assignPermissionsToUser(
      AssignPermissionModel assignPermissionModel) async {
    final response =
        await _staffService.assignPermission(assignPermissionModel);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> getUserPermission(String id) async {
    final response = await _staffService.getPermissionsForUser(id);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<PaginatedData<User>> getUsers(int page, int limit) async {
    final response = await _staffService.getUsers(
      page,
      limit,
    );
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> createUser(CreateUserModel model) async {
    final response = await _staffService.createUser(model);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> updateUser(UpdateUserModel model, String id) async {
    final response = await _staffService.updateUser(model, id);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CreateTeamResponse> createTeam(CreateTeamModel model) async {
    final response = await _staffService.createTeam(model);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CreateTeamResponse> updateTeam(
      CreateTeamModel model, String id) async {
    final response = await _staffService.updateTeam(model, id);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<TeamModel>> getTeams() async {
    final response = await _staffService.getTeams();
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> getUser(String userId) async {
    final response = await _staffService.getUser(userId);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }
}
