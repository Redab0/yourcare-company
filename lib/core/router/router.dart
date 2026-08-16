import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/features/screens/auth/login_screen.dart';
import 'package:cleaning_service_driver/features/screens/auto_bid/auto_bid_configuration_screen.dart';
import 'package:cleaning_service_driver/features/screens/car_wash/car_wash_main_screen.dart';
import 'package:cleaning_service_driver/features/screens/car_wash/car_wash_pricing_screen.dart';
import 'package:cleaning_service_driver/features/screens/calendar/employee_calendar_screen.dart';
import 'package:cleaning_service_driver/features/screens/home/home_screen.dart';
import 'package:cleaning_service_driver/features/screens/home/main_layout.dart';
import 'package:cleaning_service_driver/features/screens/home/splash_screen.dart';
import 'package:cleaning_service_driver/features/screens/housekeeping/housekeeping_configuration_screen.dart';
import 'package:cleaning_service_driver/features/screens/housekeeping/housekeeping_main_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/deep_cleaning_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/car_wash_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/deep_cleaning_success_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/house_keeping_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/house_keeping_success_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/job_completed_success_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/jobs_screen.dart';
import 'package:cleaning_service_driver/features/screens/jobs/upholstery_cleaning_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/profile/business_profile_screen.dart';
import 'package:cleaning_service_driver/features/screens/profile/user_profile_screen.dart';
import 'package:cleaning_service_driver/features/screens/requests/cleaning_requests_screen.dart';
import 'package:cleaning_service_driver/features/screens/requests/deep_cleaning_requests_screen.dart';
import 'package:cleaning_service_driver/features/screens/requests/deep_cleaning_success_screen.dart';
import 'package:cleaning_service_driver/features/screens/requests/house_keeping_requests_screen.dart';
import 'package:cleaning_service_driver/features/screens/requests/house_keeping_success_screen.dart';
import 'package:cleaning_service_driver/features/screens/requests/upholstery_cleaning_requests_screen.dart';
import 'package:cleaning_service_driver/features/screens/schedule/employee_availability_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/create_staff_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/create_team_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/staff_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/staff_list_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/staff_main_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/teams_list_screen.dart';
import 'package:cleaning_service_driver/features/screens/statistics/statistics_screen.dart';
import 'package:cleaning_service_driver/features/screens/upholstery/upholstery_pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// A helper function for screens to handle back button navigation
void smartBackButton(BuildContext context, [String? fallbackRoute]) {
  // Always use GoRouter to navigate back or to a fallback route
  if (fallbackRoute != null) {
    context.go(fallbackRoute);
  } else {
    // If no fallback route is provided, go to home
    context.go('/');
  }
}

class AppRouter {
  late final GoRouter router;
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  AppRouter({required GlobalKey<NavigatorState> navigatorKey}) {
    // Routes for use with AuthRouter
    final List<RouteBase> routes = [
      // Auth Routes - these exist outside the shell
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return LoginScreen();
        },
      ),

      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          // Home tab
          GoRoute(
            name: 'home',
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),

          GoRoute(
            path: '/business-profile',
            name: 'business-profile-screen',
            builder: (context, state) => const BusinessProfileScreen(),
          ),
          GoRoute(
            path: '/housekeeping',
            name: 'housekeeping-main-screen',
            builder: (context, state) => const HouseKeepingMainScreen(),
          ),
          GoRoute(
            path: '/housekeeping-configuration',
            name: 'housekeeping-configuration-screen',
            builder: (context, state) =>
                const HousekeepingConfigurationScreen(),
          ),
          GoRoute(
            path: '/car-wash',
            name: 'car-wash-main-screen',
            builder: (context, state) => const CarWashMainScreen(),
          ),
          GoRoute(
            path: '/car-wash-pricing',
            name: 'car-wash-pricing-screen',
            builder: (context, state) => const CarWashPricingScreen(),
          ),
          GoRoute(
            path: '/car-wash-working-hours',
            name: 'car-wash-working-hours-screen',
            builder: (context, state) => const EmployeeAvailabilityScreen(
              serviceType: AvailabilityServiceType.carWash,
            ),
          ),
          GoRoute(
            path: '/upholstery-configuration',
            name: 'upholstery-configuration-screen',
            builder: (context, state) => const UpholsteryPricingScreen(),
          ),
          GoRoute(
            path: '/auto-bidding',
            name: 'auto-bidding-screen',
            builder: (context, state) => const AutoBidConfigurationScreen(),
          ),
          GoRoute(
            path: '/user-profile',
            name: 'user-profile-screen',
            builder: (context, state) => const UserProfileScreen(),
          ),
          GoRoute(
            path: '/staff',
            name: 'staff-main-screen',
            builder: (_, __) => StaffMainScreen(),
            routes: [
              GoRoute(
                name: 'createUsersScreen',
                path: 'create-users',
                builder: (_, s) => CreateStaffScreen(),
              ),
              GoRoute(
                  name: 'createEditTeamScreen',
                  path: 'create-team',
                  builder: (_, s) {
                    final TeamModel? team = s.extra as TeamModel?;
                    return CreateEditTeamScreen(
                      team: team,
                    );
                  }),
              GoRoute(
                name: 'teamsListScreen',
                path: 'teams-list-screen',
                builder: (_, s) => TeamsListScreen(),
              ),
              GoRoute(
                  name: 'staffList',
                  path: 'staff-list-screen',
                  builder: (_, s) => StaffListScreen(),
                  routes: [
                    GoRoute(
                        name: 'userDetailsScreen',
                        path: 'user-details-screen',
                        builder: (_, s) {
                          final user = s.extra as User;
                          return StaffDetailsScreen(
                            user: user,
                          );
                        })
                  ])
            ],
          ),

          GoRoute(
            path: '/jobs',
            name: 'jobs-main-screen',
            builder: (_, __) => JobsScreen(),
            routes: [
              GoRoute(
                name: 'houseKeepingJobDetails',
                path: 'house-keeping-job',
                builder: (ctx, state) {
                  // cast the extra back to the exact object you passed
                  final req = state.extra as HouseKeepingHistory;
                  return HouseKeepingJobDetails(request: req);
                },
              ),
              GoRoute(
                name: 'deepCleaningJobDetails',
                path: 'deep-cleaning-job',
                builder: (_, s) => DeepCleaningJobDetailsScreen(
                    request: s.extra! as DeepCleaningHistory),
              ),
              GoRoute(
                name: 'upholsteryCleaningJobDetails',
                path: 'upholstery-cleaning-job',
                builder: (_, s) => UpholsteryCleaningJobDetailsScreen(
                    request: s.extra! as UpholsteryCleaningHistory),
              ),
              GoRoute(
                name: 'carWashJobDetails',
                path: 'car-wash-job',
                builder: (_, state) => CarWashJobDetailsScreen(
                  request: state.extra! as CarWashHistory,
                ),
              ),
              GoRoute(
                name: 'houseKeepingJobSuccess',
                path: 'house-keeping-job-success',
                builder: (_, s) => HouseKeepingJobSuccessScreen(
                    request: s.extra! as HouseKeepingHistory),
              ),
              GoRoute(
                name: 'jobCompletedSuccessScreen',
                path: 'job-completed-success',
                builder: (_, s) => JobSuccessScreen(),
              ),
              GoRoute(
                name: 'deepCleaningJobSuccess',
                path: 'dep-cleaning-job-success',
                builder: (_, s) => DeepCleaningJobSuccessScreen(),
              ),
            ],
          ),

          GoRoute(
            name: 'statisticsScreen',
            path: '/StatisticsScreen',
            builder: (_, __) => StatisticsScreen(),
          ),

          GoRoute(
            name: 'employee-calendar-screen',
            path: '/employee-calendar',
            builder: (_, __) => EmployeeCalendarScreen(),
          ),
          GoRoute(
            name: 'employee-availability-screen',
            path: '/employee-availability',
            builder: (_, state) => EmployeeAvailabilityScreen(
              serviceType: AvailabilityServiceType.fromApiValue(
                    state.uri.queryParameters['serviceType'],
                  ) ??
                  AvailabilityServiceType.houseCleaning,
            ),
          ),

          GoRoute(
            path: '/requests',
            name: 'requests-main-screen',
            builder: (_, __) => RequestsScreen(),
            routes: [
              GoRoute(
                name: 'houseKeeping',
                path: 'house-keeping',
                builder: (ctx, state) {
                  // cast the extra back to the exact object you passed
                  final req = state.extra as HouseKeepingHistory;
                  return HouseKeepingRequestScreen(request: req);
                },
              ),
              GoRoute(
                name: 'deepCleaning',
                path: 'deep-cleaning',
                builder: (_, s) => DeepCleaningRequestScreen(
                    request: s.extra! as DeepCleaningHistory),
              ),
              GoRoute(
                name: 'upholsteryCleaning',
                path: 'upholstery-cleaning',
                builder: (_, s) => UpholsteryCleaningRequestScreen(
                    request: s.extra! as UpholsteryCleaningHistory),
              ),
              GoRoute(
                name: 'houseKeepingSuccess',
                path: 'house-keeping-success',
                builder: (_, s) => HouseKeepingSuccessScreen(
                    request: s.extra! as HouseKeepingHistory),
              ),
              GoRoute(
                name: 'deepCleaningSuccess',
                path: 'dep-cleaning-success',
                builder: (_, s) => DeepCleaningSuccessScreen(),
              ),
            ],
          ),
        ],
      ),
    ];

    // Error builder for use with AuthRouter
    Widget errorBuilder(BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Not Found'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => smartBackButton(context, '/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Route not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    router = GoRouter(
      initialLocation: '/splash',
      navigatorKey: navigatorKey, // reuse your existing keys
      routes: routes,
      errorBuilder: errorBuilder,
    );
  }
}
