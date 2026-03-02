import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();
  @override
  List<Object?> get props => [];
}

class FetchStatisticsEvent extends StatisticsEvent {
  final String? periodType;
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchStatisticsEvent({
    this.periodType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [periodType, startDate, endDate];
}
