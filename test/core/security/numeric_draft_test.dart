import '../../helpers/price_access_fixture.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_state.dart';
import 'package:cleaning_service_driver/features/screens/housekeeping/housekeeping_configuration_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(grantPriceAccess);
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final raw in ['bad', '-1', 'NaN', 'Infinity', '1.0001']) {
    testWidgets(
        'invalid charge "$raw" survives blur/rebuild and cannot save as zero',
        (tester) async {
      final bloc = _PricingBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<HousekeepingPricingBloc>.value(
            value: bloc, child: const HousekeepingConfigurationScreen()),
      ));
      await tester.pumpAndSettle();
      final context =
          tester.element(find.byType(HousekeepingConfigurationScreen));
      final l10n = AppLocalizations.of(context)!;
      final charge =
          find.widgetWithText(TextField, l10n.cleaning_products_price);
      final base =
          find.widgetWithText(TextField, l10n.base_price_per_cleaner_per_hour);
      await tester.ensureVisible(charge);
      await tester.enterText(charge, raw);
      await tester.ensureVisible(base);
      FocusScope.of(context).unfocus();
      bloc.rebuild();
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(charge).controller!.text, raw);
      final save = find.text(l10n.save_pricing);
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(bloc.saves, 0);
      expect(bloc.chargeUpdates, isEmpty);
      await tester.ensureVisible(charge);
      await tester.enterText(charge, '0');
      await tester.ensureVisible(base);
      FocusScope.of(context).unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(bloc.saves, 1);
      expect(bloc.chargeUpdates.last, 0);
    });
  }
}

class _PricingBloc extends Cubit<HousekeepingPricingState>
    implements HousekeepingPricingBloc {
  _PricingBloc()
      : super(const HousekeepingPricingState(
            basePrice: 5, cleaningProductsPrice: 2));
  int saves = 0;
  final chargeUpdates = <double>[];
  void rebuild() => emit(state.copyWith(basePrice: 6));
  @override
  void add(HousekeepingPricingEvent event) {
    if (event is SaveHousekeepingPricing) saves++;
    if (event is UpdateBasePrice) {
      emit(state.copyWith(basePrice: event.basePrice));
    }
    if (event is UpdateCleaningProductsPrice) {
      chargeUpdates.add(event.cleaningProductsPrice);
      emit(state.copyWith(cleaningProductsPrice: event.cleaningProductsPrice));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
