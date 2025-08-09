import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/obtain_house_keeping_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/submit_business_offer_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsActionBloc
    extends Bloc<RequestsActionEvent, RequestsActionState> {
  final submitOfferUseCase = sl<SubmitBusinessOfferUseCase>();
  final obtainHouseKeepingUseCase = sl<ObtainHouseKeepingRequestUseCase>();
  final getUsersUseCase = sl<GetAllUsersUseCase>();

  final _loader = sl<LoadingController>();

  RequestsActionBloc() : super(RequestsInitial()) {
    on<ObtainHouseKeepingRequest>(_onHouseKeepingRequestObtained);
    on<SubmitOffer>(_onSubmitOffer);
    on<FetchWorkersEvent>(_onFetchWorkers);
  }

  FutureOr<void> _onHouseKeepingRequestObtained(ObtainHouseKeepingRequest event,
      Emitter<RequestsActionState> emit) async {
    _loader.show();
    try {
      final response = await obtainHouseKeepingUseCase.call(
        id: event.requestId,
        model: event.acceptHouseKeepingModel,
      );
      _loader.hide();
      emit(HouseKeepingRequestObtained(response));
    } catch (e) {
      _loader.hide();
      emit(RequestsActionFailed('$e'));
    }
  }

  FutureOr<void> _onSubmitOffer(
      SubmitOffer event, Emitter<RequestsActionState> emit) async {
    _loader.show();
    try {
      await submitOfferUseCase.call(BusinessOffer(
          requestId: event.requestId,
          totalPrice: event.totalPrice,
          description: event.description));
      _loader.hide();
      emit(OfferSubmitted());
    } catch (e) {
      _loader.hide();
      emit(RequestsActionFailed('$e'));
    }
  }

  FutureOr<void> _onFetchWorkers(
      FetchWorkersEvent event, Emitter<RequestsActionState> emit) async {
    _loader.show();
    try {
      final workers = await getUsersUseCase.call(1, 100);
      _loader.hide();
      emit(
        WorkersFetchedState(
          workers.docs,
        ),
      );
    } catch (e) {
      _loader.hide();
      emit(RequestsActionFailed('$e'));
    }
  }
}
