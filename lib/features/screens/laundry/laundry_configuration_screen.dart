import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_same_day_settings_card.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LaundryConfigurationScreen extends StatefulWidget {
  const LaundryConfigurationScreen({super.key});

  @override
  State<LaundryConfigurationScreen> createState() =>
      _LaundryConfigurationScreenState();
}

class _LaundryConfigurationScreenState
    extends State<LaundryConfigurationScreen> {
  static const _tourScope = 'business_laundry_journey';
  final _pricingKey = GlobalKey(debugLabel: 'laundry-pricing-tour');
  final _availabilityKey = GlobalKey(debugLabel: 'laundry-availability-tour');
  late final BusinessShowcaseTourController _tour;
  List<GlobalKey> _visibleTourKeys = const [];
  late final _user = SecureStorageService().getUser();

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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: Text(context.l10n.laundry_configuration),
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
            future: _user,
            builder: (context, snapshot) {
              final List<
                  ({
                    GlobalKey key,
                    Widget tile,
                    String title,
                    String description,
                  })> tiles = [];

              if (canAccessLaundrySettings(snapshot.data)) {
                tiles.add((
                  key: _pricingKey,
                  title: context.l10n.laundry_pricing,
                  description: context.l10n.laundry_setup_help,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/business_laundry_pricing.png',
                    title: context.l10n.laundry_pricing,
                    onTap: () => context.pushNamed('laundry-catalog-screen'),
                    large: isTablet,
                  ),
                ));
              }

              if (canAccessLaundrySettings(snapshot.data)) {
                tiles.add((
                  key: _availabilityKey,
                  title: context.l10n.laundry_working_hours,
                  description: context.l10n.laundry_working_hours_help,
                  tile: HomeMenuItem(
                    imageAsset:
                        'assets/images/business_laundry_working_hours.png',
                    title: context.l10n.laundry_working_hours,
                    onTap: () => context.pushNamed(
                      'laundry-working-hours-screen',
                    ),
                    large: isTablet,
                  ),
                ));
              }

              tiles.sort((a, b) => a.key == _availabilityKey
                  ? -1
                  : b.key == _availabilityKey
                      ? 1
                      : 0);
              _visibleTourKeys = tiles.map((item) => item.key).toList();
              final ownerId = businessShowcaseOwnerId(snapshot.data);
              if (ownerId != null) {
                _tour.scheduleStartOnce(
                  ownerId: ownerId,
                  journeyId: 'laundry_menu',
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
