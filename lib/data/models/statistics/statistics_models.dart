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
  final double? totalRevenue;
  final double? totalFees;
  final double? totalIncome;
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
    this.totalRevenue,
    this.totalFees,
    this.totalIncome,
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

/// Top-level response that contains both "overview" and "monthlyStats"
@JsonSerializable(checked: true)
class StatisticsResponse {
  final StatisticsOverview? overview;
  final List<MonthlyStats>? monthlyStats;

  StatisticsResponse({this.overview, this.monthlyStats});

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatisticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsResponseToJson(this);
}
