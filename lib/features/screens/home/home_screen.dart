import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_state.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_event.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:cleaning_service_driver/features/screens/home/business_home_service.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../components/home_menu_item.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _setupTourScope = 'business_dashboard_setup';

  late final String _userId;
  late final BusinessShowcaseTourController _setupTour;
  late final Map<BusinessHomeService, GlobalKey> _setupTourKeys = {
    for (final service in businessSetupTourOrder)
      service: GlobalKey(debugLabel: 'setup-tour-${service.name}'),
  };
  User? _user; // will hold the latest fetched user
  List<BusinessHomeService> _visibleSetupTourServices = const [];

  @override
  void initState() {
    super.initState();
    _setupTour = BusinessShowcaseTourController(
      scope: _setupTourScope,
    );
    // Grab stored user & kick off fresh fetch
    SecureStorageService().getUser().then((stored) {
      if (stored == null && mounted) {
        context.go('/login');
        return;
      }
      if (!mounted) return;
      _userId = stored!.id!;
      setState(() => _user = stored);
      context.read<HomeBloc>().add(FetchUserDetails(_userId));
    });
  }

  @override
  void dispose() {
    _setupTour.dispose();
    super.dispose();
  }

  void _scheduleAutomaticSetupTour(String companyId) {
    final keys = _setupTourKeysForVisibleServices();
    _setupTour.scheduleStartOnce(
      ownerId: companyId,
      journeyId: 'dashboard',
      keys: keys,
    );
  }

  void _startSetupTour() {
    _setupTour.start(_setupTourKeysForVisibleServices());
  }

  List<GlobalKey> _setupTourKeysForVisibleServices() {
    return _visibleSetupTourServices
        .map((service) => _setupTourKeys[service])
        .whereType<GlobalKey>()
        .toList(growable: false);
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required BusinessHomeService service,
    required bool isTablet,
  }) {
    final tile = HomeMenuItem(
      imageAsset: service.imageAsset,
      title: service.title(context),
      onTap: () => service.open(context),
      large: isTablet,
    );
    final tourIndex = _visibleSetupTourServices.indexOf(service);
    final key = _setupTourKeys[service];
    if (tourIndex < 0 || key == null) return tile;

    return BusinessShowcaseStep(
      showcaseKey: key,
      scope: _setupTourScope,
      title: service.title(context),
      description: service.setupGuideDescription(context),
      index: tourIndex,
      itemCount: _visibleSetupTourServices.length,
      child: tile,
    );
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
              tooltip: context.l10n.business_setup_tour_restart,
              icon: const Icon(Icons.help_outline_rounded),
              onPressed: _startSetupTour,
            ),
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
                  final refreshedUser = state.user.copyWith(
                    services: _user?.services ?? state.user.services,
                  );
                  _user = refreshedUser;
                  SecureStorageService().saveUser(refreshedUser);
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

                return BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
                  bloc: sl<CompanyProfileCubit>(),
                  builder: (context, profileState) {
                    final companyServices = user.services == null
                        ? profileState.companyServices
                        : CompanyProvidedService.parseAll(user.services);
                    final services = BusinessHomeService.values
                        .where((service) => service.canShow(
                              permissions: perms ?? const [],
                              companyServices: companyServices,
                            ))
                        .toList(growable: false);
                    _visibleSetupTourServices =
                        orderedBusinessSetupTourServices(services);

                    final profile = profileState.profile;
                    final profileId = profile?.id?.trim();
                    final tourOwnerId = businessShowcaseOwnerId(user) ??
                        (profileId?.isNotEmpty == true ? profileId : null);
                    if (tourOwnerId != null &&
                        _visibleSetupTourServices.isNotEmpty) {
                      _scheduleAutomaticSetupTour(tourOwnerId);
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: LayoutBuilder(
                            builder: (context, innerConstraints) {
                              const spacing = 16.0;
                              final tileWidth = (innerConstraints.maxWidth -
                                      spacing * (crossAxisCount - 1)) /
                                  crossAxisCount;
                              final tileHeight = tileWidth / aspectRatio;
                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  for (final service in services)
                                    SizedBox(
                                      width: tileWidth,
                                      height: tileHeight,
                                      child: _buildServiceTile(
                                        context,
                                        service: service,
                                        isTablet: isTablet,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              });
            })));
  }
}
