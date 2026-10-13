import 'dart:async';
import 'package:cleaning_service_driver/core/api/session_request_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keychain errors reject the request instead of leaving it pending',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    var dispatched = 0;
    dio.interceptors.add(SessionRequestInterceptor(
        readAccessToken: () async =>
            throw PlatformException(code: 'keychain-unavailable'),
        languageTag: () => 'en'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatched++;
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    await expectLater(
        dio.get('/catalog').timeout(const Duration(seconds: 1)),
        throwsA(isA<DioException>().having(
            (e) => e.error, 'underlying error', isA<PlatformException>())));
    expect(dispatched, 0);
  });
  test(
      'an unresolved keychain read expires and never dispatches when its token arrives late',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final token = Completer<String?>();
    var dispatched = 0;
    dio.interceptors.add(SessionRequestInterceptor(
        readAccessToken: () => token.future,
        languageTag: () => 'en',
        credentialsTimeout: const Duration(milliseconds: 20)));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatched++;
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    await expectLater(
        dio.get('/catalog'),
        throwsA(isA<DioException>().having(
            (e) => e.error, 'underlying timeout', isA<TimeoutException>())));
    token.complete('late-token');
    await Future<void>.delayed(Duration.zero);
    expect(dispatched, 0);
  });
  test('locale preparation errors reject and a subsequent retry can succeed',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    var available = false;
    var dispatched = 0;
    dio.interceptors.add(SessionRequestInterceptor(
        readAccessToken: () async => 'test-token',
        languageTag: () {
          if (!available) throw StateError('Locale unavailable');
          return 'ar';
        }));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatched++;
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    await expectLater(dio.get('/catalog'), throwsA(isA<DioException>()));
    available = true;
    final response = await dio.get('/catalog');
    expect(
        response.requestOptions.headers['Authorization'], 'Bearer test-token');
    expect(response.requestOptions.headers['locale'], 'ar');
    expect(dispatched, 1);
  });
  test(
      'explicit language overrides are kept and absent tokens remain unauthenticated',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(SessionRequestInterceptor(
        readAccessToken: () async => null,
        languageTag: () => throw StateError('Should use explicit language')));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    final response = await dio.get('/catalog',
        options: Options(headers: {'Accept-Language': ' ar '}));
    expect(response.requestOptions.headers['Accept-Language'], 'ar');
    expect(response.requestOptions.headers['locale'], 'ar');
    expect(
        response.requestOptions.headers.containsKey('Authorization'), isFalse);
  });
  test('cancelling during keychain lookup prevents transport dispatch',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final token = Completer<String?>();
    final cancel = CancelToken();
    var dispatched = 0;
    dio.interceptors.add(SessionRequestInterceptor(
        readAccessToken: () => token.future, languageTag: () => 'en'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatched++;
      handler.resolve(Response(requestOptions: options, statusCode: 200));
    }));
    final request = dio.get('/catalog', cancelToken: cancel);
    final rejected = expectLater(
        request,
        throwsA(isA<DioException>()
            .having((e) => e.type, 'type', DioExceptionType.cancel)));
    await Future<void>.delayed(Duration.zero);
    cancel.cancel();
    token.complete('unused-token');
    await rejected;
    expect(dispatched, 0);
  });
}
