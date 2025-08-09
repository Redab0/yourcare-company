import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/api/api_client.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:cleaning_service_driver/data/repositories/auth/auth_repository.dart';
import 'package:cleaning_service_driver/data/repositories/home/home_repository.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';
import 'package:cleaning_service_driver/data/repositories/profile/profile_repository.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';
import 'package:cleaning_service_driver/data/repositories/staff/permissions_repository.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';
import 'package:cleaning_service_driver/data/services/auth/auth_service.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';
import 'package:cleaning_service_driver/data/services/profile/profile_service.dart';
import 'package:cleaning_service_driver/data/services/requests/requests_service.dart';
import 'package:cleaning_service_driver/data/services/staff/staff_service.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/login_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/logout_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/home/fetch_home_data_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/assign_cleaners_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/assign_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/cancel_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/complete_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/get_up_coming_jobs_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/start_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/get_areas_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/update_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/upload_media_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_available_requests_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/obtain_house_keeping_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/submit_business_offer_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/assign_permissions_for_user.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/check_permissions_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/create_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/create_user_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_permissions_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_users_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_permissions_for_user.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_teams_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_user_details.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/update_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/update_user_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;
final rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> setupServiceLocator() async {
  // ApiClient
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerSingleton<GlobalKey<NavigatorState>>(rootNavigatorKey);
  sl.registerSingleton<LoadingController>(LoadingOverlay(rootNavigatorKey));

  // Services
  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<RequestsService>(
    () => RequestsService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<JobsService>(
    () => JobsService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<StaffService>(
    () => StaffService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<ProfileService>(
    () => ProfileService(sl<ApiClient>().dio),
  );

  // Repos
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<AuthService>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepository(),
  );
  sl.registerLazySingleton<RequestsRepository>(
    () => RequestsRepository(sl<RequestsService>()),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepository(sl<JobsService>()),
  );
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepository(sl<StaffService>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(sl<ProfileService>()),
  );

  sl.registerLazySingleton<PermissionsRepository>(
    () => PermissionsRepository(),
  );

  //use cases
  sl.registerFactory(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => FetchHomeDataUseCase(sl<HomeRepository>()));
  sl.registerFactory(
      () => GetAvailableRequestsUseCase(sl<RequestsRepository>()));
  sl.registerFactory(
      () => SubmitBusinessOfferUseCase(sl<RequestsRepository>()));
  sl.registerFactory(
      () => ObtainHouseKeepingRequestUseCase(sl<RequestsRepository>()));
  sl.registerFactory(() => GetUpComingJobsUseCase(sl<JobsRepository>()));
  sl.registerFactory(() => CancelJobUseCase(sl<JobsRepository>()));
  sl.registerFactory(() => CompleteJobUseCase(sl<JobsRepository>()));
  sl.registerFactory(() => StartJobUseCase(sl<JobsRepository>()));
  sl.registerFactory(
      () => AssignPermissionsForUserUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetAllPermissionsUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetAllUsersUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetPermissionsForUserUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => CreateUserUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetBusinessProfileUseCase(sl<ProfileRepository>()));
  sl.registerFactory(
      () => UpdateBusinessProfileUseCase(sl<ProfileRepository>()));
  sl.registerFactory(() => GetAreasUseCase(sl<ProfileRepository>()));
  sl.registerFactory(() => UploadMediaUseCase(sl<ProfileRepository>()));
  sl.registerFactory(
      () => CheckPermissionsUseCase(sl<PermissionsRepository>()));
  sl.registerFactory(() => UpdateUserUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => CreateTeamUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => UpdateTeamUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetTeamsUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetUserDetails(sl<StaffRepository>()));
  sl.registerFactory(() => AssignCleanersUseCase(sl<JobsRepository>()));
  sl.registerFactory(() => AssignTeamUseCase(sl<JobsRepository>()));

  // Blocs
  sl.registerFactory(() => AuthBloc());
  sl.registerFactory(() => HomeBloc());
  sl.registerFactory(() => RequestsBloc());
  sl.registerFactory(() => JobBloc());
  sl.registerFactory(() => JobActionsBloc());
  sl.registerFactory(() => RequestsActionBloc());
  sl.registerFactory(() => StaffBloc());
  sl.registerFactory(() => StaffActionBloc());
  sl.registerFactory(() => ProfileBloc());
  sl.registerFactory(() => LocaleCubit());
}
