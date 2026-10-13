import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:cleaning_service_driver/data/viewmodels/stats_vm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps car-wash request totals from the statistics response', () {
    final response = StatisticsResponse.fromJson({
      'overview': {
        'totalRequests': 12,
        'deepCleaningRequests': 2,
        'houseCleaningRequests': 3,
        'upholsteryCleaningRequests': 1,
        'carWashRequests': 6,
        'carWashRevenue': 91,
      },
      'periodStats': [
        {
          'period': '2026-08',
          'periodLabel': 'August 2026',
          'count': 12,
          'revenue': 140.5,
          'carWashCount': 6,
          'carWashRevenue': 91,
        },
      ],
      'monthlyStats': [
        {'month': 8, 'count': 12, 'revenue': 140.5},
      ],
      'periodType': 'monthly',
      'startDate': null,
      'endDate': null,
    });

    expect(response.overview?.carWashRequests, 6);
    expect(response.overview?.carWashRevenue, 91);
    expect(response.periodStats?.single.carWashCount, 6);
    expect(response.periodStats?.single.carWashRevenue, 91);
    expect(response.periodType, 'monthly');

    final viewModel = StatsVM.fromResponse(response);
    expect(viewModel.carWash, 6);
    expect(viewModel.carWashRevenue, 91);
    expect(viewModel.periods.single.carWashCount, 6);
    expect(viewModel.periods.single.carWashRevenue, 91);
    expect(viewModel.total, 12);
    expect(viewModel.monthly.single.revenue, 140.5);
  });

  test('defaults a missing car-wash total to zero for older responses', () {
    final response = StatisticsResponse.fromJson({
      'overview': {'totalRequests': 1},
      'monthlyStats': <Map<String, dynamic>>[],
    });

    expect(StatsVM.fromResponse(response).carWash, 0);
  });
}
