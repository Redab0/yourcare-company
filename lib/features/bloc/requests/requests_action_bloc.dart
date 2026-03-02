import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/calendar/employee_calendar_response.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/accept_exclusive_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_employee_calendar_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/obtain_house_keeping_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/submit_business_offer_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/submit_upholstery_offer_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestsActionBloc
    extends Bloc<RequestsActionEvent, RequestsActionState> {
  final submitOfferUseCase = sl<SubmitBusinessOfferUseCase>();
  final submitUpholsteryOfferUseCase = sl<SubmitUpholsteryOfferUseCase>();
  final obtainHouseKeepingUseCase = sl<ObtainHouseKeepingRequestUseCase>();
  final acceptExclusiveRequestUseCase = sl<AcceptExclusiveRequestUseCase>();
  final getUsersUseCase = sl<GetAllUsersUseCase>();
  final getEmployeeCalendarUseCase = sl<GetEmployeeCalendarUseCase>();

  final _loader = sl<LoadingController>();

  RequestsActionBloc() : super(RequestsInitial()) {
    on<ObtainHouseKeepingRequest>(_onHouseKeepingRequestObtained);
    on<SubmitOffer>(_onSubmitOffer);
    on<SubmitUpholsteryOffer>(_onSubmitUpholsteryOffer);
    on<FetchWorkersEvent>(_onFetchWorkers);
    on<AcceptExclusiveRequestEvent>(_onAcceptExclusiveRequest);
    on<CheckWorkerAvailability>(_onCheckWorkerAvailability);
    on<FetchAvailableWorkersForSlot>(_onFetchAvailableWorkersForSlot);
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
        description: event.description,
        timelineBusinessOffer: event.timeline,
        descriptionBusinessOffer: event.description,
      ));
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

  FutureOr<void> _onCheckWorkerAvailability(
    CheckWorkerAvailability event,
    Emitter<RequestsActionState> emit,
  ) async {
    emit(WorkerAvailabilityChecking(event.employeeId));
    try {
      final response = await getEmployeeCalendarUseCase.call(
        startDate: event.scheduledTime,
        endDate: event.scheduledTime,
        employeeId: event.employeeId,
      );
      final hasConflict = _hasConflict(
        response,
        event.scheduledTime,
        event.durationHours,
      );
      emit(WorkerAvailabilityChecked(event.employeeId, hasConflict));
    } catch (e) {
      emit(RequestsActionFailed('$e'));
    }
  }

  FutureOr<void> _onFetchAvailableWorkersForSlot(
    FetchAvailableWorkersForSlot event,
    Emitter<RequestsActionState> emit,
  ) async {
    emit(const WorkersAvailabilityFiltering());
    try {
      final response = await getEmployeeCalendarUseCase.call(
        startDate: event.scheduledTime,
        endDate: event.scheduledTime,
      );
      final busy = _busyWorkerIds(
        response,
        event.scheduledTime,
        event.durationHours,
        ignoreRequestId: event.ignoreRequestId,
      );
      final available = event.workerIds
          .where((id) => !busy.contains(id))
          .toList(growable: false);
      emit(WorkersAvailabilityFiltered(available));
    } catch (e) {
      emit(RequestsActionFailed('$e'));
    }
  }

  FutureOr<void> _onAcceptExclusiveRequest(AcceptExclusiveRequestEvent event,
      Emitter<RequestsActionState> emit) async {
    _loader.show();
    try {
      final response = await acceptExclusiveRequestUseCase.call(
        event.requestId,
      );
      _loader.hide();
      emit(ExclusiveRequestObtained(response));
    } catch (e) {
      _loader.hide();
      emit(RequestsActionFailed('$e'));
    }
  }

  FutureOr<void> _onSubmitUpholsteryOffer(
      SubmitUpholsteryOffer event, Emitter<RequestsActionState> emit) async {
    _loader.show();
    try {
      await submitUpholsteryOfferUseCase.call(BusinessOffer(
        requestId: event.requestId,
        totalPrice: event.totalPrice,
        description: event.description,
        timelineBusinessOffer: event.timeline,
        descriptionBusinessOffer: event.description,
      ));
      _loader.hide();
      emit(OfferSubmitted());
    } catch (e) {
      _loader.hide();
      emit(RequestsActionFailed('$e'));
    }
  }

  bool _hasConflict(
    EmployeeCalendarResponse calendarResponse,
    DateTime scheduledTime,
    int durationHours,
  ) {
    final calendarDays = calendarResponse.calendar ?? [];
    final start = scheduledTime;
    final safeDuration = durationHours > 0 ? durationHours : 1;
    final end = start.add(Duration(hours: safeDuration));
    for (final day in calendarDays) {
      final dayDate = day.date;
      if (dayDate == null || !_isSameDay(dayDate, start)) continue;
      final works = day.works ?? [];
      for (final work in works) {
        final status = work.requestStatus;
        if (status == RequestStatus.cancelled ||
            status == RequestStatus.canceled) {
          continue;
        }
        final workStart = work.startTime ?? work.scheduledTime;
        if (workStart == null) {
          return true;
        }
        DateTime? workEnd = work.endTime;
        if (workEnd == null &&
            work.durationHours != null &&
            work.durationHours! > 0) {
          workEnd = workStart.add(Duration(hours: work.durationHours!));
        }
        workEnd ??= workStart.add(const Duration(hours: 1));
        if (_overlaps(workStart, workEnd, start, end)) {
          return true;
        }
      }
    }
    return false;
  }

  Set<String> _busyWorkerIds(
    EmployeeCalendarResponse calendarResponse,
    DateTime scheduledTime,
    int durationHours, {
    String? ignoreRequestId,
  }) {
    final busy = <String>{};
    final calendarDays = calendarResponse.calendar ?? [];
    final start = scheduledTime;
    final safeDuration = durationHours > 0 ? durationHours : 1;
    final end = start.add(Duration(hours: safeDuration));
    for (final day in calendarDays) {
      final dayDate = day.date;
      if (dayDate == null || !_isSameDay(dayDate, start)) continue;
      final works = day.works ?? [];
      for (final work in works) {
        if (ignoreRequestId != null &&
            work.requestId == ignoreRequestId) {
          continue;
        }
        final status = work.requestStatus;
        if (status == RequestStatus.cancelled ||
            status == RequestStatus.canceled) {
          continue;
        }
        final workStart = work.startTime ?? work.scheduledTime;
        if (workStart == null) {
          _collectWorkAssignees(work, busy);
          continue;
        }
        DateTime? workEnd = work.endTime;
        if (workEnd == null &&
            work.durationHours != null &&
            work.durationHours! > 0) {
          workEnd = workStart.add(Duration(hours: work.durationHours!));
        }
        workEnd ??= workStart.add(const Duration(hours: 1));
        if (_overlaps(workStart, workEnd, start, end)) {
          _collectWorkAssignees(work, busy);
        }
      }
    }
    return busy;
  }

  void _collectWorkAssignees(CalendarWork work, Set<String> busy) {
    final cleaners = work.assignedCleaners ?? const [];
    for (final cleaner in cleaners) {
      final id = cleaner.id;
      if (id != null && id.isNotEmpty) {
        busy.add(id);
      }
    }
    final teamMembers = work.assignedTeam?.members ?? const [];
    for (final member in teamMembers) {
      final id = member.id;
      if (id != null && id.isNotEmpty) {
        busy.add(id);
      }
    }
  }

  bool _overlaps(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}
