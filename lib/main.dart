import 'dart:async';
import 'core/access/price_widgets.dart';
import 'core/api/api_client.dart';
import 'core/security/session_lifecycle.dart';
import 'package:cleaning_service_driver/core/diagnostics/mobile_telemetry.dart';
import 'package:cleaning_service_driver/core/diagnostics/app_diagnostics.dart';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/widgets/environment_banner.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/providers/app_bloc_provider.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/router/router.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/locale_cubit.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is available in isolates handling background notifications.
  if (!ApiEnvironment.firebaseEnabled) return;
  await Firebase.initializeApp();
  await MobileTelemetry.initialize();
}

void main() async {
  ApiEnvironment.validate();
  WidgetsFlutterBinding.ensureInitialized();
  AppDiagnostics.installErrorHandlers();
  if (ApiEnvironment.firebaseEnabled) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await Firebase.initializeApp();
    await MobileTelemetry.initialize();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  await setupServiceLocator();

  // If already logged in, initialize notifications and register token.
  String? accessToken;
  try {
    accessToken = await SecureStorageService().getAccessToken();
  } catch (_) {
    /* Unavailable native storage does not clear saved credentials. */
  }
  if (accessToken != null) {
    unawaited(sl<NotificationsRepository>()
        .initializeAndRegister()
        .then<void>((_) {}, onError: (Object _, StackTrace __) {}));
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(SessionLifecycle(
      sessions: sl<ApiClient>().sessions,
      onResume: sl<ApiClient>().refreshPriceAccess,
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final rootKey = sl<GlobalKey<NavigatorState>>();
  late final router = AppRouter(navigatorKey: rootKey).router;

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: BlocBuilder<LocaleCubit, Locale>(
        bloc: sl<LocaleCubit>(),
        builder: (context, locale) {
          return MaterialApp.router(
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            title: AppConstants.appName,
            theme: AppTheme.light(),
            darkTheme: AppTheme.light(),
            themeMode: ThemeMode.system,
            routerConfig: router,
            builder: (context, child) {
              final width = MediaQuery.of(context).size.width;
              final scaler = AppTheme.textScalerForWidth(width);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                child: PriceAccessScope(
                    child: EnvironmentBanner(
                        child: child ?? const SizedBox.shrink())),
              );
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
