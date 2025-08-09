import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/assign_team_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'jobs_service.g.dart';

@RestApi()
abstract class JobsService {
  factory JobsService(Dio dio, {String baseUrl}) = _JobsService;

  @GET('/company/requests')
  Future<ApiResponse<ResponsePayload<PaginatedData<CleaningRequest>>>> getJobs({
    @Query('page') required int page,
    @Query('limit') required int limit,
    @Query('status') String? status,
    @Query('type') String? type,
    @Query('sortBy') String? sortBy,
    @Query('sortOrder') String? sortOrder,
    @Query('allowPagination') bool? allowPagination,
  });

  @PATCH('/requests/{id}/in-progress')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>> startJob(
    @Path('id') String id,
  );

  @PATCH('/requests/{id}/complete')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>> completeJob(
    @Path('id') String id,
  );

  @PATCH('/requests/{id}/cancel')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>> cancelJob(
    @Path('id') String id,
  );

  @PATCH('/company/requests/{id}/assign-cleaners')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>> assignCleaners(
    @Path('id') String id,
    @Body() AcceptHouseKeepingModel model,
  );

  @PATCH('/company/requests/{id}/assign-team')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>> assignTeam(
    @Path('id') String id,
    @Body() AssignTeamModel model,
  );
}
