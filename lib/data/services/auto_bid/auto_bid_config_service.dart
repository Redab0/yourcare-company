import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auto_bid_config_service.g.dart';

@RestApi()
abstract class AutoBidConfigService {
  factory AutoBidConfigService(Dio dio, {String baseUrl}) =
      _AutoBidConfigService;

  @GET('/business/auto-bid/config/{serviceType}')
  Future<ApiResponse<ResponsePayload<AutoBidConfig>>> getAutoBidConfig(
    @Path('serviceType') String serviceType,
  );

  @POST('/business/auto-bid/config')
  Future<ApiResponse<ResponsePayload<AutoBidConfig>>> upsertAutoBidConfig(
    @Body() AutoBidConfigRequest request,
  );
}
