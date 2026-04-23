import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_state.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_event.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../components/home_menu_item.dart';
import '../../../core/utils/permissions_helper.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String _userId;
  User? _user; // will hold the latest fetched user

  @override
  void initState() {
    super.initState();
    // Grab stored user & kick off fresh fetch
    SecureStorageService().getUser().then((stored) {
      if (stored == null && mounted) {
        context.go('/login');
        return;
      }
      _userId = stored!.id!;
      context.read<HomeBloc>().add(FetchUserDetails(_userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                builder: (sheetContext) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<LocaleCubit, Locale>(
                        builder: (ctx, locale) {
                          final isArabic = locale.languageCode == 'ar';
                          final isEnglish = locale.languageCode == 'en';

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Arabic
                              ChoiceChip(
                                label: const Text('العربية'),
                                selected: isArabic,
                                onSelected: (_) {
                                  ctx
                                      .read<LocaleCubit>()
                                      .changeLocale(const Locale('ar'));
                                  Navigator.pop(sheetContext);
                                },
                              ),
                              // English
                              ChoiceChip(
                                label: const Text('English'),
                                selected: isEnglish,
                                onSelected: (_) {
                                  ctx
                                      .read<LocaleCubit>()
                                      .changeLocale(const Locale('en'));
                                  Navigator.pop(sheetContext);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(context.l10n.your_care_business),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
            ),
          ],
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<HomeBloc, HomeState>(listener: (ctx, state) {
                if (state is UserFetched) {
                  _user = state.user;
                  SecureStorageService().saveUser(state.user);
                } else if (state is HomeFailure) {
                  ctx.showErrorToast();
                }
              }),
              BlocListener<AuthBloc, AuthState>(listener: (ctx, state) {
                if (state is Unauthenticated) {
                  SecureStorageService().clearAuthData();
                  context.go('/login');
                }
              })
            ],
            child: BlocBuilder<HomeBloc, HomeState>(builder: (ctx, state) {
              // show spinner while loading
              if (state is HomeFailure) {
                return SizedBox.shrink();
              }
              final user = _user;
              if (user == null) {
                return const SizedBox.shrink();
              }

              final perms = user.permissions;

              return LayoutBuilder(builder: (ctx, constraints) {
                final isTablet = constraints.maxWidth >= 900;
                final crossAxisCount = isTablet ? 3 : 2;
                final aspectRatio = isTablet ? 1.2 : .8;

                final canViewUpcomingJobs =
                    perms!.hasPermission(Permission.companyRequestsRead);
                final canViewCleaningRequests = perms.hasAnyPermission([
                  Permission.availableRequestsRead,
                  Permission.availableRequestsBrowse,
                ]);
                final canViewHousekeepingConfig = perms.hasAnyPermission([
                  Permission.cleanerAvailabilityRead,
                  Permission.cleanerAvailabilityCreate,
                  Permission.cleanerAvailabilityUpdate,
                  Permission.cleanerAvailabilityDelete,
                  Permission.housekeepingPricingRead,
                  Permission.housekeepingPricingCreate,
                  Permission.housekeepingPricingUpdate,
                ]);
                final canViewAutoBid = perms.hasAnyPermission([
                  Permission.autoBidRead,
                  Permission.autoBidCreate,
                  Permission.autoBidUpdate,
                ]);
                final canViewStaffManagement = perms.hasAnyPermission([
                  Permission.staffRead,
                  Permission.staffCreate,
                  Permission.staffUpdate,
                  Permission.teamsRead,
                  Permission.teamsCreate,
                  Permission.teamsUpdate,
                  Permission.permissionsRead,
                  Permission.permissionsUpdate,
                  Permission.requestsRead,
                  Permission.companyRequestsRead,
                  Permission.companyRequestsStatistics,
                  Permission.availableRequestsRead,
                  Permission.availableRequestsBrowse,
                  Permission.browsAvailableRequests,
                ]);
                final canViewCompanyProfile = perms.hasAnyPermission([
                  Permission.companyProfileRead,
                  Permission.companyProfileUpdate,
                ]);
                final canViewReports = perms.hasAnyPermission([
                  Permission.reportsRead,
                ]);

                final items = <Widget>[];
                if (canViewUpcomingJobs) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/jobs.png',
                    title: context.l10n.upcoming_jobs,
                    onTap: () => context.pushNamed('jobs-main-screen'),
                    large: isTablet,
                  ));
                }
                if (canViewCleaningRequests) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/requests.png',
                    title: context.l10n.cleaning_requests,
                    onTap: () => context.pushNamed('requests-main-screen'),
                    large: isTablet,
                  ));
                }
                if (canViewHousekeepingConfig) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/ic_house_keeping_management.png',
                    title: context.l10n.house_keeping_configuration,
                    onTap: () => context.pushNamed('housekeeping-main-screen'),
                    large: isTablet,
                  ));
                }
                if (canViewAutoBid) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/ic_requests.png',
                    title: context.l10n.auto_bidding,
                    onTap: () => context.pushNamed('auto-bidding-screen'),
                    large: isTablet,
                  ));
                }

                if (canViewStaffManagement) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/staff.png',
                    title: context.l10n.staff_management,
                    onTap: () => context.pushNamed('staff-main-screen'),
                    large: isTablet,
                  ));
                }
                if (canViewCompanyProfile) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/ic_business_profile.png',
                    title: context.l10n.company_profile,
                    onTap: () => context.pushNamed('business-profile-screen'),
                    large: isTablet,
                  ));
                }
                if (canViewReports) {
                  items.add(HomeMenuItem(
                    imageAsset: 'assets/images/analytics.png',
                    title: context.l10n.reports,
                    onTap: () => context.pushNamed('statisticsScreen'),
                    large: isTablet,
                  ));
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => items[i],
                      ),
                    ),
                  ),
                );
              });
            })));
  }
}
