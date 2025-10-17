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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
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
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to load user details')),
                  );
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
              // once done, ensure we have _user
              final user = _user;
              if (user == null) {
                // unlikely but safe fallback
                return const SizedBox.shrink();
              }

              final perms = user.permissions;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: .8,
                        children: [
                          if (perms!.hasPermission(Permission.requestsRead))
                            HomeMenuItem(
                              imageAsset: 'assets/images/jobs.png',
                              title: context.l10n.upcoming_jobs,
                              onTap: () => context.go('/jobs'),
                            ),
                          if (perms.hasPermission(Permission.requestsRead))
                            HomeMenuItem(
                              imageAsset: 'assets/images/requests.png',
                              title: context.l10n.cleaning_requests,
                              onTap: () => context.go('/requests'),
                            ),
                          if (perms.hasPermission(Permission.transactionsRead))
                            HomeMenuItem(
                              imageAsset: 'assets/images/analytics.png',
                              title: context.l10n.reports,
                              onTap: () => context.goNamed('statisticsScreen'),
                            ),
                          if (perms.hasPermission(Permission.usersRead))
                            HomeMenuItem(
                              imageAsset: 'assets/images/staff.png',
                              title: context.l10n.staff_management,
                              onTap: () => context.go('/staff'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })));
  }
}
