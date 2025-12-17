import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_profile_service.g.dart';

@RestApi()
abstract class UserProfileService {
  factory UserProfileService(Dio dio, {String baseUrl}) = _UserProfileService;

  @GET('/users/profile')
  Future<ApiResponse<ResponsePayload<User>>> getUserProfile();
}
