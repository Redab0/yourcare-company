import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:cleaning_service_driver/data/services/documents/documents_service.dart';
import 'package:cleaning_service_driver/data/repositories/documents/documents_repository.dart';
import 'package:cleaning_service_driver/domain/usecases/documents/documents_usecases.dart';
import 'package:cleaning_service_driver/features/bloc/documents/documents_cubit.dart';
import 'package:cleaning_service_driver/features/screens/documents/documents_screen.dart';
import 'package:cleaning_service_driver/features/screens/home/business_home_service.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';

const document = BusinessDocument(
    id: 'abc',
    title: 'Service policy and business contract',
    category: 'contract',
    audience: 'business',
    fileName: 'contract-2026.pdf',
    mimeType: 'application/pdf',
    size: 3072);
const imageDocument = BusinessDocument(
    id: 'image-1',
    title: 'Office map',
    category: 'other',
    audience: 'business',
    fileName: 'office-map.png',
    mimeType: 'image/png',
    size: 68);
const samplePage = DocumentPage(docs: [
  document,
  BusinessDocument(
      id: 'safety',
      title: 'Health and safety handbook',
      category: 'policy',
      audience: 'business',
      fileName: 'safety.pdf',
      mimeType: 'application/pdf',
      size: 2048),
  imageDocument,
  BusinessDocument(
      id: 'guide',
      title: 'Employee guide',
      category: 'other',
      audience: 'business',
      fileName: 'guide.pdf',
      mimeType: 'application/pdf',
      size: 4096),
], page: 1, totalPages: 1);

class FakeCases implements DocumentsUseCases {
  Future<DocumentPage> Function(int)? handler;
  Uint8List? responseBytes;
  int downloadCalls = 0;
  @override
  Future<DocumentPage> list({int page = 1, String? search, String? category}) =>
      handler?.call(page) ?? Future.value(samplePage);
  @override
  Future<Uint8List> download(String id) async {
    downloadCalls++;
    return responseBytes ?? Uint8List.fromList([37, 80, 68, 70]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    await (FontLoader('Zain')
          ..addFont(rootBundle.load('assets/fonts/Zain-Regular.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  test('documents visible to owners and managers, not workers', () {
    expect(
        BusinessHomeService.documentsCenter.canShow(
            permissions: [], companyServices: null, isBusinessOwner: true),
        true);
    expect(
        BusinessHomeService.documentsCenter
            .canShow(permissions: [], companyServices: null, role: 'manager'),
        true);
    expect(
        BusinessHomeService.documentsCenter
            .canShow(permissions: [], companyServices: null, role: 'worker'),
        false);
  });
  test('list cannot send a customer-supplied business ID', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      expect(o.uri.path, '/api/company/documents');
      expect(o.queryParameters,
          {'page': 2, 'limit': 20, 'search': 'policy', 'category': 'policy'});
      h.resolve(Response(requestOptions: o, data: {
        'success': true,
        'message': 'Success',
        'data': {'docs': [], 'page': 2, 'totalPages': 2}
      }));
    }));
    expect(
        (await DocumentsRepository(DocumentsService(dio))
                .list(page: 2, search: 'policy', category: 'policy'))
            .page,
        2);
  });
  test('downloads binary bytes through the session client', () async {
    final dio = Dio(BaseOptions(
        baseUrl: 'https://example.test/api',
        headers: {'Authorization': 'test-session', 'channel': 'MANAGER'}));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      expect(o.uri.path, '/api/company/documents/abc/download');
      expect(o.responseType, ResponseType.bytes);
      expect(o.headers['channel'], 'MANAGER');
      h.resolve(Response(requestOptions: o, data: <int>[37, 80, 68, 70]));
    }));
    expect(await DocumentsRepository(DocumentsService(dio)).download('abc'),
        [37, 80, 68, 70]);
  });
  test('latest response wins', () async {
    final first = Completer<DocumentPage>(), second = Completer<DocumentPage>();
    final cubit = DocumentsCubit(
        FakeCases()..handler = ((p) => p == 1 ? first.future : second.future));
    final a = cubit.load(), b = cubit.load(page: 2);
    second.complete(const DocumentPage(docs: [], page: 2, totalPages: 2));
    await b;
    first.complete(samplePage);
    await a;
    expect(cubit.state.result!.page, 2);
    await cubit.close();
  });
  for (final language in ['en', 'ar']) {
    for (final width in [320.0, 1100.0]) {
      testWidgets('company documents $language at $width', (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubit = DocumentsCubit(FakeCases());
        addTearDown(cubit.close);
        await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light(),
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: AppTheme.textScalerForWidth(width)),
                child: child!),
            home: RepaintBoundary(
                key: const Key('documents'),
                child: DocumentsScreen(cubit: cubit))));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text(document.title), findsOneWidget);
        await expectLater(
            find.byKey(const Key('documents')),
            matchesGoldenFile(
                'goldens/documents-$language-${width.toInt()}.png'));
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets('error retry and empty state', (tester) async {
    final cases = FakeCases()
      ..handler = ((_) async => throw StateError('offline'));
    final cubit = DocumentsCubit(cases);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DocumentsScreen(cubit: cubit)));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    cases.handler =
        (_) async => const DocumentPage(docs: [], page: 1, totalPages: 0);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No documents found'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('grid opens an image with authenticated bytes', (tester) async {
    final cases = FakeCases()
      ..responseBytes = base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL/nwAAAABJRU5ErkJggg==');
    cases.handler = (_) async =>
        const DocumentPage(docs: [imageDocument], page: 1, totalPages: 1);
    final cubit = DocumentsCubit(cases);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DocumentsScreen(cubit: cubit)));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    await tester.tap(find.text('Office map'));
    await tester.pumpAndSettle();
    expect(cases.downloadCalls, 1);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byTooltip('Download'), findsOneWidget);
  });
  testWidgets('invalid PDF bytes show an error instead of loading forever',
      (tester) async {
    final cubit = DocumentsCubit(FakeCases());
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DocumentsScreen(cubit: cubit)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Service policy and business contract'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to open this document.'), findsOneWidget);
    expect(find.byTooltip('Download'), findsOneWidget);
  });
}
