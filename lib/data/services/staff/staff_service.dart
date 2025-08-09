import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_response.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/update_user_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'staff_service.g.dart';

@RestApi()
abstract class StaffService {
  factory StaffService(Dio dio, {String baseUrl}) = _StaffService;

  @GET('/permissions')
  Future<ApiResponse<ResponsePayload<List<PermissionModel>>>> getPermissions();

  @POST('/permissions/assign')
  Future<ApiResponse<ResponsePayload<User>>> assignPermission(
    @Body() AssignPermissionModel body,
  );

  @GET('permissions/user/{userId}')
  Future<ApiResponse<ResponsePayload<User>>> getPermissionsForUser(
    @Path('userId') String userId,
  );

  @GET('/business-company/users')
  Future<ApiResponse<ResponsePayload<PaginatedData<User>>>> getUsers(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/business-company/users')
  Future<ApiResponse<ResponsePayload<User>>> createUser(
    @Body() CreateUserModel model,
  );

  @PATCH('/business-company/users/{id}')
  Future<ApiResponse<ResponsePayload<User>>> updateUser(
    @Body() UpdateUserModel model,
    @Path('id') String id,
  );

  @POST('/teams')
  Future<ApiResponse<ResponsePayload<CreateTeamResponse>>> createTeam(
    @Body() CreateTeamModel model,
  );

  @PATCH('/teams/{id}')
  Future<ApiResponse<ResponsePayload<CreateTeamResponse>>> updateTeam(
    @Body() CreateTeamModel model,
    @Path('id') String id,
  );

  @GET('/teams/my-company')
  Future<ApiResponse<ResponsePayload<List<TeamModel>>>> getTeams();

  @GET("/users/{id}")
  Future<ApiResponse<ResponsePayload<User>>> getUser(
    @Path('id') String id,
  );
}
