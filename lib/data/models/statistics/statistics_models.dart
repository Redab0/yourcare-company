import 'package:json_annotation/json_annotation.dart';

part 'statistics_models.g.dart';

/// The "overview" object
@JsonSerializable(checked: true)
class StatisticsOverview {
  final int? totalRequests;
  final int? pendingRequests;
  final int? confirmedRequests;
  final int? inProgressRequests;
  final int? completedRequests;
  final int? canceledRequests;
  final int? deepCleaningRequests;
  final int? houseCleaningRequests;
  final int? upholsteryCleaningRequests;
  final int? carWashRequests;
  final int? laundryRequests;
  final double? totalRevenue;
  final double? deepCleaningRevenue;
  final double? houseCleaningRevenue;
  final double? upholsteryCleaningRevenue;
  final double? carWashRevenue;
  final double? laundryRevenue;
  final double? totalFees;
  final double? netRevenue;
  final double? totalIncome;
  final double? ourFeeTotal;
  final double? totalIncomeAfterFee;
  final double? avgRequestValue;

  StatisticsOverview({
    this.totalRequests,
    this.pendingRequests,
    this.confirmedRequests,
    this.inProgressRequests,
    this.completedRequests,
    this.canceledRequests,
    this.deepCleaningRequests,
    this.houseCleaningRequests,
    this.upholsteryCleaningRequests,
    this.carWashRequests,
    this.laundryRequests,
    this.totalRevenue,
    this.deepCleaningRevenue,
    this.houseCleaningRevenue,
    this.upholsteryCleaningRevenue,
    this.carWashRevenue,
    this.laundryRevenue,
    this.totalFees,
    this.netRevenue,
    this.totalIncome,
    this.ourFeeTotal,
    this.totalIncomeAfterFee,
    this.avgRequestValue,
  });

  factory StatisticsOverview.fromJson(Map<String, dynamic> json) =>
      _$StatisticsOverviewFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsOverviewToJson(this);
}

/// The items inside "monthlyStats"
@JsonSerializable(checked: true)
class MonthlyStats {
  final int? month;
  final int? count;
  final num? revenue;

  MonthlyStats({this.month, this.count, this.revenue});

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyStatsToJson(this);
}

/// Statistics grouped by the period requested from the API.
@JsonSerializable(checked: true)
class PeriodStats {
  final String? period;
  final String? periodLabel;
  final int? count;
  final num? revenue;
  final int? completedCount;
  final int? pendingCount;
  final int? confirmedCount;
  final int? inProgressCount;
  final int? canceledCount;
  final int? deepCleaningCount;
  final int? houseCleaningCount;
  final int? upholsteryCleaningCount;
  final int? carWashCount;
  final int? laundryCount;
  final num? deepCleaningRevenue;
  final num? houseCleaningRevenue;
  final num? upholsteryCleaningRevenue;
  final num? carWashRevenue;
  final num? laundryRevenue;

  PeriodStats({
    this.period,
    this.periodLabel,
    this.count,
    this.revenue,
    this.completedCount,
    this.pendingCount,
    this.confirmedCount,
    this.inProgressCount,
    this.canceledCount,
    this.deepCleaningCount,
    this.houseCleaningCount,
    this.upholsteryCleaningCount,
    this.carWashCount,
    this.laundryCount,
    this.deepCleaningRevenue,
    this.houseCleaningRevenue,
    this.upholsteryCleaningRevenue,
    this.carWashRevenue,
    this.laundryRevenue,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) =>
      _$PeriodStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PeriodStatsToJson(this);
}

/// Top-level response that contains both "overview" and "monthlyStats"
@JsonSerializable(checked: true)
class StatisticsResponse {
  final StatisticsOverview? overview;
  final List<PeriodStats>? periodStats;
  final List<MonthlyStats>? monthlyStats;
  final String? periodType;
  final String? startDate;
  final String? endDate;

  StatisticsResponse({
    this.overview,
    this.periodStats,
    this.monthlyStats,
    this.periodType,
    this.startDate,
    this.endDate,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatisticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsResponseToJson(this);
}
