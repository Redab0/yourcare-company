import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'housekeeping_pricing_service.g.dart';

@RestApi()
abstract class HousekeepingPricingService {
  factory HousekeepingPricingService(Dio dio, {String baseUrl}) =
      _HousekeepingPricingService;

  @GET('/company/housekeeping-pricing')
  Future<ApiResponse<ResponsePayload<HousekeepingPricing>>>
      getHousekeepingPricing();

  @POST('/company/housekeeping-pricing')
  Future<ApiResponse<ResponsePayload<HousekeepingPricing>>>
      upsertHousekeepingPricing(
    @Body() HousekeepingPricingRequest request,
  );

  @POST('/company/housekeeping-pricing/area-fees')
  Future<ApiResponse<ResponsePayload<dynamic>>> upsertAreaFee(
    @Body() HousekeepingAreaFeeRequest request,
  );
}
