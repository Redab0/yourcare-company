import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_catalog_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_invoice_editor.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_job_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../data/models/laundry/laundry_models_test.dart'
    show laundryFixture;

const _catalog = [
  LaundryCatalogItem(
      id: 'blanket',
      nameEn: 'Blanket',
      nameAr: 'بطانية',
      sizes: [
        LaundrySize(id: 'large', nameEn: 'Large', nameAr: 'كبير', price: 2.5),
      ]),
  LaundryCatalogItem(
      id: 'curtain',
      nameEn: 'Curtain',
      nameAr: 'ستارة',
      unit: 'meter',
      price: 1.5),
];

class _Repository extends LaundryRepository {
  _Repository() : super(LaundryService(Dio()));
  @override
  Future<List<LaundryServiceDefinition>> getServices() async => const [
        LaundryServiceDefinition(
            id: 'cleaning', nameEn: 'Cleaning', nameAr: 'تنظيف'),
      ];
  @override
  Future<List<LaundryCategory>> getCategories() async => const [];
  int reads = 0;
  int invoiceSends = 0;
  LaundryCatalogMutation? savedItem;
  List<LaundryCatalogItem> catalog = _catalog;
  Object? error;
  @override
  Future<List<LaundryCatalogItem>> getCatalog() async => catalog;
  @override
  Future<LaundryHistory> getOrder(String id) async {
    reads++;
    if (error != null) throw error!;
    return LaundryHistory.fromJson(
        laundryFixture(status: 'paid', payment: 'paid'));
  }

  @override
  Future<LaundryHistory> sendInvoice(String id,
      {String? expectedRevision}) async {
    invoiceSends++;
    final fixture = laundryFixture(status: 'invoice_sent');
    ((fixture['Laundry'] as Map)['invoice'] as Map)['status'] = 'sent';
    return LaundryHistory.fromJson(fixture);
  }

  @override
  Future<LaundryCatalogItem> saveItem(LaundryCatalogMutation body,
      {String? id}) async {
    savedItem = body;
    return LaundryCatalogItem(
        id: 'new',
        nameEn: body.nameEn,
        nameAr: body.nameAr,
        unit: body.unit,
        unitLabel: body.unitLabel,
        price: body.price,
        sizes: body.sizes,
        active: body.active);
  }
}

Widget _app(Widget child, {String language = 'en'}) => MaterialApp(
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
  late _Repository repository;
  setUp(() {
    repository = _Repository();
    sl.registerSingleton<LaundryRepository>(repository);
  });
  tearDown(() async {
    await sl.unregister<LaundryRepository>();
  });

  for (final language in ['en', 'ar']) {
    testWidgets(
        'unpaid order waits and refresh unlocks completion in $language',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final order =
          LaundryHistory.fromJson(laundryFixture(status: 'invoice_sent'));
      await tester.pumpWidget(
          _app(LaundryJobDetailsScreen(request: order), language: language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      expect(find.text(l10n.laundry_waiting_payment), findsOneWidget);
      expect(find.text(l10n.laundry_start_work), findsNothing);
      expect(find.text(l10n.laundry_create_invoice), findsNothing);
      expect(repository.reads, 0,
          reason: 'Already loaded list data should be reused');
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(repository.reads, 1);
      expect(find.text(l10n.laundry_waiting_payment), findsNothing);
      expect(find.text(l10n.laundry_complete), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invoice stays editable until company confirms sending',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(
        request: LaundryHistory.fromJson(laundryFixture()))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Send invoice'));
    await tester.tap(find.text('Send invoice'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Send this invoice to the customer? Items and prices cannot be changed after sending.'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.invoiceSends, 0);
    await tester.tap(find.text('Send invoice'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send invoice'));
    await tester.pumpAndSettle();
    expect(repository.invoiceSends, 1);
    expect(find.text('Edit draft invoice'), findsNothing);
    expect(find.text('Send invoice'), findsNothing);
    expect(
        find.text(
            'Waiting for customer payment. Refresh to check payment status.'),
        findsOneWidget);
  });

  testWidgets('refresh failure keeps current order and shows API message',
      (tester) async {
    repository.error = Exception('Order changed; refresh again');
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(
        request: LaundryHistory.fromJson(laundryFixture()))));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('Order changed; refresh again'), findsOneWidget);
    expect(find.text('#LD12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'invoice chooses catalog size and emits a draft with no client prices',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LaundryInvoiceRequest? result;
    await tester.pumpWidget(_app(Builder(
        builder: (context) => Scaffold(
            body: TextButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .push<LaundryInvoiceRequest>(MaterialPageRoute(
                          builder: (_) =>
                              const LaundryInvoiceEditor(catalog: _catalog)));
                },
                child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blanket').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Large ·').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.send, isFalse);
    expect(result!.toJson()['items'], [
      {'itemId': 'blanket', 'sizeId': 'large', 'quantity': 2.0}
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'catalog rejects zero and creates a custom item with a positive service price',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Item name in English'), 'Shirt');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Item name in Arabic'), 'قميص');
    await tester.tap(find.widgetWithText(SwitchListTile, 'Cleaning'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('laundry-service-price-cleaning')), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.savedItem, isNull);
    expect(find.text('Price must be greater than zero'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('laundry-service-price-cleaning')), '1.250');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.savedItem?.nameEn, 'Shirt');
    expect(repository.savedItem?.nameAr, 'قميص');
    expect(repository.savedItem?.price, isNull);
    expect(repository.savedItem?.services?.single.toJson(), {
      'serviceId': 'cleaning',
      'active': true,
      'price': 1.25,
    });
    expect(repository.savedItem?.sizes, isEmpty);
    expect(repository.savedItem?.active, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final sized in [false, true]) {
    testWidgets(
        'quick enabling a custom ${sized ? 'sized' : 'base-priced'} item rejects zero',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      repository.catalog = [
        LaundryCatalogItem(
            id: 'old-item',
            nameEn: 'Blanket',
            nameAr: 'بطانية',
            active: false,
            price: sized ? null : 0,
            sizes: sized
                ? const [
                    LaundrySize(
                        id: 'large', nameEn: 'Large', nameAr: 'كبير', price: 0)
                  ]
                : const []),
      ];
      await tester.pumpWidget(_app(const LaundryCatalogScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();
      expect(repository.savedItem, isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.savedItem, isNull);
      expect(find.text('Price must be greater than zero'), findsOneWidget);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(AlertDialog)))!;
      await tester.enterText(
          find.widgetWithText(TextFormField, l10n.laundry_price), '2.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.savedItem?.active, isTrue);
      expect(
          sized
              ? repository.savedItem?.sizes.single.price
              : repository.savedItem?.price,
          2.5);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('invoice and order render at phone width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        _app(const LaundryInvoiceEditor(catalog: _catalog), language: 'ar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(_app(
        LaundryJobDetailsScreen(
            request: LaundryHistory.fromJson(laundryFixture())),
        language: 'ar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
