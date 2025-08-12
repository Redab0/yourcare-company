import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:cleaning_service_driver/data/repositories/statistics/statistics_repository.dart';

class GetRequestsStatistics {
  final StatisticsRepository _statisticsRepository;

  GetRequestsStatistics(this._statisticsRepository);

  Future<StatisticsResponse> call() async {
    try {
      return _statisticsRepository.getRequestsStatistics();
    } catch (e) {
      throw Exception('Getting Requests Statistics Failed $e');
    }
  }
}
