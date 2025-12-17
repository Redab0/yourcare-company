import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/assign_cleaners_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/assign_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/cancel_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/complete_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/start_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/update_frequency_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/upload_media_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_teams_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobActionsBloc extends Bloc<JobActionsEvent, JobActionsState> {
  final startJobUseCase = sl<StartJobUseCase>();
  final cancelJobUseCase = sl<CancelJobUseCase>();
  final getUsersUseCase = sl<GetAllUsersUseCase>();
  final getTeamsUseCase = sl<GetTeamsUseCase>();
  final completeJobUseCase = sl<CompleteJobUseCase>();
  final assignWorkersUseCase = sl<AssignCleanersUseCase>();
  final assignTeamUseCase = sl<AssignTeamUseCase>();
  final uploadMediaUseCase = sl<UploadMediaUseCase>();
  final updateRequestFrequencyUseCase = sl<UpdateFrequencyRequestUseCase>();
  final _loader = sl<LoadingController>();

  JobActionsBloc() : super(JobActionsInitial()) {
    on<StartJobEvent>(_onStartJob);
    on<CancelJobEvent>(_onCancelJob);
    on<CompleteJobEvent>(_onCompleteJob);
    on<AssignWorkersEvent>(_onAssignWorkers);
    on<AssignTeamEvent>(_onAssignTeam);
    on<FetchWorkersEvent>(_onFetchWorkers);
    on<FetchTeamsEvent>(_onFetchTeams);
    on<UploadMediaEvent>(_upload);
    on<UpdateFrequencyRequestEvent>(_onUpdateRequestFrequency);
  }

  FutureOr<void> _onStartJob(
      StartJobEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      final response = await startJobUseCase.call(event.id);
      _loader.hide();
      emit(JobStarted(response));
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed("$e"));
    }
  }

  FutureOr<void> _onCancelJob(
      CancelJobEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      await cancelJobUseCase.call(event.id);
      _loader.hide();
      emit(JobCanceled());
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed("$e"));
    }
  }

  FutureOr<void> _onCompleteJob(
      CompleteJobEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      final response = await completeJobUseCase.call(event.id,
          completeJobRequest: event.completeJobRequest);
      _loader.hide();
      emit(JobCompleted(response));
    } catch (e) {
      _loader.hide();
      print("ERROR $e");
      emit(JobActionFailed("$e"));
    }
  }

  FutureOr<void> _onAssignTeam(
      AssignTeamEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      var model = await assignTeamUseCase.call(event.id, event.teamId);
      _loader.hide();
      emit(TeamAssigned(model));
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed("$e"));
    }
  }

  FutureOr<void> _onAssignWorkers(
      AssignWorkersEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      var response = await assignWorkersUseCase.call(event.id, event.model);
      _loader.hide();
      emit(WorkersAssigned(response));
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed("$e"));
    }
  }

  FutureOr<void> _onFetchWorkers(
      FetchWorkersEvent event, Emitter<JobActionsState> emit) async {
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
      emit(JobActionFailed('$e'));
    }
  }

  FutureOr<void> _onFetchTeams(
      FetchTeamsEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      final teams = await getTeamsUseCase.call();
      _loader.hide();
      emit(
        TeamsFetchedState(
          teams,
        ),
      );
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed('$e'));
    }
  }

  FutureOr<void> _upload(
      UploadMediaEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    emit(MediaUploading());
    try {
      final response = await uploadMediaUseCase.call(event.files);
      _loader.hide();
      emit(MediaUploaded(response));
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed("Request Failed $e"));
    }
  }

  FutureOr<void> _onUpdateRequestFrequency(
      UpdateFrequencyRequestEvent event, Emitter<JobActionsState> emit) async {
    _loader.show();
    try {
      final response =
          await updateRequestFrequencyUseCase.call(event.id, event.body);
      _loader.hide();
      emit(RequestFrequencyUpdated(response));
    } catch (e) {
      _loader.hide();
      emit(JobActionFailed("$e"));
    }
  }
}
