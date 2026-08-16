import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HouseKeepingMainScreen extends StatefulWidget {
  const HouseKeepingMainScreen({super.key});

  @override
  State<HouseKeepingMainScreen> createState() => _HouseKeepingMainScreenState();
}

class _HouseKeepingMainScreenState extends State<HouseKeepingMainScreen> {
  static const _tourScope = 'business_housekeeping_journey';
  final _pricingKey = GlobalKey(debugLabel: 'housekeeping-pricing-tour');
  final _availabilityKey =
      GlobalKey(debugLabel: 'housekeeping-availability-tour');
  late final BusinessShowcaseTourController _tour;
  List<GlobalKey> _visibleTourKeys = const [];

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: Text(context.l10n.house_keeping_configuration),
        actions: [
          BusinessShowcaseHelpButton(
            onPressed: () => _tour.start(_visibleTourKeys),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final isTablet = constraints.maxWidth >= 900;
          final crossAxisCount = isTablet ? 3 : 2;
          final aspectRatio = isTablet ? 1.2 : .8;
          final maxWidth = isTablet ? 1100.0 : double.infinity;

          return FutureBuilder<User?>(
            future: SecureStorageService().getUser(),
            builder: (context, snapshot) {
              final perms = snapshot.data?.permissions ?? [];
              final List<
                  ({
                    GlobalKey key,
                    Widget tile,
                    String title,
                    String description,
                  })> tiles = [];

              if (perms.hasAnyPermission([
                Permission.housekeepingPricingRead,
                Permission.housekeepingPricingCreate,
                Permission.housekeepingPricingUpdate,
              ])) {
                tiles.add((
                  key: _pricingKey,
                  title: context.l10n.housekeeping_configuration,
                  description:
                      context.l10n.business_inner_tour_housekeeping_pricing,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/ic_house_keeping_pricing.png',
                    title: context.l10n.housekeeping_configuration,
                    onTap: () =>
                        context.pushNamed('housekeeping-configuration-screen'),
                    large: isTablet,
                  ),
                ));
              }

              if (perms.hasAnyPermission([
                Permission.cleanerAvailabilityRead,
                Permission.cleanerAvailabilityCreate,
                Permission.cleanerAvailabilityUpdate,
                Permission.cleanerAvailabilityDelete,
              ])) {
                tiles.add((
                  key: _availabilityKey,
                  title: context.l10n.employee_availability,
                  description: context
                      .l10n.business_inner_tour_housekeeping_availability,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/ic_employee_availability.png',
                    title: context.l10n.employee_availability,
                    onTap: () => context.pushNamed(
                      'employee-availability-screen',
                      queryParameters: {
                        'serviceType':
                            AvailabilityServiceType.houseCleaning.apiValue,
                      },
                    ),
                    large: isTablet,
                  ),
                ));
              }

              _visibleTourKeys = tiles.map((item) => item.key).toList();
              final ownerId = businessShowcaseOwnerId(snapshot.data);
              if (ownerId != null) {
                _tour.scheduleStartOnce(
                  ownerId: ownerId,
                  journeyId: 'housekeeping_menu',
                  keys: _visibleTourKeys,
                );
              }

              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
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
                            for (var i = 0; i < tiles.length; i++)
                              SizedBox(
                                width: tileWidth,
                                height: tileHeight,
                                child: BusinessShowcaseStep(
                                  showcaseKey: tiles[i].key,
                                  scope: _tourScope,
                                  title: tiles[i].title,
                                  description: tiles[i].description,
                                  index: i,
                                  itemCount: tiles.length,
                                  child: tiles[i].tile,
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
        }),
      ),
    );
  }
}
