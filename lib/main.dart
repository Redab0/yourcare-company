import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/providers/app_bloc_provider.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/router/router.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

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
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
