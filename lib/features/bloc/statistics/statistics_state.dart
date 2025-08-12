import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:equatable/equatable.dart';

class StatisticsState extends Equatable {
  const StatisticsState();
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsFailure extends StatisticsState {
  final String errorMessage;
  const StatisticsFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

class StatisticsFetched extends StatisticsState {
  final StatisticsResponse response;

  const StatisticsFetched(this.response);

  @override
  List<Object?> get props => [response];
}
