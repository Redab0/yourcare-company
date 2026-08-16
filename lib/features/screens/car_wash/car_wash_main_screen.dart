import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CarWashMainScreen extends StatefulWidget {
  const CarWashMainScreen({super.key});

  @override
  State<CarWashMainScreen> createState() => _CarWashMainScreenState();
}

class _CarWashMainScreenState extends State<CarWashMainScreen> {
  static const _tourScope = 'business_car_wash_journey';
  final _packagesKey = GlobalKey(debugLabel: 'car-wash-packages-tour');
  final _hoursKey = GlobalKey(debugLabel: 'car-wash-hours-tour');
  late final BusinessShowcaseTourController _tour;
  late final Future<User?> _userFuture;
  bool _canManageAvailability = false;

  List<GlobalKey> get _tourKeys => [
        _packagesKey,
        if (_canManageAvailability) _hoursKey,
      ];

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    _userFuture = SecureStorageService().getUser();
    _userFuture.then((user) {
      if (!mounted) return;
      final permissions = user?.permissions ?? const [];
      setState(() {
        _canManageAvailability = permissions.hasAnyPermission([
          Permission.cleanerAvailabilityRead,
          Permission.cleanerAvailabilityCreate,
          Permission.cleanerAvailabilityUpdate,
          Permission.cleanerAvailabilityDelete,
        ]);
      });
      final ownerId = businessShowcaseOwnerId(user);
      if (ownerId == null) return;
      _tour.scheduleStartOnce(
        ownerId: ownerId,
        journeyId: 'car_wash_menu',
        keys: _tourKeys,
      );
    });
  }

  @override
  void dispose() {
    _tour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(fallbackRouteName: 'home'),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(context.l10n.car_wash_configuration),
        actions: [
          BusinessShowcaseHelpButton(onPressed: () => _tour.start(_tourKeys)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final isTablet = constraints.maxWidth >= 900;
          final crossAxisCount = isTablet ? 3 : 2;
          final aspectRatio = isTablet ? 1.2 : .8;
          final tiles = [
            BusinessShowcaseStep(
              showcaseKey: _packagesKey,
              scope: _tourScope,
              title: context.l10n.car_wash_packages_and_pricing,
              description: context.l10n.business_inner_tour_car_wash_packages,
              index: 0,
              itemCount: _tourKeys.length,
              child: HomeMenuItem(
                imageAsset: 'assets/images/ic_car_wash_pricing.png',
                title: context.l10n.car_wash_packages_and_pricing,
                onTap: () => context.pushNamed('car-wash-pricing-screen'),
                large: isTablet,
              ),
            ),
            if (_canManageAvailability)
              BusinessShowcaseStep(
                showcaseKey: _hoursKey,
                scope: _tourScope,
                title: context.l10n.car_wash_working_hours,
                description: context.l10n.business_inner_tour_car_wash_hours,
                index: 1,
                itemCount: _tourKeys.length,
                child: HomeMenuItem(
                  imageAsset: 'assets/images/ic_car_wash_availability.png',
                  title: context.l10n.car_wash_working_hours,
                  onTap: () =>
                      context.pushNamed('car-wash-working-hours-screen'),
                  large: isTablet,
                ),
              ),
          ];

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 1100 : double.infinity,
                ),
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
                        for (final tile in tiles)
                          SizedBox(
                            width: tileWidth,
                            height: tileHeight,
                            child: tile,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
