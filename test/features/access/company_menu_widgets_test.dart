import 'package:cleaning_service_driver/core/access/price_access.dart';
import 'package:cleaning_service_driver/core/access/price_widgets.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/features/screens/home/business_setup_tour_storage.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/screens/staff/staff_main_screen.dart';
import 'package:cleaning_service_driver/features/screens/housekeeping/housekeeping_main_screen.dart';
import 'package:cleaning_service_driver/features/screens/car_wash/car_wash_main_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    for (final journey in [
      'staff_menu',
      'housekeeping_menu',
      'car_wash_menu'
    ]) {
      await BusinessSetupTourStorage(preferences)
          .markCompleted('fixture', journeyId: journey);
    }
    sl.registerSingleton<SharedPreferences>(preferences);
  });
  tearDown(() => sl.unregister<SharedPreferences>());
  for (final language in ['en', 'ar']) {
    for (final owner in [true, false]) {
      testWidgets(
          '${owner ? "owner" : "unassigned manager"} staff submenu $language',
          (tester) async {
        final user =
            User(id: 'fixture', role: owner ? 'business_owner' : 'manager');
        await SecureStorageService().saveSession('synthetic', user);
        await tester.pumpWidget(_app(const StaffMainScreen(), language));
        await tester.pumpAndSettle();
        final l10n =
            AppLocalizations.of(tester.element(find.byType(StaffMainScreen)))!;
        for (final title in [
          l10n.create_user_title,
          l10n.user_management,
          l10n.create_team,
          l10n.team_management,
          l10n.employee_calendar
        ]) {
          expect(find.text(title), owner ? findsOneWidget : findsNothing);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
    testWidgets(
        'owner operational availability survives price denial $language',
        (tester) async {
      final user = User(id: 'fixture', role: 'business_owner');
      await SecureStorageService().saveSession('synthetic', user);
      final access = PriceAccess()
        ..publish(user, generation: 0, pricesHidden: true);
      await tester.pumpWidget(
          _app(const HouseKeepingMainScreen(), language, access: access));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(HouseKeepingMainScreen)))!;
      expect(find.text(l10n.employee_availability), findsOneWidget);
      expect(find.text(l10n.housekeeping_configuration), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
          _app(const CarWashMainScreen(), language, access: access));
      await tester.pumpAndSettle();
      expect(find.text(l10n.car_wash_working_hours), findsOneWidget);
      expect(find.text(l10n.car_wash_packages_and_pricing), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      access.dispose();
    });
  }
}

Widget _app(Widget home, String language, {PriceAccess? access}) =>
    PriceAccessScope(
        access: access,
        child: MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home));
