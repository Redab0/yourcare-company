import 'package:json_annotation/json_annotation.dart';

part 'monthly_stats.g.dart';

@JsonSerializable(checked: true)
class MonthlyStats {
  final int? month;
  final int? count;
  final double? revenue;

  MonthlyStats(this.month, this.count, this.revenue);

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyStatsToJson(this);
}
