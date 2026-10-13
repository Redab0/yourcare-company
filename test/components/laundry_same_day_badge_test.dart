import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/components/laundry_same_day_badge.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_job_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/models/laundry/laundry_models_test.dart' show laundryFixture;

class _Repository extends LaundryRepository {
  int settingsReads = 0;
  _Repository() : super(LaundryService(Dio()));
  @override
  Future<LaundrySettings> getSettings() async {
    settingsReads++;
    return const LaundrySettings(
        sameDayEnabled: false,
        sameDayCutoffTime: null,
        timeZone: 'Asia/Kuwait');
  }
}

Map<String, dynamic> _fixture(bool? sameDay) {
  final fixture = laundryFixture();
  if (sameDay != null) (fixture['Laundry'] as Map)['sameDay'] = sameDay;
  return fixture;
}

Widget _app(Widget child, String language) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child);

void main() {
  test('booking snapshot survives parsing and invoice updates; legacy is false',
      () {
    for (final flag in [true, false, null]) {
      final order = CleaningRequest.fromJson(_fixture(flag)) as LaundryHistory;
      expect(order.detail.sameDay, flag == true);
      final updated = order.copyWithExtraInvoice(
          extraFees: 1,
          extraFeesDescription: 'extra',
          awaitingExtraPayment: true);
      expect(updated.detail.sameDay, flag == true);
      expect((updated.toJson()['Laundry'] as Map)['sameDay'], flag == true);
    }
  });

  for (final language in ['en', 'ar']) {
    for (final flag in [true, false]) {
      testWidgets(
          'company list and details show saved sameDay=$flag in $language',
          (tester) async {
        tester.view.physicalSize = const Size(360, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = _Repository();
        sl.registerSingleton<LaundryRepository>(repository);
        addTearDown(() => sl.unregister<LaundryRepository>());
        final order = LaundryHistory.fromJson(_fixture(flag));
        await tester.pumpWidget(
            _app(Scaffold(body: JobTile(request: order)), language));
        await tester.pumpAndSettle();
        var l10n = AppLocalizations.of(tester.element(find.byType(JobTile)))!;
        expect(find.text(l10n.laundry_same_day),
            flag ? findsOneWidget : findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
            _app(LaundryJobDetailsScreen(request: order), language));
        await tester.pumpAndSettle();
        l10n = AppLocalizations.of(
            tester.element(find.byType(LaundrySameDayBadge)))!;
        expect(find.text(l10n.laundry_same_day),
            flag ? findsOneWidget : findsNothing);
        expect(repository.settingsReads, 0,
            reason:
                'Use the saved booking flag even when the company now disables same day.');
        expect(tester.takeException(), isNull);
      });
    }
  }
}
