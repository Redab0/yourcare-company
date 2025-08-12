import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/statistics/get_requests_statistics_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_event.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final _loader = sl<LoadingController>();
  final getStatisticsUseCase = sl<GetRequestsStatistics>();

  StatisticsBloc() : super(StatisticsInitial()) {
    on<FetchStatisticsEvent>(_onFetchStatistics);
  }

  FutureOr<void> _onFetchStatistics(
      FetchStatisticsEvent event, Emitter<StatisticsState> emit) async {
    _loader.show();
    try {
      final response = await getStatisticsUseCase.call();
      _loader.hide();
      emit(StatisticsFetched(response));
    } catch (e) {
      _loader.hide();
      emit(StatisticsFailure(e.toString()));
    }
  }
}
