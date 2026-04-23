import 'package:cleaning_service_driver/components/custome_bottom_nav.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget? child;
  final String currentPath;

  const MainLayout({
    super.key,
    this.child,
    required this.currentPath,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    final isRTL = AppLocalizations.of(context)?.localeName == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: FutureBuilder<User?>(
        future: SecureStorageService().getUser(),
        builder: (context, snap) {
          final perms = snap.data?.permissions ?? <PermissionModel>[];

          // Always include Dashboard
          final items = <NavItem>[
            NavItem(
              label: context.l10n.dashboard,
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              path: '/home',
            ),
            NavItem(
              label: context.l10n.profile,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              path: '/user-profile',
            ),
          ];

          // Conditionally add Requests
          if (perms.hasAnyPermission([
            Permission.availableRequestsRead,
            Permission.availableRequestsBrowse,
          ])) {
            items.insert(
              0,
              NavItem(
                label: context.l10n.requests,
                icon: Icons.request_page_outlined,
                activeIcon: Icons.request_page_rounded,
                path: '/requests',
              ),
            );
          }

          var currentIndex =
              items.indexWhere((i) => widget.currentPath.startsWith(i.path));
          if (currentIndex < 0) currentIndex = 0;

          return Scaffold(
            body: widget.child,
            bottomNavigationBar: items.length > 1
                ? CustomBottomNav(
                    items: items,
                    currentIndex: currentIndex,
                    onTap: (i) => context.go(items[i].path),
                  )
                : null,
          );
        },
      ),
    );
  }
}
