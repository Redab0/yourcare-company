import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auto_bid_categories_service.g.dart';

@RestApi()
abstract class AutoBidCategoriesService {
  factory AutoBidCategoriesService(Dio dio, {String baseUrl}) =
      _AutoBidCategoriesService;

  @GET('/business/auto-bid/categories/{serviceType}')
  Future<ApiResponse<ResponsePayload<AutoBidCategoriesPayload>>>
      getAutoBidCategories(
    @Path('serviceType') String serviceType,
  );
}

/// Keeps the service-discriminated catalog opaque without relying on a
/// generated Map.fromJson constructor (which Dart maps do not provide).
class AutoBidCategoriesPayload {
  const AutoBidCategoriesPayload(this.json);
  final Map<String, dynamic> json;
  factory AutoBidCategoriesPayload.fromJson(Map<String, dynamic> json) =>
      AutoBidCategoriesPayload(json);
  Map<String, dynamic> toJson() => json;
}
