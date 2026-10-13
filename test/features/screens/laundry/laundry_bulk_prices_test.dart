import 'dart:async';
import 'dart:convert';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_catalog_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_bulk_prices_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _services = [
  LaundryItemService(
      serviceId: 'wash',
      nameEn: 'Wash',
      nameAr: 'غسيل',
      companyActive: true,
      price: 2,
      usesDefaultPrice: false),
  LaundryItemService(
      serviceId: 'iron',
      nameEn: 'Iron',
      nameAr: 'كي',
      defaultPrice: 3,
      price: 3),
];
const _catalog = [
  LaundryCatalogItem(
      id: 'config-shirt',
      productId: 'shirt',
      source: 'admin',
      nameEn: 'Shirt',
      nameAr: 'قميص',
      price: 1,
      usesDefaultPrice: false,
      companyActive: true,
      services: _services),
  LaundryCatalogItem(
      id: 'custom-blanket',
      nameEn: 'Blanket',
      nameAr: 'بطانية',
      active: false,
      sizes: [
        LaundrySize(id: 's', nameEn: 'Small', nameAr: 'صغير', price: 4),
        LaundrySize(id: 'l', nameEn: 'Large', nameAr: 'كبير', price: 6),
      ]),
  LaundryCatalogItem(
      id: 'config-curtain',
      productId: 'curtain',
      source: 'admin',
      nameEn: 'Curtain',
      nameAr: 'ستارة',
      companyActive: true,
      sizes: [
        LaundrySize(
            id: 'm',
            nameEn: 'Medium',
            nameAr: 'متوسط',
            price: 5,
            usesDefaultPrice: false),
        LaundrySize(
            id: 'xl', nameEn: 'Extra large', nameAr: 'كبير جدًا', price: 7),
      ]),
];
Finder _field(String item, String price) =>
    find.byKey(ValueKey('bulk-price-$item-$price'));
Finder get _save => find.byKey(const ValueKey('laundry-bulk-save'));

Future<void> _open(WidgetTester tester,
    Future<List<LaundryCatalogItem>> Function(LaundryBulkPricesRequest) save,
    {String locale = 'en', List<LaundryCatalogItem> catalog = _catalog}) async {
  await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
          builder: (context) => Scaffold(
              body: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LaundryBulkPricesScreen(
                          catalog: catalog, save: save))),
                  child: const Text('open'))))));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _toggle(String item) => find.descendant(
    of: find.byKey(ValueKey('bulk-item-$item')),
    matching: find.byType(SwitchListTile));

Future<void> _changeAvailability(WidgetTester tester, String item) async {
  await tester.ensureVisible(_toggle(item));
  await tester.tap(_toggle(item));
  await tester.pumpAndSettle();
}

Future<void> _edit(WidgetTester tester, Finder field, String value) async {
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

class _CatalogRepository extends LaundryRepository {
  _CatalogRepository() : super(LaundryService(Dio()));
  int reads = 0;
  int writes = 0;
  @override
  Future<List<LaundryCatalogItem>> getCatalog() async {
    reads++;
    return [_catalog.first];
  }

  @override
  Future<List<LaundryCatalogItem>> updatePrices(
      LaundryBulkPricesRequest request) async {
    writes++;
    expect(
        request.items.single.toJson(), {'productId': 'shirt', 'price': 1.75});
    return [
      const LaundryCatalogItem(
          id: 'new-config-shirt',
          productId: 'shirt',
          source: 'admin',
          nameEn: 'Shirt',
          nameAr: 'قميص',
          companyActive: true,
          price: 1.75,
          usesDefaultPrice: false),
    ];
  }
}

void main() {
  testWidgets(
      'catalog opens cached bulk editor and merges saved rows without refetch',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_user': jsonEncode({
        'role': 'manager',
        'permissions': [
          {'name': 'company_profile:update'},
        ]
      }),
    });
    final repository = _CatalogRepository();
    sl.registerSingleton<LaundryRepository>(repository);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      FlutterSecureStorage.setMockInitialValues({});
      await sl.unregister<LaundryRepository>();
    });
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('laundry-bulk-prices')));
    await tester.tap(find.byKey(const ValueKey('laundry-bulk-prices')));
    await tester.pumpAndSettle();
    expect(repository.reads, 1);
    await _edit(tester, _field('shirt', 'base'), '1.75');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
    expect(repository.reads, 1);
    expect(find.text(RequestFmt.price(1.75)), findsOneWidget);
    expect(find.byType(LaundryBulkPricesScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one status-only save sends false and true only for changed rows',
      (tester) async {
    final requests = <LaundryBulkPricesRequest>[];
    await _open(tester, (request) async {
      requests.add(request);
      return _catalog;
    });
    await _changeAvailability(tester, 'shirt');
    await _changeAvailability(tester, 'custom-blanket');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(requests.single.toJson(), {
      'items': [
        {'productId': 'shirt', 'active': false},
        {'itemId': 'custom-blanket', 'active': true},
      ]
    });
    expect(find.byType(LaundryBulkPricesScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('combined save omits unchanged item and service availability',
      (tester) async {
    LaundryBulkPricesRequest? request;
    await _open(tester, (value) async {
      request = value;
      return _catalog;
    });
    await _changeAvailability(tester, 'shirt');
    await _edit(tester, _field('shirt', 'base'), '1.5');
    await _edit(tester, _field('shirt', 'iron'), '3.5');
    await _edit(tester, _field('curtain', 'm'), '5.25');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(request!.toJson(), {
      'items': [
        {
          'productId': 'shirt',
          'active': false,
          'price': 1.5,
          'services': [
            {'serviceId': 'wash', 'active': true, 'price': 2.0},
            {'serviceId': 'iron', 'active': false, 'price': 3.5},
          ]
        },
        {
          'productId': 'curtain',
          'sizes': [
            {'sizeId': 'm', 'price': 5.25}
          ],
        },
      ]
    });
  });

  testWidgets('reverting availability omits it from a price update',
      (tester) async {
    LaundryBulkPricesRequest? request;
    await _open(tester, (value) async {
      request = value;
      return _catalog;
    });
    await _changeAvailability(tester, 'shirt');
    expect(tester.widget<FilledButton>(_save).onPressed, isNotNull);
    await _changeAvailability(tester, 'shirt');
    expect(tester.widget<FilledButton>(_save).onPressed, isNull);
    await _edit(tester, _field('shirt', 'base'), '1.5');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(
        request!.items.single.toJson(), {'productId': 'shirt', 'price': 1.5});
  });

  for (final locale in ['en', 'ar']) {
    testWidgets(
        'failed combined save retains hidden availability and prices in $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final requests = <LaundryBulkPricesRequest>[];
      await _open(tester, (request) async {
        requests.add(request);
        if (requests.length == 1) throw StateError('server-private-message');
        return _catalog;
      }, locale: locale);
      final l10n = AppLocalizations.of(
          tester.element(find.byType(LaundryBulkPricesScreen)))!;
      await _changeAvailability(tester, 'shirt');
      await _edit(tester, _field('shirt', 'base'), '1.5');
      final search = find.byKey(const ValueKey('laundry-bulk-search'));
      await tester.ensureVisible(search);
      await tester.enterText(search, 'Blanket');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bulk-item-shirt')), findsNothing);
      await tester.tap(_save);
      await tester.pumpAndSettle();
      expect(find.text(l10n.laundry_bulk_prices_error), findsOneWidget);
      expect(find.textContaining('server-private-message'), findsNothing);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text(l10n.laundry_bulk_prices_unsaved), findsOneWidget);
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      await tester.enterText(search, '');
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(_toggle('shirt')).value, isFalse);
      expect(
          tester
              .widget<TextFormField>(_field('shirt', 'base'))
              .controller!
              .text,
          '1.5');
      await tester.tap(_save);
      await tester.pumpAndSettle();
      expect(requests, hasLength(2));
      expect(requests.first.toJson(), requests.last.toJson());
      expect(requests.last.items.single.toJson(),
          {'productId': 'shirt', 'active': false, 'price': 1.5});
      expect(find.byType(LaundryBulkPricesScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('saving locks availability and prevents duplicate submission',
      (tester) async {
    final pending = Completer<List<LaundryCatalogItem>>();
    var requests = 0;
    await _open(tester, (_) {
      requests++;
      return pending.future;
    });
    await _changeAvailability(tester, 'shirt');
    await tester.tap(_save);
    await tester.pump();
    expect(requests, 1);
    expect(tester.widget<SwitchListTile>(_toggle('shirt')).onChanged, isNull);
    expect(tester.widget<FilledButton>(_save).onPressed, isNull);
    pending.complete(_catalog);
    await tester.pumpAndSettle();
    expect(find.byType(LaundryBulkPricesScreen), findsNothing);
  });

  testWidgets('globally disabled products cannot be newly enabled',
      (tester) async {
    const disabled = LaundryCatalogItem(
        id: 'disabled',
        productId: 'disabled',
        source: 'admin',
        nameEn: 'Disabled',
        nameAr: 'متوقف',
        productActive: false,
        companyActive: false,
        price: 2,
        usesDefaultPrice: false);
    await _open(tester, (_) async => [], catalog: [disabled]);
    final toggle = tester.widget<SwitchListTile>(_toggle('disabled'));
    expect(toggle.value, isFalse);
    expect(toggle.onChanged, isNull);
    expect(tester.widget<FilledButton>(_save).onPressed, isNull);
  });

  testWidgets('one save includes changed managed and custom items only',
      (tester) async {
    final requests = <LaundryBulkPricesRequest>[];
    await _open(tester, (request) async {
      requests.add(request);
      return _catalog;
    });
    expect(tester.widget<FilledButton>(_save).onPressed, isNull);
    await _edit(tester, _field('shirt', 'base'), '1.25');
    await _edit(tester, _field('custom-blanket', 's'), '4.5');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(requests.single.toJson(), {
      'items': [
        {'productId': 'shirt', 'price': 1.25},
        {
          'itemId': 'custom-blanket',
          'sizes': [
            {'sizeId': 's', 'price': 4.5},
            {'sizeId': 'l', 'price': 6.0},
          ]
        },
      ]
    });
    expect(find.byType(LaundryBulkPricesScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('service edits preserve availability and untouched prices',
      (tester) async {
    LaundryBulkPricesRequest? request;
    await _open(tester, (value) async {
      request = value;
      return _catalog;
    });
    await _edit(tester, _field('shirt', 'iron'), '3.25');
    await _edit(tester, _field('curtain', 'm'), '5.5');
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(request!.toJson(), {
      'items': [
        {
          'productId': 'shirt',
          'services': [
            {'serviceId': 'wash', 'active': true, 'price': 2.0},
            {'serviceId': 'iron', 'active': false, 'price': 3.25},
          ]
        },
        {
          'productId': 'curtain',
          'sizes': [
            {'sizeId': 'm', 'price': 5.5},
          ]
        },
      ]
    });
  });

  for (final locale in ['en', 'ar']) {
    testWidgets(
        'validates changed prices and preserves failed edits in $locale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var attempts = 0;
      await _open(tester, (_) async {
        attempts++;
        throw StateError('private-server-detail');
      }, locale: locale);
      final l10n = AppLocalizations.of(
          tester.element(find.byType(LaundryBulkPricesScreen)))!;
      for (final price in ['0', '10000.001', '1.1234', 'NaN', '']) {
        await _edit(tester, _field('shirt', 'base'), price);
        await tester.tap(_save);
        await tester.pumpAndSettle();
        expect(find.text(l10n.laundry_bulk_prices_invalid), findsWidgets);
      }
      expect(attempts, 0);
      await _edit(tester, _field('shirt', 'base'), '١٫٢٥٠');
      await tester.tap(_save);
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(find.text(l10n.laundry_bulk_prices_error), findsOneWidget);
      expect(find.textContaining('private-server-detail'), findsNothing);
      expect(
          tester
              .widget<TextFormField>(_field('shirt', 'base'))
              .controller!
              .text,
          '١٫٢٥٠');
      expect(tester.widget<FilledButton>(_save).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invalid edits cannot save after scrolling them offscreen',
      (tester) async {
    var attempts = 0;
    await _open(tester, (_) async {
      attempts++;
      return _catalog;
    });
    await _edit(tester, _field('shirt', 'base'), '0');
    await tester.ensureVisible(_field('curtain', 'xl'));
    await tester.pumpAndSettle();
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(attempts, 0);
    expect(find.byType(LaundryBulkPricesScreen), findsOneWidget);
  });

  testWidgets('back navigation guards unsaved edits and allows discard',
      (tester) async {
    await _open(tester, (_) async => _catalog);
    await _edit(tester, _field('shirt', 'base'), '1.5');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
        find.text('You have unsaved changes to prices or item availability.'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TextFormField>(_field('shirt', 'base')).controller!.text,
        '1.5');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(LaundryBulkPricesScreen), findsNothing);
  });

  testWidgets('default and admin-disabled prices remain untouched',
      (tester) async {
    const item = LaundryCatalogItem(
        id: 'p',
        productId: 'p',
        source: 'admin',
        nameEn: 'Disabled item',
        nameAr: 'صنف متوقف',
        price: 2,
        productActive: false,
        companyActive: true);
    await _open(tester, (_) async => [], catalog: [item]);
    expect(tester.widget<TextFormField>(_field('p', 'base')).enabled, isFalse);
    expect(tester.widget<FilledButton>(_save).onPressed, isNull);
  });
}
