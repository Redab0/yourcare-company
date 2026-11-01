import 'dart:convert';
import 'dart:typed_data';
import 'package:cleaning_service_driver/data/models/profile/company_services.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';
import 'package:cleaning_service_driver/data/services/profile/business/business_profile_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/company_services_backend.dart';

Map<String, dynamic> envelope(Map<String, dynamic> data) => {
      'success': true,
      'message': 'ok',
      'data': {'locale': 'en', 'data': data}
    };
void main() {
  test('minimal own context has no private-profile dependency or money model',
      () async {
    for (final sample in companyServicesBackendCases) {
      final calls = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
      addTearDown(dio.close);
      final body = Map<String, dynamic>.from(sample['body'] as Map);
      dio.httpClientAdapter = _Adapter((options) {
        calls.add(options.path);
        expect(options.method, 'GET');
        return (sample['status'] as int, body);
      });
      final result =
          await BusinessProfileRepository(BusinessProfileService(dio))
              .getCompanyServices();
      final data = (body['data'] as Map)['data'] as Map;
      expect(result.businessId, data['businessId']);
      expect(result.services, data['services']);
      expect(data.keys.toSet(), {'businessId', 'services'});
      expect(sample['assignedPermissions'], isEmpty);
      expect(sample['privateProfileStatus'], 403);
      expect(sample['genericBusinessStatus'], 403);
      expect(calls, ['/business/my-services'],
          reason: sample['actorCase'] as String);
    }
  });
  for (final status in [404, 400]) {
    test('old backend $status uses only a fresh authorized profile fallback',
        () async {
      final calls = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
      dio.httpClientAdapter = _Adapter((options) {
        calls.add(options.path);
        return options.path.endsWith('my-services')
            ? (status, {'message': 'Invalid resource ID'})
            : (
                200,
                envelope({
                  'id': 'company',
                  'services': ['houseCleaning']
                })
              );
      });
      final result =
          await BusinessProfileRepository(BusinessProfileService(dio))
              .getCompanyServices();
      expect(result.services, ['houseCleaning']);
      expect(calls, ['/business/my-services', '/business/my-business']);
    });
  }
  for (final status in [400, 401, 403, 503]) {
    test('context $status does not weaken profile authorization', () async {
      final calls = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
      dio.httpClientAdapter = _Adapter((options) {
        calls.add(options.path);
        return (status, {'message': 'Access unavailable'});
      });
      await expectLater(
          BusinessProfileRepository(BusinessProfileService(dio))
              .getCompanyServices(),
          throwsA(isA<DioException>()));
      expect(calls, ['/business/my-services']);
    });
  }
  test('unsupported new route never overrides denied old private profile',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    dio.httpClientAdapter = _Adapter((options) =>
        options.path.endsWith('my-services')
            ? (400, {'message': 'Invalid resource ID'})
            : (403, {'message': 'Forbidden'}));
    await expectLater(
        BusinessProfileRepository(BusinessProfileService(dio))
            .getCompanyServices(),
        throwsA(isA<DioException>()
            .having((e) => e.response?.statusCode, 'status', 403)));
  });
  test('malformed context fails closed; empty actual service list is valid',
      () {
    expect(
        CompanyServices.fromJson({'businessId': 'company', 'services': []})
            .services,
        isEmpty);
    for (final value in [
      {'businessId': null, 'services': []},
      {'businessId': 'company', 'services': null},
      {
        'businessId': 'company',
        'services': [1]
      }
    ]) {
      expect(() => CompanyServices.fromJson(value), throwsFormatException);
    }
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.reply);
  final (int, Map<String, dynamic>) Function(RequestOptions) reply;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    final result = reply(options);
    return ResponseBody.fromString(jsonEncode(result.$2), result.$1, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}
