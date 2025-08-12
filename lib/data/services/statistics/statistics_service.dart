import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'statistics_service.g.dart';

@RestApi()
abstract class StatisticsService {
  factory StatisticsService(Dio dio, {String baseUrl}) = _StatisticsService;

  @GET('/company/requests/reports/statistics')
  Future<ApiResponse<ResponsePayload<StatisticsResponse>>>
      getRequestsStatistics();
}
