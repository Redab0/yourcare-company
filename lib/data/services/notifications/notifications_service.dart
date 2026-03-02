import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/notifications/register_token.dart';
import 'package:cleaning_service_driver/data/models/notifications/register_token_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notifications_service.g.dart';

@RestApi()
abstract class NotificationsService {
  factory NotificationsService(Dio dio, {String baseUrl}) =
      _NotificationsService;

  @POST("/notifications/register-token")
  Future<ApiResponse<ResponsePayload<RegisterTokenResponse>>>
      registerDeviceToken(
    @Body() RegisterToken registerToken,
  );

  @POST("/notifications/deactivate-token")
  Future<ApiResponse<ResponsePayload<RegisterTokenResponse>>>
      deactivateDeviceToken(
    @Body() RegisterToken registerToken,
  );
}
