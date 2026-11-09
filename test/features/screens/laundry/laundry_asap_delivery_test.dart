import 'dart:io';
import 'dart:ui' as ui;

import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_job_details_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_presentation.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:cleaning_service_driver/features/screens/requests/cleaning_requests_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../data/models/laundry/laundry_models_test.dart'
    show laundryFixture;
import '../../../helpers/price_access_fixture.dart';

Widget _app(Widget child, String locale) => MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RepaintBoundary(key: const ValueKey('asap-preview'), child: child),
    );

const _previewDir = String.fromEnvironment('PROVIDER_ASAP_PREVIEW_DIR');
Future<void> _capture(WidgetTester tester, String name) async {
  if (_previewDir.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('asap-preview')));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory(_previewDir);
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

class _RequestsBloc extends Cubit<RequestsState> implements RequestsBloc {
  _RequestsBloc(LaundryHistory order)
      : super(RequestsState(all: [order], hasMoreAll: false));
  @override
  void add(RequestsEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _asapFixture(String option) {
  final fixture = laundryFixture();
  fixture['Laundry'] = <String, dynamic>{
    ...Map<String, dynamic>.from(fixture['Laundry'] as Map),
    'pickupMode': 'asap',
    'deliveryOption': option,
    'deliveryDate': option == 'same_day' ? '2026-11-09' : '2026-11-10',
    'sameDay': option == 'same_day',
    // Operational timestamp remains parseable, but is not a booked appointment.
    'scheduledTime': '2026-11-08T22:30:00.000Z',
  };
  return fixture;
}

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Zain');
    for (final weight in ['Regular', 'Bold', 'Black', 'ExtraBold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Zain-$weight.ttf'));
    }
    await fonts.load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  setUp(grantPriceAccess);
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  tearDown(() async => sl.reset());

  test('ASAP snapshot survives parsing, terminal projection and invoice copies',
      () {
    final fixture = _asapFixture('next_day');
    fixture['requestStatus'] = 'completed';
    final order = CleaningRequest.fromJson(fixture) as LaundryHistory;
    final updated = order.copyWithExtraInvoice(
        extraFees: 1,
        extraFeesDescription: 'extra',
        awaitingExtraPayment: true);
    for (final details in [order.detail, order.displayDetail, updated.detail]) {
      expect(details.isAsapPickup, isTrue);
      expect(details.deliveryOption, 'next_day');
      expect(details.deliveryDate, '2026-11-10');
      expect(details.sameDay, isFalse);
      final json = details.toJson();
      expect(json['pickupMode'], 'asap');
      expect(json['deliveryOption'], 'next_day');
      expect(json['deliveryDate'], '2026-11-10');
    }
    expect(order.displayDetail.status, 'completed');
  });

  test('legacy standard service is never inferred to promise Next Day', () {
    final order = LaundryHistory.fromJson(laundryFixture());
    expect(order.detail.isAsapPickup, isFalse);
    expect(order.detail.deliveryOption, isNull);
    expect(order.detail.deliveryDate, isNull);
    expect(order.detail.sameDay, isFalse);
  });

  for (final locale in ['en', 'ar']) {
    for (final width in [360.0, 800.0]) {
      for (final option in ['same_day', 'next_day']) {
        testWidgets('ASAP $option list/detail $locale at $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 1100);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          sl.registerSingleton<LaundryRepository>(
              LaundryRepository(LaundryService(Dio())));
          final order = LaundryHistory.fromJson(_asapFixture(option));
          await tester.pumpWidget(
              _app(Scaffold(body: JobTile(request: order)), locale));
          await tester.pumpAndSettle();
          var context = tester.element(find.byType(JobTile));
          var l10n = AppLocalizations.of(context)!;
          final choice = option == 'same_day'
              ? l10n.laundry_same_day
              : l10n.laundry_next_day;
          final date = laundryDeliveryDateLabel(
              context, option == 'same_day' ? '2026-11-09' : '2026-11-10')!;
          expect(find.text(choice), findsOneWidget);
          expect(
              find.text('${l10n.laundry_pickup}: ${l10n.laundry_pickup_asap}'),
              findsOneWidget);
          expect(find.text('${l10n.laundry_delivery_date}: $date'),
              findsOneWidget);
          expect(find.textContaining('22:30'), findsNothing);
          expect(tester.takeException(), isNull);
          await _capture(tester, 'list-$option-$locale-$width');

          await tester.pumpWidget(
              _app(LaundryJobDetailsScreen(request: order), locale));
          await tester.pumpAndSettle();
          context = tester.element(find.byType(LaundryJobDetailsScreen));
          l10n = AppLocalizations.of(context)!;
          expect(find.text(l10n.laundry_pickup_asap), findsOneWidget);
          expect(find.text(choice), findsNWidgets(2));
          expect(find.text(date), findsOneWidget);
          expect(find.text(l10n.request_date_time), findsNothing);
          expect(tester.takeException(), isNull);
          await _capture(tester, 'detail-$option-$locale-$width');
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }

      testWidgets('legacy pickup schedule stays dated $locale at $width',
          (tester) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        sl.registerSingleton<LaundryRepository>(
            LaundryRepository(LaundryService(Dio())));
        final order = LaundryHistory.fromJson(laundryFixture());
        await tester
            .pumpWidget(_app(LaundryJobDetailsScreen(request: order), locale));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(LaundryJobDetailsScreen));
        final l10n = AppLocalizations.of(context)!;
        expect(find.text(l10n.request_date_time), findsOneWidget);
        expect(find.text(l10n.laundry_pickup_asap), findsNothing);
        expect(find.text(l10n.laundry_next_day), findsNothing);
        expect(find.text(l10n.laundry_delivery_date), findsNothing);
        expect(laundryDeliveryDateLabel(context, '2026-02-30'), isNull);
        expect(
            laundryDeliveryDateLabel(context, '2026-11-09T00:00:00Z'), isNull);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in ['en', 'ar']) {
    testWidgets('collapsed request summary retains ASAP delivery $locale',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final order = LaundryHistory.fromJson(_asapFixture('next_day'));
      final bloc = _RequestsBloc(order);
      addTearDown(bloc.close);
      await tester.pumpWidget(_app(
          BlocProvider<RequestsBloc>.value(
              value: bloc, child: const RequestsScreen()),
          locale));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(RequestsScreen));
      final l10n = AppLocalizations.of(context)!;
      final date = laundryDeliveryDateLabel(context, '2026-11-10');
      expect(
          find.text(
              '${l10n.laundry_pickup}: ${l10n.laundry_pickup_asap} · ${l10n.laundry_next_day} · $date'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
