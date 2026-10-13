import 'dart:async';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_cubit.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_invoice_editor.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_job_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../data/models/laundry/laundry_models_test.dart'
    show laundryFixture;

const _catalog = [
  LaundryCatalogItem(id: 'shirt', nameEn: 'Shirt', nameAr: 'قميص', price: 2)
];
LaundryHistory _order() {
  final data = laundryFixture(status: 'picked_up');
  (data['Laundry'] as Map).remove('invoice');
  return LaundryHistory.fromJson(data);
}

class _Repository extends LaundryRepository {
  int reads = 0;
  final replies = <Future<List<LaundryCatalogItem>>>[];
  bool failSave = false;
  _Repository() : super(LaundryService(Dio()));
  @override
  Future<List<LaundryCatalogItem>> getCatalog() {
    final index = reads++;
    return index < replies.length ? replies[index] : Future.value(_catalog);
  }

  @override
  Future<LaundryHistory> saveInvoice(
      String id, LaundryInvoiceRequest body) async {
    if (failSave) throw Exception('Invoice was not saved');
    return _order();
  }
}

Widget _app(Widget child, {String language = 'en'}) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child);
void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(600, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _register(LaundryRepository repo) {
  sl.registerSingleton<LaundryRepository>(repo);
  addTearDown(() => sl.unregister<LaundryRepository>());
}

Map<String, dynamic> _response() => {
      'success': true,
      'message': 'Success',
      'data': {
        'locale': 'en',
        'data': _catalog.map((item) => item.toJson()).toList()
      }
    };
void main() {
  test(
      'catalog has a whole-request deadline, cancels stalled transport and supports retry',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final pending = <(RequestOptions, RequestInterceptorHandler)>[];
    final secondRequest = Completer<void>();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      pending.add((options, handler));
      if (pending.length == 2) secondRequest.complete();
    }));
    final repo = LaundryRepository(LaundryService(dio),
        catalogTimeout: const Duration(milliseconds: 30));
    await expectLater(repo.getCatalog(), throwsA(isA<TimeoutException>()));
    expect(pending.single.$1.path, '/business/my-business/laundry-catalog');
    expect(pending.single.$1.cancelToken!.isCancelled, isTrue);
    final retry = repo.getCatalog();
    await secondRequest.future;
    expect(pending.length, 2);
    pending.last.$2
        .resolve(Response(requestOptions: pending.last.$1, data: _response()));
    expect((await retry).single.id, 'shirt');
    // A late response from the abandoned request is consumed, never reused.
    pending.first.$2
        .resolve(Response(requestOptions: pending.first.$1, data: _response()));
    await Future<void>.delayed(Duration.zero);
  });
  test(
      'catalog timeout clears loading, keeps existing data and ignores late completion',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final pending = <(RequestOptions, RequestInterceptorHandler)>[];
    var success = true;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (success) {
        handler.resolve(Response(requestOptions: options, data: _response()));
      } else {
        pending.add((options, handler));
      }
    }));
    final cubit = LaundryCubit(
        LaundryRepository(LaundryService(dio),
            catalogTimeout: const Duration(milliseconds: 30)),
        order: _order());
    addTearDown(cubit.close);
    await cubit.loadCatalog();
    success = false;
    await cubit.loadCatalog();
    expect(cubit.state.loading, isFalse);
    expect(cubit.state.loadingCatalog, isFalse);
    expect(cubit.state.catalogFailure, LaundryCatalogFailure.timeout);
    expect(cubit.state.catalog.single.id, 'shirt');
    expect(cubit.state.order!.id, isNotNull);
    success = true;
    await cubit.loadCatalog();
    expect(cubit.state.catalogFailure, isNull);
    pending.single.$2.resolve(Response(
        requestOptions: pending.single.$1,
        statusCode: 500,
        data: {'success': false, 'message': 'Late error', 'data': null}));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.catalogFailure, isNull);
    expect(cubit.state.catalog.single.id, 'shirt');
  });
  test(
      'a session preparation timeout has the same visible recovery as a network timeout',
      () async {
    final repo = _Repository();
    final pending = Completer<List<LaundryCatalogItem>>();
    repo.replies.add(pending.future);
    final cubit = LaundryCubit(repo, order: _order());
    addTearDown(cubit.close);
    final load = cubit.loadCatalog();
    pending.completeError(DioException(
        requestOptions: RequestOptions(path: '/catalog'),
        error: TimeoutException('Credentials read timed out')));
    await load;
    expect(cubit.state.catalogFailure, LaundryCatalogFailure.timeout);
    expect(cubit.state.loading, isFalse);
    await cubit.loadCatalog();
    expect(cubit.state.catalogFailure, isNull);
    expect(cubit.state.catalog.single.id, 'shirt');
  });
  for (final type in [
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout
  ]) {
    test('Dio $type is a retryable catalog timeout', () async {
      final repo = _Repository();
      final pending = Completer<List<LaundryCatalogItem>>();
      repo.replies.add(pending.future);
      final cubit = LaundryCubit(repo, order: _order());
      addTearDown(cubit.close);
      final load = cubit.loadCatalog();
      pending.completeError(DioException(
          requestOptions: RequestOptions(path: '/catalog'), type: type));
      await load;
      expect(cubit.state.catalogFailure, LaundryCatalogFailure.timeout);
      expect(cubit.state.loading, isFalse);
      await cubit.loadCatalog();
      expect(cubit.state.catalogFailure, isNull);
      expect(repo.reads, 2);
    });
  }
  test(
      'permission/server failure is distinct from timeout and duplicate loads share one request',
      () async {
    final repo = _Repository();
    final pending = Completer<List<LaundryCatalogItem>>();
    repo.replies.add(pending.future);
    final cubit = LaundryCubit(repo, order: _order());
    addTearDown(cubit.close);
    final load = cubit.loadCatalog();
    await cubit.loadCatalog();
    expect(repo.reads, 1);
    pending.completeError(DioException(
        requestOptions: RequestOptions(path: '/catalog'),
        response: Response(
            requestOptions: RequestOptions(path: '/catalog'),
            statusCode: 403,
            data: {'message': 'Forbidden'})));
    await load;
    expect(cubit.state.catalogFailure, LaundryCatalogFailure.unavailable);
    expect(cubit.state.error, 'Forbidden');
    expect(cubit.state.loading, isFalse);
  });
  for (final language in ['en', 'ar']) {
    testWidgets(
        'slow invoice catalog keeps details visible, timeout offers retry in $language',
        (tester) async {
      _size(tester);
      final repo = _Repository();
      _register(repo);
      final pending = Completer<List<LaundryCatalogItem>>();
      repo.replies.add(pending.future);
      await tester.pumpWidget(
          _app(LaundryJobDetailsScreen(request: _order()), language: language));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(LaundryJobDetailsScreen)))!;
      final create = find.ancestor(
          of: find.text(l10n.laundry_create_invoice),
          matching: find.byWidgetPredicate((widget) => widget is FilledButton));
      await tester.ensureVisible(create);
      await tester.tap(create);
      await tester.pump();
      expect(find.text(l10n.laundry_catalog_loading), findsOneWidget);
      expect(find.text(l10n.laundry_customer), findsWidgets);
      expect(find.byType(LaundryInvoiceEditor), findsNothing);
      expect(tester.widget<FilledButton>(create).onPressed, isNull);
      pending.completeError(TimeoutException('Timed out'));
      await tester.pumpAndSettle();
      expect(find.byType(AppIconSpinner), findsNothing);
      expect(find.text(l10n.laundry_catalog_load_timeout), findsOneWidget);
      await tester
          .ensureVisible(find.byKey(const ValueKey('laundry-catalog-retry')));
      await tester.tap(find.byKey(const ValueKey('laundry-catalog-retry')));
      await tester.pumpAndSettle();
      expect(repo.reads, 2);
      expect(find.byType(LaundryInvoiceEditor), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'double tapping Create cannot open an empty or duplicate invoice editor',
      (tester) async {
    _size(tester);
    final repo = _Repository();
    _register(repo);
    final pending = Completer<List<LaundryCatalogItem>>();
    repo.replies.add(pending.future);
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: _order())));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(find.ancestor(
        of: find.text('Create invoice'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton)));
    button.onPressed!();
    button.onPressed!();
    await tester.pump();
    expect(repo.reads, 1);
    expect(find.byType(LaundryInvoiceEditor), findsNothing);
    pending.complete(_catalog);
    await tester.pumpAndSettle();
    expect(find.byType(LaundryInvoiceEditor), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    expect(repo.reads, 1,
        reason: 'Reuse the loaded catalog within the invoice journey.');
    expect(find.byType(LaundryInvoiceEditor), findsOneWidget);
  });
  testWidgets(
      'leaving the order during a pending catalog load never opens an editor later',
      (tester) async {
    _size(tester);
    final repo = _Repository();
    _register(repo);
    final pending = Completer<List<LaundryCatalogItem>>();
    repo.replies.add(pending.future);
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: _order())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(_catalog);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(LaundryInvoiceEditor), findsNothing);
  });
  testWidgets(
      'unsaved invoice selections survive a catalog timeout between retries',
      (tester) async {
    _size(tester);
    final repo = _Repository()..failSave = true;
    _register(repo);
    await tester.pumpWidget(_app(LaundryJobDetailsScreen(request: _order())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shirt').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '3');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    final pending = Completer<List<LaundryCatalogItem>>();
    repo.replies.addAll([Future.value(_catalog), pending.future]);
    await tester.ensureVisible(find.text('Create invoice'));
    await tester.tap(find.text('Create invoice'));
    await tester.pump();
    pending.completeError(TimeoutException('Timed out'));
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('laundry-catalog-retry')));
    await tester.tap(find.byKey(const ValueKey('laundry-catalog-retry')));
    await tester.pumpAndSettle();
    expect(repo.reads, 3);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        '3.0');
    expect(find.text('Shirt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
