import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/api/api_diagnostics_interceptor.dart';
import 'package:cleaning_service_driver/core/api/stack_contract.dart';
import 'package:cleaning_service_driver/core/api/upload_limits.dart';
import 'package:cleaning_service_driver/core/diagnostics/app_diagnostics.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/widgets/environment_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('invalid environments fail; API and chat use the same origin', () {
    expect(() => ApiEnvironment.validate('developmnt'), throwsStateError);
    ApiEnvironment.validate();
    expect(Uri.parse(ApiEnvironment.chatUrl).host,
        Uri.parse(ApiEnvironment.apiUrl).host);
    expect(Uri.parse(ApiEnvironment.chatUrl).path, '/chat');
    expect(ApiEnvironment.isDevelopment,
        const String.fromEnvironment('API_ENV') == 'development');
  });

  test(
      'sessions and logout are isolated without migrating production credentials',
      () async {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'production-session',
      'development_access_token': 'development-session',
      'areas': 'production-cache',
      'development_areas': 'development-cache',
    });
    final storage = SecureStorageService();
    final dev = ApiEnvironment.isDevelopment;
    expect(await storage.getAccessToken(),
        dev ? 'development-session' : 'production-session');
    await storage.saveAccessToken('updated');
    expect(await storage.getAccessToken(), 'updated');
    await storage.clearAll();
    expect(await storage.getAccessToken(), isNull);
    const raw = FlutterSecureStorage();
    expect(
        await raw.read(key: dev ? 'access_token' : 'development_access_token'),
        dev ? 'production-session' : 'development-session');
    expect(await raw.read(key: dev ? 'areas' : 'development_areas'),
        dev ? 'production-cache' : 'development-cache');
  });

  test('request IDs survive retries and malformed values are replaced',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors
        .add(ApiDiagnosticsInterceptor(newId: () => 'fixture-request-id'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    final valid = await dio.get('https://fixture.invalid/api/requests',
        options: Options(headers: {'x-request-id': 'valid-request-id'}));
    expect(valid.requestOptions.headers['X-Request-ID'], 'valid-request-id');
    expect(
        valid.requestOptions.headers.keys
            .where((key) => key.toLowerCase() == 'x-request-id'),
        hasLength(1));
    final malformed = await dio.get('https://fixture.invalid/api/requests',
        options: Options(headers: {'X-Request-ID': 'bad\r\nvalue'}));
    expect(
        malformed.requestOptions.headers['X-Request-ID'], 'fixture-request-id');
  });

  test('diagnostics never retain records or call a configured sink', () async {
    var called = false;
    AppDiagnostics.sink = (_) async {
      called = true;
    };
    AppDiagnostics.recordError(StateError('secret-token'), StackTrace.empty);
    AppDiagnostics.recordApi(
        method: 'POST',
        operation: 'requests',
        status: 500,
        requestId: 'sensitive');
    await Future<void>.delayed(Duration.zero);
    expect(AppDiagnostics.records, isEmpty);
    expect(AppDiagnostics.sink, isNull);
    expect(called, isFalse);
  });

  test('framework errors are handled without a diagnostic record', () {
    final flutterHandler = FlutterError.onError;
    final platformHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = flutterHandler;
      PlatformDispatcher.instance.onError = platformHandler;
    });
    AppDiagnostics.installErrorHandlers();
    expect(
        PlatformDispatcher.instance.onError!(
            ArgumentError('secret'), StackTrace.empty),
        isTrue);
    expect(AppDiagnostics.records, isEmpty);
    expect(FlutterError.onError, isNot(same(flutterHandler)));
  });

  test('canonical order states exclude payment, offer and display aliases', () {
    expect(OrderStatus.values.map((s) => s.wireValue).toSet(), {
      'notPaid',
      'pending',
      'confirmed',
      'inProgress',
      'completed',
      'canceled'
    });
    for (final value in ['paid', 'accepted', 'cancelled', 'pickup_pending']) {
      expect(OrderStatus.fromWire(value), isNull);
    }
    expect(ServiceType.values.map((s) => s.wireValue).toSet(), {
      'houseCleaning',
      'carWash',
      'upholsteryCleaning',
      'deepCleaning',
      'laundry'
    });
  });

  test(
      'upload limits reject excessive count, file size and aggregate before upload',
      () {
    expect(() => UploadLimits.validate([]), throwsFormatException);
    expect(
        () => UploadLimits.validate(List.filled(11, const UploadFileSize(1))),
        throwsFormatException);
    expect(
        () =>
            UploadLimits.validate([const UploadFileSize(20 * 1024 * 1024 + 1)]),
        throwsFormatException);
    expect(
        () => UploadLimits.validate([
              const UploadFileSize(100 * 1024 * 1024, isVideo: true),
              const UploadFileSize(1)
            ]),
        throwsFormatException);
    UploadLimits.validate(
        [const UploadFileSize(100 * 1024 * 1024, isVideo: true)]);
  });

  testWidgets('development is visibly labelled including release builds',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: EnvironmentBanner(child: Text('content'))));
    // MaterialApp's debug banner is separate from our environment ribbon.
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Banner && widget.message == 'DEV'),
        ApiEnvironment.isDevelopment ? findsOneWidget : findsNothing);
  });
}
