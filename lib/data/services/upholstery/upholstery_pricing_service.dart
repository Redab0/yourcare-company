import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'upholstery_pricing_service.g.dart';

@RestApi()
abstract class UpholsteryPricingService {
  factory UpholsteryPricingService(Dio dio, {String baseUrl}) =
      _UpholsteryPricingService;

  @GET('/business-categories/active')
  Future<ApiResponse<ResponsePayload<List<UpholsteryBusinessCategory>>>>
      getActiveCategories(
    @Header('Accept-Language') String languageCode,
  );

  @GET('/business/my-business/upholstery-packages')
  Future<ApiResponse<ResponsePayload<List<UpholsteryPricingGroup>>>>
      getMyUpholsteryPackages();

  @PATCH('/business/my-business/upholstery-pricing')
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateMyUpholsteryPricing(
    @Body() UpholsteryPricingRequest request,
  );
}
