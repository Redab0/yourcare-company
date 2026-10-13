import 'package:cleaning_service_driver/core/api/api_client.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_catalog_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:cleaning_service_driver/main_documents_preview.dart'
    show DocumentsPreviewLogin;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Standalone DEV preview: real authentication and APIs, no mobile push bootstrap.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (ApiClient.baseUrl != ApiClient.dev_baseUrl) {
    throw StateError('The laundry preview must use DEV');
  }
  await setupServiceLocator();
  runApp(_LaundryPreviewApp());
}

class _LaundryPreviewApp extends StatelessWidget {
  _LaundryPreviewApp();
  final _router = GoRouter(initialLocation: '/laundry', routes: [
    GoRoute(
        path: '/login',
        builder: (_, __) =>
            const DocumentsPreviewLogin(successLocation: '/laundry')),
    GoRoute(
        path: '/home',
        name: 'laundry-main-screen',
        builder: (_, __) =>
            const DocumentsPreviewLogin(successLocation: '/laundry')),
    GoRoute(
        path: '/laundry',
        builder: (_, __) => const LaundryCatalogScreen(),
        redirect: (_, __) async {
          final storage = SecureStorageService();
          final user = await storage.getUser();
          return await storage.getAccessToken() != null &&
                  ['business_owner', 'manager'].contains(user?.role) &&
                  user?.businessId != null
              ? null
              : '/login';
        }),
  ]);
  @override
  Widget build(BuildContext context) => BlocBuilder<LocaleCubit, Locale>(
      bloc: sl<LocaleCubit>(),
      builder: (_, locale) => MaterialApp.router(
          title: 'YourCare Company Laundry - DEV',
          theme: AppTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
          debugShowCheckedModeBanner: false));
}
