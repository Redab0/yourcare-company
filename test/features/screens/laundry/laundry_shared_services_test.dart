import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_product_editor.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = LaundryCatalogItem(
    id: 'config',
    productId: 'shirt',
    source: 'admin',
    nameEn: 'Shirt',
    nameAr: 'قميص',
    companyActive: true,
    sizes: [
      LaundrySize(
          id: 'legacy',
          nameEn: 'Large',
          nameAr: 'كبير',
          price: 3,
          defaultPrice: 2,
          usesDefaultPrice: false)
    ],
    services: [
      LaundryItemService(
          serviceId: 'cleaning',
          nameEn: 'Cleaning',
          nameAr: 'تنظيف',
          defaultPrice: 1,
          price: 1),
      LaundryItemService(serviceId: 'ironing', nameEn: 'Ironing', nameAr: 'كي'),
      LaundryItemService(
          serviceId: 'dry',
          nameEn: 'Dry cleaning',
          nameAr: 'تنظيف جاف',
          serviceActive: false,
          companyActive: true,
          active: false,
          price: 4,
          usesDefaultPrice: false),
      LaundryItemService(
          serviceId: 'retained',
          nameEn: 'Unavailable old service',
          nameAr: 'خدمة قديمة غير متاحة',
          serviceActive: false,
          companyActive: true),
      LaundryItemService(
          serviceId: 'blocked',
          nameEn: 'Blocked service',
          nameAr: 'خدمة معطلة',
          serviceActive: false),
    ]);

Widget _app(Widget child, String language) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({
        'auth_user': jsonEncode({
          'role': 'manager',
          'permissions': [
            {'name': 'company_profile:update'}
          ]
        })
      }));
  tearDown(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final language in ['en', 'ar']) {
    testWidgets(
        'shared services require positive company prices and preserve legacy options in $language',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      LaundryProductConfig? saved;
      await tester.pumpWidget(_app(
          Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () async {
                        saved = await showDialog<LaundryProductConfig>(
                            context: context,
                            builder: (_) =>
                                const LaundryProductEditor(item: _item));
                      },
                      child: const Text('open')))),
          language));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final l10n =
          AppLocalizations.of(tester.element(find.byType(AlertDialog)))!;
      expect(find.text(l10n.laundry_legacy_pricing_help), findsOneWidget);
      expect(find.text(l10n.laundry_use_default_price), findsNothing);
      expect(find.text(l10n.laundry_reset_prices), findsNothing);
      final cleaningPrice =
          find.byKey(const ValueKey('laundry-service-price-cleaning'));
      expect(tester.widget<TextFormField>(cleaningPrice).controller!.text,
          isEmpty);
      Finder toggle(String id) => find
          .descendant(
              of: find.byKey(ValueKey('laundry-service-$id')),
              matching: find.byType(SwitchListTile))
          .first;
      await tester.ensureVisible(toggle('cleaning'));
      await tester.tap(toggle('cleaning'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(toggle('ironing'));
      await tester.tap(toggle('ironing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text(l10n.price_must_be_greater_than_zero), findsNWidgets(2));
      final ironingPrice =
          find.byKey(const ValueKey('laundry-service-price-ironing'));
      await tester.ensureVisible(ironingPrice);
      await tester.enterText(ironingPrice, '0');
      expect(
          tester.widget<SwitchListTile>(toggle('blocked')).onChanged, isNull);
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text(l10n.price_must_be_greater_than_zero), findsNWidgets(2));
      await tester.ensureVisible(cleaningPrice);
      await tester.enterText(cleaningPrice, '1.250');
      await tester.ensureVisible(ironingPrice);
      await tester.enterText(ironingPrice, '0.750');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(saved!.toJson(), {
        'active': true,
        'sizes': [
          {'sizeId': 'legacy', 'price': 3.0}
        ],
        'services': [
          {'serviceId': 'cleaning', 'active': true, 'price': 1.25},
          {'serviceId': 'ironing', 'active': true, 'price': 0.75},
          {'serviceId': 'dry', 'active': true, 'price': 4.0},
          {'serviceId': 'retained', 'active': true},
          {'serviceId': 'blocked', 'active': false},
        ],
      });
      expect(tester.takeException(), isNull);
    });
  }
}
