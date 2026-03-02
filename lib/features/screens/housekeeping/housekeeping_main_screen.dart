import 'package:cleaning_service_driver/components/home_menu_item.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HouseKeepingMainScreen extends StatelessWidget {
  const HouseKeepingMainScreen({super.key});

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
        title: Text(context.l10n.house_keeping_configuration),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final isTablet = constraints.maxWidth >= 900;
          final crossAxisCount = isTablet ? 3 : 2;
          final aspectRatio = isTablet ? 1.2 : .8;
          final maxWidth = isTablet ? 1100.0 : double.infinity;

          final tiles = [
            HomeMenuItem(
              imageAsset: 'assets/images/ic_house_keeping_pricing.png',
              title: context.l10n.housekeeping_configuration,
              onTap: () => context.goNamed('housekeeping-configuration-screen'),
              large: isTablet,
            ),
            HomeMenuItem(
              imageAsset: 'assets/images/ic_employee_availability.png',
              title: context.l10n.employee_availability,
              onTap: () => context.goNamed('employee-availability-screen'),
              large: isTablet,
            ),
          ];

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
        }),
      ),
    );
  }
}
