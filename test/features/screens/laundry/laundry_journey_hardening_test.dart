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
import 'package:cleaning_service_driver/features/screens/laundry/laundry_presentation.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../data/models/laundry/laundry_models_test.dart'
    show laundryFixture;

const _tops =
    LaundryCategory(id: 'tops', nameEn: 'Tops', nameAr: 'ملابس علوية');
const _home = LaundryCategory(id: 'home', nameEn: 'Home', nameAr: 'المنزل');
const _catalog = [
  LaundryCatalogItem(
      id: 'shirt',
      nameEn: 'Shirt',
      nameAr: 'قميص',
      categoryId: 'tops',
      category: _tops,
      services: [
        LaundryItemService(
            serviceId: 'cleaning',
            nameEn: 'Cleaning',
            nameAr: 'غسيل',
            active: true,
            companyActive: true,
            price: 1.25,
            usesDefaultPrice: false)
      ]),
  LaundryCatalogItem(
      id: 'curtain',
      nameEn: 'Curtain',
      nameAr: 'ستارة',
      categoryId: 'home',
      category: _home,
      unit: 'meter',
      price: 1.333,
      usesDefaultPrice: false),
  LaundryCatalogItem(
      id: 'unpriced', nameEn: 'Unpriced item', nameAr: 'صنف بدون سعر'),
  LaundryCatalogItem(
      id: 'disabled',
      nameEn: 'Disabled item',
      nameAr: 'صنف معطل',
      price: 2,
      active: false),
];

class _Repository extends LaundryRepository {
  _Repository() : super(LaundryService(Dio()));
  final data = laundryFixture(status: 'pending_pickup');
  final statuses = <String>[];
  LaundryInvoiceRequest? invoiceRequest;
  LaundryCatalogMutation? itemRequest;
  bool failSave = false;
  Object? invoiceError;
  int catalogReads = 0;
  List<LaundryCatalogItem> currentCatalog = _catalog;
  Map<String, dynamic> get detail => data['Laundry'] as Map<String, dynamic>;
  LaundryHistory get order => LaundryHistory.fromJson(data);
  @override
  Future<List<LaundryCategory>> getCategories() async => [_tops, _home];
  @override
  Future<List<LaundryCatalogItem>> getCatalog() async {
    catalogReads++;
    return currentCatalog;
  }

  @override
  Future<List<LaundryServiceDefinition>> getServices() async => [
        const LaundryServiceDefinition(
            id: 'cleaning', nameEn: 'Cleaning', nameAr: 'غسيل')
      ];
  @override
  Future<LaundryCatalogItem> saveItem(LaundryCatalogMutation body,
      {String? id}) async {
    itemRequest = body;
    return LaundryCatalogItem(
        id: id ?? 'new',
        nameEn: body.nameEn,
        nameAr: body.nameAr,
        categoryId: body.categoryId,
        category: body.categoryId == 'tops' ? _tops : _home,
        active: body.active);
  }

  @override
  Future<LaundryHistory> updateStatus(String id, String status) async {
    statuses.add(status);
    detail['status'] = status;
    return order;
  }

  @override
  Future<LaundryHistory> saveInvoice(
      String id, LaundryInvoiceRequest body) async {
    if (invoiceError != null) throw invoiceError!;
    if (failSave) throw Exception('Catalog changed; please review items');
    invoiceRequest = body;
    detail['invoice'] = {
      'revision': 'reviewed-revision',
      'status': body.send ? 'sent' : 'draft',
      'subtotal': 2.5,
      'total': 2.5,
      'items': [
        {
          'itemId': 'shirt',
          'itemName': 'Shirt',
          'itemNameAr': 'قميص',
          'sizeId': 'cleaning',
          'serviceId': 'cleaning',
          'size': 'Cleaning',
          'sizeAr': 'غسيل',
          'categoryId': 'tops',
          'category': _tops.toJson(),
          'unit': 'item',
          'quantity': 2,
          'unitPrice': 1.25,
          'total': 2.5
        }
      ]
    };
    if (body.send) detail['status'] = 'invoice_sent';
    return order;
  }

  @override
  Future<LaundryHistory> sendInvoice(String id,
      {String? expectedRevision}) async {
    expect(expectedRevision, 'reviewed-revision');
    detail['status'] = 'invoice_sent';
    (detail['invoice'] as Map)['status'] = 'sent';
    return order;
  }

  @override
  Future<LaundryHistory> getOrder(String id) async {
    if ((detail['invoice'] as Map?)?['status'] == 'sent') {
      detail['status'] = 'paid';
      detail['paymentStatus'] = 'paid';
      (detail['invoice'] as Map)['status'] = 'paid';
    }
    return order;
  }
}

Widget _app(Widget child, {String language = 'en'}) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child);

void _size(WidgetTester tester, [Size size = const Size(900, 1800)]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _choose(WidgetTester tester, Finder finder, String text) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> _action(WidgetTester tester, String text) async {
  final button = find.widgetWithText(FilledButton, text);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, text).last);
  await tester.pumpAndSettle();
}

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
  late _Repository repo;
  setUp(() {
    repo = _Repository();
    sl.registerSingleton<LaundryRepository>(repo);
  });
  tearDown(() async {
    await sl.unregister<LaundryRepository>();
  });

  testWidgets(
      'bag request can be priced directly, paid and completed without pickup steps',
      (tester) async {
    _size(tester);
    repo.detail.remove('invoice');
    expect(repo.order.detail.items, isEmpty);
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: repo.order)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bag pickup — inspect'), findsOneWidget);
    expect(find.text('Create invoice'), findsOneWidget);
    expect(find.text('Accept pickup'), findsNothing);
    expect(find.text('Mark as picked up'), findsNothing);
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).first, 'Tops');
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Shirt');
    // A single service is preselected; zero-priced/unavailable items never enter the dropdown.
    expect(find.textContaining('Cleaning ·'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.ensureVisible(find.text('Save draft'));
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(repo.invoiceRequest?.items.single.quantity, 2);
    expect(repo.invoiceRequest?.items.single.sizeId, 'cleaning');
    expect(repo.invoiceRequest?.send, isFalse);
    expect(find.textContaining('Service: Cleaning'), findsOneWidget);
    await tester.ensureVisible(find.text('Send invoice'));
    await tester.tap(find.text('Send invoice'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send invoice'));
    await tester.pumpAndSettle();
    expect(find.text('Start laundry'), findsNothing);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('Confirmed'), findsOneWidget);
    await _action(tester, 'Complete order');
    expect(repo.statuses, ['completed']);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Create invoice'), findsNothing);
    expect(find.text('Start laundry'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'ar']) {
    testWidgets(
        'category and search filters remain usable on a narrow $language catalog',
        (tester) async {
      _size(tester, const Size(320, 900));
      await tester
          .pumpWidget(_app(const LaundryCatalogScreen(), language: language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      await _choose(tester, find.byType(DropdownButtonFormField<String>),
          _tops.name(language == 'ar'));
      expect(find.text(_catalog.first.name(language == 'ar')), findsOneWidget);
      expect(find.text(_catalog[1].name(language == 'ar')), findsNothing);
      await tester.enterText(
          find.byKey(const ValueKey('laundry-catalog-search')), 'no-match');
      await tester.pumpAndSettle();
      expect(find.text(l10n.laundry_no_matching_items), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('laundry-catalog-search')), '');
      await _choose(tester, find.byType(DropdownButtonFormField<String>),
          _home.name(language == 'ar'));
      expect(find.text(_catalog[1].name(language == 'ar')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('all status actions obey payment locks in $language',
        (tester) async {
      _size(tester, const Size(320, 900));
      const statuses = [
        'pending_pickup',
        'pickup_accepted',
        'picked_up',
        'invoice_sent',
        'confirmed',
        'paid',
        'in_progress',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered',
        'completed',
        'pickup_rejected',
        'cancelled',
        'future_status',
      ];
      for (final mode in ['pickup_invoice_later', 'cart_pay_upfront']) {
        for (final payment in ['paid', 'unpaid']) {
          for (final status in statuses) {
            final data =
                laundryFixture(mode: mode, status: status, payment: payment);
            await tester.pumpWidget(_app(
                LaundryJobDetailsScreen(
                    key: ValueKey('$mode-$payment-$status'),
                    request: LaundryHistory.fromJson(data)),
                language: language));
            await tester.pumpAndSettle();
            final context = tester.element(find.byType(Scaffold));
            final terminal = [
              'completed',
              'pickup_rejected',
              'cancelled',
              'future_status'
            ].contains(status);
            final canComplete = payment == 'paid' && !terminal;
            final canCancel = !terminal &&
                (payment == 'paid' ||
                    ['pending_pickup', 'pickup_accepted'].contains(status));
            expect(
                find.widgetWithText(
                    FilledButton, laundryActionLabel(context, 'completed')),
                canComplete ? findsOneWidget : findsNothing,
                reason: '$mode / $status / $payment');
            expect(
                find.widgetWithText(
                    OutlinedButton, laundryActionLabel(context, 'cancelled')),
                canCancel ? findsOneWidget : findsNothing,
                reason: '$mode / $status / $payment');
            final l10n = AppLocalizations.of(context)!;
            for (final label in [
              l10n.laundry_accept_pickup,
              l10n.laundry_mark_picked_up,
              l10n.laundry_start_work,
              l10n.laundry_mark_ready,
              l10n.laundry_start_delivery,
              l10n.laundry_mark_delivered,
            ]) {
              expect(find.widgetWithText(FilledButton, label), findsNothing);
            }
            expect(tester.takeException(), isNull,
                reason: '$mode / $status / $payment');
          }
        }
      }
    });
  }

  testWidgets(
      'invoice category changes clear invalid selection and retains valid decimal quantity',
      (tester) async {
    _size(tester);
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
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).first, 'Tops');
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Shirt');
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).first, 'Home');
    expect(find.text('Shirt'), findsNothing);
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Curtain');
    await tester.enterText(find.byType(TextFormField).first, '1.125');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(result?.items.single.itemId, 'curtain');
    expect(result?.items.single.sizeId, isNull);
    expect(result?.items.single.quantity, 1.125);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'inactive and unpriced catalog gives company actionable invoice setup guidance',
      (tester) async {
    _size(tester);
    await tester.pumpWidget(
        _app(LaundryInvoiceEditor(catalog: _catalog.skip(2).toList())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enable and price items'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Send invoice'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'failed invoice save preserves the draft and reloads catalog on retry',
      (tester) async {
    _size(tester);
    repo.detail.remove('invoice');
    repo.detail['status'] = 'picked_up';
    repo.failSave = true;
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: repo.order)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Shirt');
    await tester.enterText(find.byType(TextFormField).first, '7');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(find.text('Catalog changed; please review items'), findsOneWidget);
    expect(repo.catalogReads, 1);
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    expect(repo.catalogReads, 2);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        '7.0');
    expect(find.text('Shirt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'minimum rejection refreshes lowered catalog prices and retains the draft on retry',
      (tester) async {
    _size(tester);
    repo.detail.remove('invoice');
    repo.detail['status'] = 'picked_up';
    repo.detail['minimumCharge'] = 5;
    final options = RequestOptions(path: '/requests/laundry/order/invoice');
    repo.invoiceError = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 400, data: {
          'code': 'LAUNDRY_MINIMUM_CHARGE_NOT_MET',
          'message': 'Add more items to reach the company minimum charge',
          'minimumCharge': 5,
          'subtotal': 2,
          'remaining': 3,
        }));
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: repo.order)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Shirt');
    await tester.enterText(find.byType(TextFormField).first, '4');
    await tester.pumpAndSettle();
    await _action(tester, 'Send invoice');
    expect(find.text('Add more items to reach the company minimum charge'),
        findsOneWidget);
    final repriced = _catalog.first.toJson();
    repriced['services'] = [
      {..._catalog.first.services.single.toJson(), 'price': 0.5},
    ];
    repo.currentCatalog = [
      LaundryCatalogItem.fromJson(repriced),
      ..._catalog.skip(1)
    ];
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    expect(repo.catalogReads, 2);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        '4.0');
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Send invoice'))
            .onPressed,
        isNull);
    expect(find.textContaining('Add enough items to reach the minimum'),
        findsWidgets);
    await tester.enterText(find.byType(TextFormField).first, '10');
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Send invoice'))
            .onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom item category changes retain service prices',
      (tester) async {
    _size(tester);
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    await _choose(tester, find.byType(DropdownButtonFormField<String>), 'Tops');
    final card = find.byKey(const ValueKey('laundry-item-shirt'));
    final edit =
        find.descendant(of: card, matching: find.byIcon(Icons.edit_outlined));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await _choose(
        tester, find.byKey(const ValueKey('laundry-item-category')), 'Home');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repo.itemRequest?.categoryId, 'home');
    expect(repo.itemRequest?.services?.single.price, 1.25);
    expect(repo.itemRequest?.removeCategory, isFalse);
    expect(find.text('All categories'), findsOneWidget);
    expect(find.text('Curtain'), findsOneWidget);
  });

  testWidgets(
      'invoice prevents fractional items, excessive discount and duplicate selections',
      (tester) async {
    _size(tester);
    const selections = [
      LaundryInvoiceSelection(
          itemId: 'shirt', sizeId: 'cleaning', quantity: 1.5)
    ];
    await tester.pumpWidget(_app(const LaundryInvoiceEditor(
        catalog: _catalog,
        draft: LaundryInvoiceRequest(items: selections, send: false))));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    await tester.tap(find.text(l10n.laundry_save_draft));
    await tester.pumpAndSettle();
    expect(find.text(l10n.laundry_whole_quantity), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.enterText(
        find.widgetWithText(TextFormField, l10n.laundry_discount), '100');
    await tester.tap(find.text(l10n.laundry_save_draft));
    await tester.pumpAndSettle();
    expect(find.text(l10n.laundry_invoice_invalid_discount), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(const LaundryInvoiceEditor(
        catalog: _catalog,
        draft: LaundryInvoiceRequest(items: [
          LaundryInvoiceSelection(
              itemId: 'shirt', sizeId: 'cleaning', quantity: 1),
          LaundryInvoiceSelection(
              itemId: 'shirt', sizeId: 'cleaning', quantity: 2)
        ], send: false))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.laundry_save_draft));
    await tester.tap(find.text(l10n.laundry_save_draft));
    await tester.pumpAndSettle();
    expect(find.text(l10n.laundry_duplicate_items), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'unavailable invoice selection stays visible as warning and cannot be saved',
      (tester) async {
    _size(tester);
    await tester.pumpWidget(_app(const LaundryInvoiceEditor(
        catalog: _catalog,
        draft: LaundryInvoiceRequest(
            items: [LaundryInvoiceSelection(itemId: 'deleted', quantity: 1)],
            send: false))));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    expect(find.text(l10n.laundry_invoice_unavailable_item), findsOneWidget);
    await tester.tap(find.text(l10n.laundry_save_draft));
    await tester.pumpAndSettle();
    expect(find.text(l10n.laundry_required), findsOneWidget);
    expect(find.byType(LaundryInvoiceEditor), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retained invoice input keeps its original reviewed revision',
      (tester) async {
    _size(tester);
    LaundryInvoiceRequest? saved;
    await tester.pumpWidget(_app(Builder(
        builder: (context) => Scaffold(
            body: TextButton(
                onPressed: () async {
                  saved = await Navigator.of(context)
                      .push<LaundryInvoiceRequest>(MaterialPageRoute(
                          builder: (_) => const LaundryInvoiceEditor(
                              catalog: _catalog,
                              invoice: LaundryInvoice(
                                  status: 'draft',
                                  revision: 'other-managers-new-revision'),
                              draft: LaundryInvoiceRequest(
                                  expectedRevision: 'my-reviewed-revision',
                                  items: [
                                    LaundryInvoiceSelection(
                                        itemId: 'shirt',
                                        sizeId: 'cleaning',
                                        quantity: 7)
                                  ],
                                  send: false))));
                },
                child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(saved?.expectedRevision, 'my-reviewed-revision');
    expect(saved?.items.single.quantity, 7);
  });

  testWidgets(
      'explicit reload confirms discarding a failed draft and reviews latest server revision',
      (tester) async {
    _size(tester);
    repo.detail.remove('invoice');
    repo.detail['status'] = 'picked_up';
    repo.failSave = true;
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: repo.order)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Shirt');
    await tester.enterText(find.byType(TextFormField).first, '7');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    repo.failSave = false;
    await repo.saveInvoice(
        'LD12',
        const LaundryInvoiceRequest(items: [
          LaundryInvoiceSelection(
              itemId: 'shirt', sizeId: 'cleaning', quantity: 2)
        ], send: false));
    await tester.ensureVisible(find.text('Reload saved invoice'));
    await tester.tap(find.text('Reload saved invoice'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Discard your unsaved invoice changes and review the latest saved invoice?'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(LaundryInvoiceEditor), findsNothing);
    await tester.tap(find.text('Reload saved invoice'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reload saved invoice'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        '2.0');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(repo.invoiceRequest?.expectedRevision, 'reviewed-revision');
    expect(repo.invoiceRequest?.items.single.quantity, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'unpriced bag invoice opens catalog setup and reloads priced items on return',
      (tester) async {
    _size(tester);
    var opened = 0;
    await tester.pumpWidget(_app(LaundryInvoiceEditor(
        catalog: const [],
        onManageCatalog: () async {
          opened++;
          return _catalog;
        })));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Send invoice'))
            .onPressed,
        isNull);
    await tester.tap(find.text('Manage Laundry catalog'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.text('Manage Laundry catalog'), findsNothing);
    await _choose(
        tester, find.byType(DropdownButtonFormField<String>).at(1), 'Shirt');
    expect(find.textContaining('Cleaning ·'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Send invoice'))
            .onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'retired service cannot silently become a base-priced invoice item',
      (tester) async {
    _size(tester);
    await tester.pumpWidget(_app(const LaundryInvoiceEditor(
        catalog: _catalog,
        draft: LaundryInvoiceRequest(items: [
          LaundryInvoiceSelection(
              itemId: 'curtain', sizeId: 'retired-service', quantity: 1)
        ], send: false))));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    expect(find.text(l10n.laundry_invoice_unavailable_item), findsOneWidget);
    await tester.tap(find.text(l10n.laundry_save_draft));
    await tester.pumpAndSettle();
    expect(find.text(l10n.laundry_required), findsOneWidget);
    expect(find.byType(LaundryInvoiceEditor), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
