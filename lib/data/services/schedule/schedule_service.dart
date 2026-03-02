import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'schedule_service.g.dart';

@RestApi()
abstract class ScheduleService {
  factory ScheduleService(Dio dio, {String baseUrl}) = _ScheduleService;

  @GET('/company/cleaner-availability')
  Future<ApiResponse<ResponsePayload<List<CleanerAvailabilitySlot>>>>
      getCleanerAvailability();

  @POST('/company/cleaner-availability')
  Future<ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>>
      createCleanerAvailability(
    @Body() CleanerAvailabilityRequest body,
  );

  @PATCH('/company/cleaner-availability/{id}')
  Future<ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>>
      updateCleanerAvailability(
    @Path('id') String id,
    @Body() CleanerAvailabilityRequest body,
  );

  @DELETE('/company/cleaner-availability/{id}')
  Future<ApiResponse<ResponsePayload<dynamic>>> deleteCleanerAvailability(
    @Path('id') String id,
  );
}
