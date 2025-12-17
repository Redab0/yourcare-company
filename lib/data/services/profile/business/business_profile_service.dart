import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/profile/area_model.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'business_profile_service.g.dart';

@RestApi()
abstract class BusinessProfileService {
  factory BusinessProfileService(Dio dio, {String baseUrl}) =
      _BusinessProfileService;

  @GET('/business/my-business')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      getCompanyProfile();

  @PATCH('/business/my-business')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateCompanyProfile(
    @Body() UpdateBusinessProfileModel model,
  );

  @GET("/areas/localized")
  Future<ApiResponse<ResponsePayload<List<AreaModel>>>> getAreas();

  @MultiPart()
  @POST("/upload/multiple")
  Future<ApiResponse<ResponsePayload<List<MediaUploadResponse>>>> uploadMedia(
    @Part(name: "images") List<MultipartFile> files,
  );
}
