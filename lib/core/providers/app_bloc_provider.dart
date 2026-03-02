import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocProviders extends StatelessWidget {
  final Widget child;

  const AppBlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<HomeBloc>()),
        BlocProvider(create: (_) => sl<RequestsBloc>()),
        BlocProvider(create: (_) => sl<JobBloc>()),
        BlocProvider(create: (_) => sl<RequestsActionBloc>()),
        BlocProvider(create: (_) => sl<JobActionsBloc>()),
        BlocProvider(create: (_) => sl<StaffBloc>()),
        BlocProvider(create: (_) => sl<StaffActionBloc>()),
        BlocProvider(create: (_) => sl<BusinessProfileBloc>()),
        BlocProvider(create: (_) => sl<LocaleCubit>()),
        BlocProvider(create: (_) => sl<StatisticsBloc>()),
        BlocProvider(create: (_) => sl<UserProfileBloc>()),
        BlocProvider(create: (_) => sl<EmployeeCalendarBloc>()),
        BlocProvider(create: (_) => sl<EmployeeAvailabilityBloc>()),
        BlocProvider(create: (_) => sl<HousekeepingPricingBloc>()),
        BlocProvider(create: (_) => sl<AutoBidConfigBloc>()),
      ],
      child: child,
    );
  }
}
