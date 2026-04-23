import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/models/profile/custom_service_item_request.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/models/profile/update_covered_service_items_request.dart';
import 'package:cleaning_service_driver/data/models/profile/update_custom_service_item_request.dart';
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

  @GET('/business/my-business/covered-service-items')
  Future<ApiResponse<ResponsePayload<List<CoveredServiceGroup>>>>
      getCoveredServiceItems();

  @PATCH('/business/my-business/covered-service-items')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateCoveredServiceItems(
    @Body() UpdateCoveredServiceItemsRequest model,
  );

  @POST('/business/my-business/custom-service-items')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      createCustomServiceItem(
    @Body() CustomServiceItemRequest model,
  );

  @PATCH('/business/my-business/custom-service-items/{serviceItemId}')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateCustomServiceItem(
    @Path('serviceItemId') String serviceItemId,
    @Body() UpdateCustomServiceItemRequest model,
  );

  @DELETE('/business/my-business/custom-service-items/{serviceItemId}')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      deleteCustomServiceItem(
    @Path('serviceItemId') String serviceItemId,
  );

  @GET("/areas/grouped")
  Future<ApiResponse<ResponsePayload<List<AreaResponse>>>> getAreas();

  @MultiPart()
  @POST("/upload/multiple")
  Future<ApiResponse<ResponsePayload<List<MediaUploadResponse>>>> uploadMedia(
    @Part(name: "images") List<MultipartFile> files,
  );
}
