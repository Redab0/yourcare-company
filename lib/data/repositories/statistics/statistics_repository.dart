import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:cleaning_service_driver/data/services/statistics/statistics_service.dart';

class StatisticsRepository {
  final StatisticsService _statisticsService;

  StatisticsRepository(this._statisticsService);

  Future<StatisticsResponse> getRequestsStatistics(
      {String? periodType, String? startDate, String? endDate}) async {
    final response = await _statisticsService.getRequestsStatistics(
      periodType,
      startDate,
      endDate,
    );
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }
}
