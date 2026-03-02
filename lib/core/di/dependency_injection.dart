import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/api/api_client.dart';
import 'package:cleaning_service_driver/core/storage/local_storage.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:cleaning_service_driver/data/repositories/auth/auth_repository.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_categories_repository.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_config_repository.dart';
import 'package:cleaning_service_driver/data/repositories/housekeeping/housekeeping_pricing_repository.dart';
import 'package:cleaning_service_driver/data/repositories/home/home_repository.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';
import 'package:cleaning_service_driver/data/repositories/profile/user/user_profile_repository.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';
import 'package:cleaning_service_driver/data/repositories/staff/permissions_repository.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';
import 'package:cleaning_service_driver/data/repositories/statistics/statistics_repository.dart';
import 'package:cleaning_service_driver/data/services/auth/auth_service.dart';
import 'package:cleaning_service_driver/data/services/auto_bid/auto_bid_categories_service.dart';
import 'package:cleaning_service_driver/data/services/auto_bid/auto_bid_config_service.dart';
import 'package:cleaning_service_driver/data/services/housekeeping/housekeeping_pricing_service.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';
import 'package:cleaning_service_driver/data/services/profile/business/business_profile_service.dart';
import 'package:cleaning_service_driver/data/services/profile/user/user_profile_service.dart';
import 'package:cleaning_service_driver/data/services/requests/requests_service.dart';
import 'package:cleaning_service_driver/data/services/schedule/schedule_service.dart';
import 'package:cleaning_service_driver/data/services/staff/staff_service.dart';
import 'package:cleaning_service_driver/data/services/statistics/statistics_service.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/login_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/logout_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/get_auto_bid_categories_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/get_auto_bid_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auto_bid/upsert_auto_bid_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/housekeeping/get_housekeeping_pricing_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/housekeeping/upsert_housekeeping_area_fee_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/housekeeping/upsert_housekeeping_pricing_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/home/fetch_home_data_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/assign_cleaners_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/assign_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/cancel_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/complete_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/get_up_coming_jobs_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/start_job_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/update_frequency_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_areas_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/update_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/upload_media_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/user/get_user_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/accept_exclusive_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_available_requests_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_exclusives_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/get_employee_calendar_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/obtain_house_keeping_request_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/submit_business_offer_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/requests/submit_upholstery_offer_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/create_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/delete_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/get_cleaner_availability_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/schedule/update_cleaner_availability_usecase.dart';
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
import 'package:cleaning_service_driver/domain/usecases/statistics/get_requests_statistics_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;
final rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<LocaleStorage>(() => LocaleStorage(sl()));

  final saved = sl<LocaleStorage>().read();
  sl.registerSingleton<LocaleCubit>(LocaleCubit(
    initial: saved != null ? Locale(saved) : const Locale('en'),
    storage: sl<LocaleStorage>(),
  ));

  // ApiClient
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerSingleton<GlobalKey<NavigatorState>>(rootNavigatorKey);
  sl.registerSingleton<LoadingController>(LoadingOverlay(rootNavigatorKey));

  // Services
  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<AutoBidCategoriesService>(
    () => AutoBidCategoriesService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<AutoBidConfigService>(
    () => AutoBidConfigService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<NotificationsService>(
    () => NotificationsService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<RequestsService>(
    () => RequestsService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<JobsService>(
    () => JobsService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<ScheduleService>(
    () => ScheduleService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<StaffService>(
    () => StaffService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<BusinessProfileService>(
    () => BusinessProfileService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<HousekeepingPricingService>(
    () => HousekeepingPricingService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<UserProfileService>(
    () => UserProfileService(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<StatisticsService>(
    () => StatisticsService(sl<ApiClient>().dio),
  );

  // Repos
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<AuthService>()),
  );

  sl.registerLazySingleton<AutoBidCategoriesRepository>(
    () => AutoBidCategoriesRepository(sl<AutoBidCategoriesService>()),
  );

  sl.registerLazySingleton<AutoBidConfigRepository>(
    () => AutoBidConfigRepository(sl<AutoBidConfigService>()),
  );

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepository(
      sl<NotificationsService>(),
      FirebaseMessaging.instance,
    ),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepository(),
  );
  sl.registerLazySingleton<RequestsRepository>(
    () => RequestsRepository(sl<RequestsService>()),
  );
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepository(sl<ScheduleService>()),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepository(sl<JobsService>()),
  );
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepository(sl<StaffService>()),
  );
  sl.registerLazySingleton<BusinessProfileRepository>(
    () => BusinessProfileRepository(sl<BusinessProfileService>()),
  );

  sl.registerLazySingleton<HousekeepingPricingRepository>(
    () => HousekeepingPricingRepository(sl<HousekeepingPricingService>()),
  );

  sl.registerLazySingleton<PermissionsRepository>(
    () => PermissionsRepository(),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepository(sl<StatisticsService>()),
  );

  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepository(sl<UserProfileService>()),
  );

  //use cases
  sl.registerFactory(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerFactory(
      () => GetAutoBidCategoriesUseCase(sl<AutoBidCategoriesRepository>()));
  sl.registerFactory(
      () => GetAutoBidConfigUseCase(sl<AutoBidConfigRepository>()));
  sl.registerFactory(
      () => UpsertAutoBidConfigUseCase(sl<AutoBidConfigRepository>()));
  sl.registerFactory(() => FetchHomeDataUseCase(sl<HomeRepository>()));
  sl.registerFactory(
      () => GetAvailableRequestsUseCase(sl<RequestsRepository>()));
  sl.registerFactory(
      () => SubmitBusinessOfferUseCase(sl<RequestsRepository>()));
  sl.registerFactory(
      () => SubmitUpholsteryOfferUseCase(sl<RequestsRepository>()));
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
  sl.registerFactory(
      () => GetBusinessProfileUseCase(sl<BusinessProfileRepository>()));
  sl.registerFactory(
      () => UpdateBusinessProfileUseCase(sl<BusinessProfileRepository>()));
  sl.registerFactory(() => GetAreasUseCase(sl<BusinessProfileRepository>()));
  sl.registerFactory(() => UploadMediaUseCase(sl<BusinessProfileRepository>()));
  sl.registerFactory(
      () => GetHousekeepingPricingUseCase(sl<HousekeepingPricingRepository>()));
  sl.registerFactory(() =>
      UpsertHousekeepingPricingUseCase(sl<HousekeepingPricingRepository>()));
  sl.registerFactory(() =>
      UpsertHousekeepingAreaFeeUseCase(sl<HousekeepingPricingRepository>()));
  sl.registerFactory(
      () => CheckPermissionsUseCase(sl<PermissionsRepository>()));
  sl.registerFactory(() => UpdateUserUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => CreateTeamUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => UpdateTeamUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetTeamsUseCase(sl<StaffRepository>()));
  sl.registerFactory(() => GetUserDetails(sl<StaffRepository>()));
  sl.registerFactory(() => AssignCleanersUseCase(sl<JobsRepository>()));
  sl.registerFactory(() => AssignTeamUseCase(sl<JobsRepository>()));
  sl.registerFactory(() => GetRequestsStatistics(sl<StatisticsRepository>()));
  sl.registerFactory(() => GetExclusivesUseCase(sl<RequestsRepository>()));
  sl.registerFactory(
      () => AcceptExclusiveRequestUseCase(sl<RequestsRepository>()));
  sl.registerFactory(() => GetEmployeeCalendarUseCase(sl<RequestsRepository>()));
  sl.registerFactory(() => GetUserProfileUseCase(sl<UserProfileRepository>()));
  sl.registerFactory(() => UpdateFrequencyRequestUseCase(sl<JobsRepository>()));
  sl.registerFactory(
      () => GetCleanerAvailabilityUseCase(sl<ScheduleRepository>()));
  sl.registerFactory(
      () => CreateCleanerAvailabilityUseCase(sl<ScheduleRepository>()));
  sl.registerFactory(
      () => UpdateCleanerAvailabilityUseCase(sl<ScheduleRepository>()));
  sl.registerFactory(
      () => DeleteCleanerAvailabilityUseCase(sl<ScheduleRepository>()));

  // Blocs
  sl.registerFactory(() => AuthBloc());
  sl.registerFactory(() => HomeBloc());
  sl.registerFactory(() => RequestsBloc());
  sl.registerFactory(() => JobBloc());
  sl.registerFactory(() => JobActionsBloc());
  sl.registerFactory(() => RequestsActionBloc());
  sl.registerFactory(() => StaffBloc());
  sl.registerFactory(() => StaffActionBloc());
  sl.registerFactory(() => BusinessProfileBloc());
  sl.registerFactory(() => StatisticsBloc());
  sl.registerFactory(() => UserProfileBloc());
  sl.registerFactory(() => EmployeeCalendarBloc());
  sl.registerFactory(() => EmployeeAvailabilityBloc());
  sl.registerFactory(() => HousekeepingPricingBloc());
  sl.registerFactory(() => AutoBidConfigBloc());
}
