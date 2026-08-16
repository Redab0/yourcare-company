import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'car_wash_service.g.dart';

@RestApi()
abstract class CarWashService {
  factory CarWashService(Dio dio, {String baseUrl}) = _CarWashService;

  @GET('/business-categories/car-wash')
  Future<ApiResponse<ResponsePayload<CarWashCategoryResponse>>>
      getCarWashCategories();

  @GET('/business/my-business/car-wash-packages')
  Future<ApiResponse<ResponsePayload<dynamic>>> getMyCarWashPackages();

  @POST('/business/my-business/car-wash-packages')
  Future<ApiResponse<ResponsePayload<dynamic>>> createMyCarWashPackage(
    @Body() Map<String, dynamic> request,
  );

  @PATCH('/business/my-business/car-wash-packages/{packageId}')
  Future<ApiResponse<ResponsePayload<dynamic>>> updateMyCarWashPackage(
    @Path('packageId') String packageId,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/business/my-business/car-wash-packages/{packageId}')
  Future<ApiResponse<ResponsePayload<dynamic>>> deleteMyCarWashPackage(
    @Path('packageId') String packageId,
  );

  @PATCH('/business/my-business/car-wash-pricing')
  Future<ApiResponse<ResponsePayload<dynamic>>> updateMyCarWashPricing(
    @Body() Map<String, dynamic> request,
  );

  @POST('/business/my-business/car-wash-area-fees')
  Future<ApiResponse<ResponsePayload<dynamic>>> upsertMyCarWashAreaFee(
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/business/my-business/car-wash-area-fees/{areaId}')
  Future<ApiResponse<ResponsePayload<dynamic>>> deleteMyCarWashAreaFee(
    @Path('areaId') String areaId,
  );

  @PATCH('/business/my-business/car-wash-working-hours')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateMyCarWashWorkingHours(
    @Body() CarWashWorkingHoursRequest request,
  );
}
