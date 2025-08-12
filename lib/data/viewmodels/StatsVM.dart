import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';

class MonthlyStatVM {
  final int month;
  final int count;
  final num revenue;
  MonthlyStatVM(
      {required this.month, required this.count, required this.revenue});
}

class StatsVM {
  final int total,
      pending,
      confirmed,
      inProgress,
      completed,
      canceled,
      deepCleaning,
      houseCleaning;
  final num totalRevenue, avgRequestValue;
  final List<MonthlyStatVM> monthly;

  StatsVM({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.inProgress,
    required this.completed,
    required this.canceled,
    required this.deepCleaning,
    required this.houseCleaning,
    required this.totalRevenue,
    required this.avgRequestValue,
    required this.monthly,
  });

  factory StatsVM.fromResponse(StatisticsResponse r) {
    final o = r.overview;
    final m = r.monthlyStats ?? const [];

    return StatsVM(
      total: o?.totalRequests ?? 0,
      pending: o?.pendingRequests ?? 0,
      confirmed: o?.confirmedRequests ?? 0,
      inProgress: o?.inProgressRequests ?? 0,
      completed: o?.completedRequests ?? 0,
      canceled: o?.canceledRequests ?? 0,
      deepCleaning: o?.deepCleaningRequests ?? 0,
      houseCleaning: o?.houseCleaningRequests ?? 0,
      totalRevenue: o?.totalRevenue ?? 0,
      avgRequestValue: o?.avgRequestValue ?? 0,
      monthly: m
          .map((e) => MonthlyStatVM(
                month: e.month ?? 1,
                count: e.count ?? 0,
                revenue: e.revenue ?? 0,
              ))
          .toList()
        ..sort((a, b) => a.month.compareTo(b.month)),
    );
  }
}
