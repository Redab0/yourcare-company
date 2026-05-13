// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsOverview _$StatisticsOverviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'StatisticsOverview',
      json,
      ($checkedConvert) {
        final val = StatisticsOverview(
          totalRequests:
              $checkedConvert('totalRequests', (v) => (v as num?)?.toInt()),
          pendingRequests:
              $checkedConvert('pendingRequests', (v) => (v as num?)?.toInt()),
          confirmedRequests:
              $checkedConvert('confirmedRequests', (v) => (v as num?)?.toInt()),
          inProgressRequests: $checkedConvert(
              'inProgressRequests', (v) => (v as num?)?.toInt()),
          completedRequests:
              $checkedConvert('completedRequests', (v) => (v as num?)?.toInt()),
          canceledRequests:
              $checkedConvert('canceledRequests', (v) => (v as num?)?.toInt()),
          deepCleaningRequests: $checkedConvert(
              'deepCleaningRequests', (v) => (v as num?)?.toInt()),
          houseCleaningRequests: $checkedConvert(
              'houseCleaningRequests', (v) => (v as num?)?.toInt()),
          upholsteryCleaningRequests: $checkedConvert(
              'upholsteryCleaningRequests', (v) => (v as num?)?.toInt()),
          totalRevenue:
              $checkedConvert('totalRevenue', (v) => (v as num?)?.toDouble()),
          totalFees:
              $checkedConvert('totalFees', (v) => (v as num?)?.toDouble()),
          totalIncome:
              $checkedConvert('totalIncome', (v) => (v as num?)?.toDouble()),
          totalIncomeAfterFee: $checkedConvert(
              'totalIncomeAfterFee', (v) => (v as num?)?.toDouble()),
          avgRequestValue: $checkedConvert(
              'avgRequestValue', (v) => (v as num?)?.toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$StatisticsOverviewToJson(StatisticsOverview instance) =>
    <String, dynamic>{
      'totalRequests': instance.totalRequests,
      'pendingRequests': instance.pendingRequests,
      'confirmedRequests': instance.confirmedRequests,
      'inProgressRequests': instance.inProgressRequests,
      'completedRequests': instance.completedRequests,
      'canceledRequests': instance.canceledRequests,
      'deepCleaningRequests': instance.deepCleaningRequests,
      'houseCleaningRequests': instance.houseCleaningRequests,
      'upholsteryCleaningRequests': instance.upholsteryCleaningRequests,
      'totalRevenue': instance.totalRevenue,
      'totalFees': instance.totalFees,
      'totalIncome': instance.totalIncome,
      'totalIncomeAfterFee': instance.totalIncomeAfterFee,
      'avgRequestValue': instance.avgRequestValue,
    };

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MonthlyStats',
      json,
      ($checkedConvert) {
        final val = MonthlyStats(
          month: $checkedConvert('month', (v) => (v as num?)?.toInt()),
          count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
          revenue: $checkedConvert('revenue', (v) => v as num?),
        );
        return val;
      },
    );

Map<String, dynamic> _$MonthlyStatsToJson(MonthlyStats instance) =>
    <String, dynamic>{
      'month': instance.month,
      'count': instance.count,
      'revenue': instance.revenue,
    };

StatisticsResponse _$StatisticsResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'StatisticsResponse',
      json,
      ($checkedConvert) {
        final val = StatisticsResponse(
          overview: $checkedConvert(
              'overview',
              (v) => v == null
                  ? null
                  : StatisticsOverview.fromJson(v as Map<String, dynamic>)),
          monthlyStats: $checkedConvert(
              'monthlyStats',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$StatisticsResponseToJson(StatisticsResponse instance) =>
    <String, dynamic>{
      'overview': instance.overview,
      'monthlyStats': instance.monthlyStats,
    };
