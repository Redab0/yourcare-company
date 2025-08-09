import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
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
        title: const Text('Staff Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: GridView.count(
            crossAxisCount: 2, // ← two per row
            childAspectRatio: .8, // ← adjust height/width as you like
            mainAxisSpacing: 16, // ← optional spacing
            crossAxisSpacing: 16, // ← optional spacing
            children: [
              HomeMenuItem(
                imageAsset: 'assets/images/create_user.png',
                title: context.l10n.create_user_title,
                onTap: () {
                  context.goNamed('createUsersScreen');
                },
              ),
              HomeMenuItem(
                imageAsset: 'assets/images/manage_users.png',
                title: context.l10n.user_management,
                onTap: () {
                  context.goNamed('staffList');
                },
              ),
              HomeMenuItem(
                imageAsset: 'assets/images/ic_create_team.png',
                title: context.l10n.create_team,
                onTap: () {
                  context.goNamed('createEditTeamScreen');
                },
              ),
              HomeMenuItem(
                imageAsset: 'assets/images/ic_manage_team.png',
                title: context.l10n.team_management,
                onTap: () {
                  context.goNamed('teamsListScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
