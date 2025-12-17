import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/providers/app_bloc_provider.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/router/router.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setupServiceLocator();

  // Initialize push notifications (request permission + register token)
  // Safe to ignore result; failures handled internally
  await sl<NotificationsRepository>().initializeAndRegister();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
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
                child: child ?? const SizedBox.shrink(),
              );
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
