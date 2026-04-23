import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffMainScreen extends StatelessWidget {
  const StaffMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: Text(context.l10n.staff_management),
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
              final tiles = <Widget>[];

              if (perms.hasPermission(Permission.staffCreate)) {
                tiles.add(
                  HomeMenuItem(
                    imageAsset: 'assets/images/create_user.png',
                    title: context.l10n.create_user_title,
                    onTap: () => context.goNamed('createUsersScreen'),
                    large: isTablet,
                  ),
                );
              }

              if (perms.hasAnyPermission([
                Permission.staffRead,
                Permission.staffUpdate,
              ])) {
                tiles.add(
                  HomeMenuItem(
                    imageAsset: 'assets/images/manage_users.png',
                    title: context.l10n.user_management,
                    onTap: () => context.goNamed('staffList'),
                    large: isTablet,
                  ),
                );
              }

              if (perms.hasPermission(Permission.teamsCreate)) {
                tiles.add(
                  HomeMenuItem(
                    imageAsset: 'assets/images/ic_create_team.png',
                    title: context.l10n.create_team,
                    onTap: () => context.goNamed('createEditTeamScreen'),
                    large: isTablet,
                  ),
                );
              }

              if (perms.hasAnyPermission([
                Permission.teamsRead,
                Permission.teamsUpdate,
              ])) {
                tiles.add(
                  HomeMenuItem(
                    imageAsset: 'assets/images/ic_manage_team.png',
                    title: context.l10n.team_management,
                    onTap: () => context.goNamed('teamsListScreen'),
                    large: isTablet,
                  ),
                );
              }

              if (perms.hasAnyPermission([
                Permission.requestsRead,
                Permission.companyRequestsRead,
                Permission.companyRequestsStatistics,
                Permission.availableRequestsRead,
                Permission.availableRequestsBrowse,
                Permission.browsAvailableRequests,
              ])) {
                tiles.add(
                  HomeMenuItem(
                    imageAsset: 'assets/images/employee_calendar.png',
                    title: context.l10n.employee_calendar,
                    onTap: () => context.goNamed('employee-calendar-screen'),
                    large: isTablet,
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: tiles.length,
                    itemBuilder: (_, i) => tiles[i],
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
