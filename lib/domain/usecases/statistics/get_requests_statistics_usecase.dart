import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:cleaning_service_driver/data/repositories/statistics/statistics_repository.dart';
import 'package:intl/intl.dart';

class GetRequestsStatistics {
  final StatisticsRepository _statisticsRepository;

  GetRequestsStatistics(this._statisticsRepository);

  Future<StatisticsResponse> call(
      {String? periodType, DateTime? startDate, DateTime? endDate}) async {
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      return _statisticsRepository.getRequestsStatistics(
        periodType: periodType,
        startDate: startDate == null ? null : fmt.format(startDate),
        endDate: endDate == null ? null : fmt.format(endDate),
      );
    } catch (e) {
      throw Exception('Getting Requests Statistics Failed $e');
    }
  }
}
