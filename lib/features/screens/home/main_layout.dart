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
  // final List<NavItem> _navItems = [
  //   NavItem(
  //     label: 'Dashboard',
  //     icon: Icons.dashboard_outlined,
  //     activeIcon: Icons.dashboard_rounded,
  //     path: '/home',
  //   ),
  //   NavItem(
  //     label: 'Profile',
  //     icon: Icons.person_outline,
  //     activeIcon: Icons.person,
  //     path: '/profile',
  //   ),
  // ];
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _buildNavItems();
  // }
  //
  // Future<void> _buildNavItems() async {
  //   final storage = SecureStorageService();
  //   final user = await storage.getUser();
  //   final perms = user?.permissions ?? <PermissionModel>[];
  //
  //   setState(() {
  //     if (perms.hasPermission(Permission.browsAvailableRequests)) {
  //       _navItems.insert(
  //         0,
  //         NavItem(
  //           label: 'Requests',
  //           icon: Icons.request_page_outlined,
  //           activeIcon: Icons.request_page_rounded,
  //           path: '/requests',
  //         ),
  //       );
  //     }
  //   });
  // }

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
          ];

          // Conditionally add Requests
          if (perms.hasPermission(Permission.requestsRead)) {
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

          // Conditionally add Profile
          if (snap.data?.role == 'manager') {
            items.insert(
              2,
              NavItem(
                label: context.l10n.profile,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                path: '/profile',
              ),
            );
          }

          // Determine active index
          var currentIndex =
              items.indexWhere((i) => widget.currentPath.startsWith(i.path));
          if (currentIndex < 0) currentIndex = 0;

          return Scaffold(
            body: widget.child,
            // Only show bottom nav when there's more than one tab
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
