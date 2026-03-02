import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auto_bid_categories_service.g.dart';

@RestApi()
abstract class AutoBidCategoriesService {
  factory AutoBidCategoriesService(Dio dio, {String baseUrl}) =
      _AutoBidCategoriesService;

  @GET('/business/auto-bid/categories/{serviceType}')
  Future<ApiResponse<ResponsePayload<Map<String, dynamic>>>>
      getAutoBidCategories(
    @Path('serviceType') String serviceType,
  );
}
