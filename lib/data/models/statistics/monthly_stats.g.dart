// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MonthlyStats',
      json,
      ($checkedConvert) {
        final val = MonthlyStats(
          $checkedConvert('month', (v) => (v as num?)?.toInt()),
          $checkedConvert('count', (v) => (v as num?)?.toInt()),
          $checkedConvert('revenue', (v) => (v as num?)?.toDouble()),
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
