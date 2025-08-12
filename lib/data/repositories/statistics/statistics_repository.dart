import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:cleaning_service_driver/data/services/statistics/statistics_service.dart';

class StatisticsRepository {
  final StatisticsService _statisticsService;

  StatisticsRepository(this._statisticsService);

  Future<StatisticsResponse> getRequestsStatistics() async {
    final response = await _statisticsService.getRequestsStatistics();
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }
}
