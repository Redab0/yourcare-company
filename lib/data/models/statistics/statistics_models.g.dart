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
          carWashRequests:
              $checkedConvert('carWashRequests', (v) => (v as num?)?.toInt()),
          laundryRequests:
              $checkedConvert('laundryRequests', (v) => (v as num?)?.toInt()),
          totalRevenue:
              $checkedConvert('totalRevenue', (v) => (v as num?)?.toDouble()),
          deepCleaningRevenue: $checkedConvert(
              'deepCleaningRevenue', (v) => (v as num?)?.toDouble()),
          houseCleaningRevenue: $checkedConvert(
              'houseCleaningRevenue', (v) => (v as num?)?.toDouble()),
          upholsteryCleaningRevenue: $checkedConvert(
              'upholsteryCleaningRevenue', (v) => (v as num?)?.toDouble()),
          carWashRevenue:
              $checkedConvert('carWashRevenue', (v) => (v as num?)?.toDouble()),
          laundryRevenue:
              $checkedConvert('laundryRevenue', (v) => (v as num?)?.toDouble()),
          totalFees:
              $checkedConvert('totalFees', (v) => (v as num?)?.toDouble()),
          netRevenue:
              $checkedConvert('netRevenue', (v) => (v as num?)?.toDouble()),
          totalIncome:
              $checkedConvert('totalIncome', (v) => (v as num?)?.toDouble()),
          ourFeeTotal:
              $checkedConvert('ourFeeTotal', (v) => (v as num?)?.toDouble()),
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
      'carWashRequests': instance.carWashRequests,
      'laundryRequests': instance.laundryRequests,
      'totalRevenue': instance.totalRevenue,
      'deepCleaningRevenue': instance.deepCleaningRevenue,
      'houseCleaningRevenue': instance.houseCleaningRevenue,
      'upholsteryCleaningRevenue': instance.upholsteryCleaningRevenue,
      'carWashRevenue': instance.carWashRevenue,
      'laundryRevenue': instance.laundryRevenue,
      'totalFees': instance.totalFees,
      'netRevenue': instance.netRevenue,
      'totalIncome': instance.totalIncome,
      'ourFeeTotal': instance.ourFeeTotal,
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

PeriodStats _$PeriodStatsFromJson(Map<String, dynamic> json) => $checkedCreate(
      'PeriodStats',
      json,
      ($checkedConvert) {
        final val = PeriodStats(
          period: $checkedConvert('period', (v) => v as String?),
          periodLabel: $checkedConvert('periodLabel', (v) => v as String?),
          count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
          revenue: $checkedConvert('revenue', (v) => v as num?),
          completedCount:
              $checkedConvert('completedCount', (v) => (v as num?)?.toInt()),
          pendingCount:
              $checkedConvert('pendingCount', (v) => (v as num?)?.toInt()),
          confirmedCount:
              $checkedConvert('confirmedCount', (v) => (v as num?)?.toInt()),
          inProgressCount:
              $checkedConvert('inProgressCount', (v) => (v as num?)?.toInt()),
          canceledCount:
              $checkedConvert('canceledCount', (v) => (v as num?)?.toInt()),
          deepCleaningCount:
              $checkedConvert('deepCleaningCount', (v) => (v as num?)?.toInt()),
          houseCleaningCount: $checkedConvert(
              'houseCleaningCount', (v) => (v as num?)?.toInt()),
          upholsteryCleaningCount: $checkedConvert(
              'upholsteryCleaningCount', (v) => (v as num?)?.toInt()),
          carWashCount:
              $checkedConvert('carWashCount', (v) => (v as num?)?.toInt()),
          laundryCount:
              $checkedConvert('laundryCount', (v) => (v as num?)?.toInt()),
          deepCleaningRevenue:
              $checkedConvert('deepCleaningRevenue', (v) => v as num?),
          houseCleaningRevenue:
              $checkedConvert('houseCleaningRevenue', (v) => v as num?),
          upholsteryCleaningRevenue:
              $checkedConvert('upholsteryCleaningRevenue', (v) => v as num?),
          carWashRevenue: $checkedConvert('carWashRevenue', (v) => v as num?),
          laundryRevenue: $checkedConvert('laundryRevenue', (v) => v as num?),
        );
        return val;
      },
    );

Map<String, dynamic> _$PeriodStatsToJson(PeriodStats instance) =>
    <String, dynamic>{
      'period': instance.period,
      'periodLabel': instance.periodLabel,
      'count': instance.count,
      'revenue': instance.revenue,
      'completedCount': instance.completedCount,
      'pendingCount': instance.pendingCount,
      'confirmedCount': instance.confirmedCount,
      'inProgressCount': instance.inProgressCount,
      'canceledCount': instance.canceledCount,
      'deepCleaningCount': instance.deepCleaningCount,
      'houseCleaningCount': instance.houseCleaningCount,
      'upholsteryCleaningCount': instance.upholsteryCleaningCount,
      'carWashCount': instance.carWashCount,
      'laundryCount': instance.laundryCount,
      'deepCleaningRevenue': instance.deepCleaningRevenue,
      'houseCleaningRevenue': instance.houseCleaningRevenue,
      'upholsteryCleaningRevenue': instance.upholsteryCleaningRevenue,
      'carWashRevenue': instance.carWashRevenue,
      'laundryRevenue': instance.laundryRevenue,
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
          periodStats: $checkedConvert(
              'periodStats',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => PeriodStats.fromJson(e as Map<String, dynamic>))
                  .toList()),
          monthlyStats: $checkedConvert(
              'monthlyStats',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
                  .toList()),
          periodType: $checkedConvert('periodType', (v) => v as String?),
          startDate: $checkedConvert('startDate', (v) => v as String?),
          endDate: $checkedConvert('endDate', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$StatisticsResponseToJson(StatisticsResponse instance) =>
    <String, dynamic>{
      'overview': instance.overview,
      'periodStats': instance.periodStats,
      'monthlyStats': instance.monthlyStats,
      'periodType': instance.periodType,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
    };
