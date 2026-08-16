import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  static const _tourScope = 'business_staff_journey';
  final _createUserKey = GlobalKey(debugLabel: 'staff-create-user-tour');
  final _manageUsersKey = GlobalKey(debugLabel: 'staff-manage-users-tour');
  final _createTeamKey = GlobalKey(debugLabel: 'staff-create-team-tour');
  final _manageTeamsKey = GlobalKey(debugLabel: 'staff-manage-teams-tour');
  final _calendarKey = GlobalKey(debugLabel: 'staff-calendar-tour');
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
        title: Text(context.l10n.staff_management),
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

              if (perms.hasPermission(Permission.staffCreate)) {
                tiles.add((
                  key: _createUserKey,
                  title: context.l10n.create_user_title,
                  description:
                      context.l10n.business_inner_tour_staff_create_user,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/create_user.png',
                    title: context.l10n.create_user_title,
                    onTap: () => context.pushNamed('createUsersScreen'),
                    large: isTablet,
                  ),
                ));
              }

              if (perms.hasAnyPermission([
                Permission.staffRead,
                Permission.staffUpdate,
              ])) {
                tiles.add((
                  key: _manageUsersKey,
                  title: context.l10n.user_management,
                  description:
                      context.l10n.business_inner_tour_staff_manage_users,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/manage_users.png',
                    title: context.l10n.user_management,
                    onTap: () => context.pushNamed('staffList'),
                    large: isTablet,
                  ),
                ));
              }

              if (perms.hasPermission(Permission.teamsCreate)) {
                tiles.add((
                  key: _createTeamKey,
                  title: context.l10n.create_team,
                  description:
                      context.l10n.business_inner_tour_staff_create_team,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/ic_create_team.png',
                    title: context.l10n.create_team,
                    onTap: () => context.pushNamed('createEditTeamScreen'),
                    large: isTablet,
                  ),
                ));
              }

              if (perms.hasAnyPermission([
                Permission.teamsRead,
                Permission.teamsUpdate,
              ])) {
                tiles.add((
                  key: _manageTeamsKey,
                  title: context.l10n.team_management,
                  description:
                      context.l10n.business_inner_tour_staff_manage_teams,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/ic_manage_team.png',
                    title: context.l10n.team_management,
                    onTap: () => context.pushNamed('teamsListScreen'),
                    large: isTablet,
                  ),
                ));
              }

              if (perms.hasAnyPermission([
                Permission.requestsRead,
                Permission.companyRequestsRead,
                Permission.companyRequestsStatistics,
                Permission.availableRequestsRead,
                Permission.availableRequestsBrowse,
                Permission.browsAvailableRequests,
              ])) {
                tiles.add((
                  key: _calendarKey,
                  title: context.l10n.employee_calendar,
                  description: context.l10n.business_inner_tour_staff_calendar,
                  tile: HomeMenuItem(
                    imageAsset: 'assets/images/employee_calendar.png',
                    title: context.l10n.employee_calendar,
                    onTap: () => context.pushNamed('employee-calendar-screen'),
                    large: isTablet,
                  ),
                ));
              }

              _visibleTourKeys = tiles.map((item) => item.key).toList();
              final ownerId = businessShowcaseOwnerId(snapshot.data);
              if (ownerId != null) {
                _tour.scheduleStartOnce(
                  ownerId: ownerId,
                  journeyId: 'staff_menu',
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
