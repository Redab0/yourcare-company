import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/home/fetch_home_data_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_user_details.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_event.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final servicesUseCase = sl<FetchHomeDataUseCase>();
  final getUserUseCase = sl<GetUserDetails>();
  final _loader = sl<LoadingController>();
  HomeBloc() : super(HomeInitial()) {
    on<FetchHomeDataEvent>(_onFetchServices);
    on<FetchUserDetails>(_onFetchUser);
  }

  Future<void> _onFetchServices(
      FetchHomeDataEvent event, Emitter<HomeState> emit) async {
    _loader.show();
    try {
      final result = await servicesUseCase.call();
      _loader.hide();
      emit(HomeDataFetched());
    } catch (e) {
      _loader.hide();
      emit(HomeFailure());
    }
  }

  FutureOr<void> _onFetchUser(
      FetchUserDetails event, Emitter<HomeState> emit) async {
    _loader.show();
    try {
      final result = await getUserUseCase.call(event.userId);
      _loader.hide();
      emit(UserFetched(result));
    } catch (e) {
      _loader.hide();
      emit(HomeFailure());
    }
  }
}
