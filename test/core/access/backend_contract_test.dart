import 'dart:convert';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixture = jsonDecode(
      File('test/fixtures/release_expansion_backend.json')
          .readAsStringSync()) as Map<String, dynamic>;
  for (final allowed in [true, false]) {
    test(
        'actual backend company HTTP envelope parses ${allowed ? 'visible' : 'redacted'} request',
        () async {
      expect(fixture['fixtureVersion'], 2);
      expect(fixture['syntheticOnly'], isTrue);
      final dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
      dio.httpClientAdapter = _Reply(fixture[
          allowed ? 'allowedCompanyRequest' : 'restrictedCompanyRequest']);
      final response = await JobsService(dio).getJob('HK-RELEASE-FIXTURE');
      final order = response.data!.data! as HouseKeepingHistory;
      expect(response.success, isTrue);
      expect(response.data!.locale, 'en');
      expect(order.totalPrice, allowed ? 38.4 : isNull);
      expect(order.pricesHidden, !allowed);
      expect(order.companyCampaignVisible, allowed);
      expect(order.hasVisibleCampaignBenefit, allowed);
      expect(order.detail.cleanersCount, 2);
      expect(
          order.detail.numberOfCleaners!.option!.price, allowed ? 2 : isNull);
      expect(order.subRequests, hasLength(8));
      expect(order.subRequests!.first.date!.toUtc(),
          DateTime.parse('2030-10-20T06:30:00Z'));
      expect(order.subRequests![1].date!.toUtc(),
          DateTime.parse('2030-10-22T11:00:00Z'));
      dio.close();
    });
  }
  test('actual staff DTO returns computed effective price booleans', () {
    final staff = (fixture['staff'] as List)
        .map((json) => User.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    expect(staff.map((user) => user.effectiveCanSeePrices),
        [false, true, false, true]);
  });
  test(
      'request reference is compatible with bare IDs and populated Mongo objects',
      () {
    final raw = Map<String, dynamic>.from(
        fixture['allowedCompanyRequest']['data']['data']);
    for (final reference in [
      '507f1f77bcf86cd799439021',
      {'_id': '507f1f77bcf86cd799439021'}
    ]) {
      final order = CleaningRequest.fromJson({...raw, 'businessId': reference})
          as HouseKeepingHistory;
      expect(order.companyInformation?.id, '507f1f77bcf86cd799439021');
      expect(order.companyInformation?.name, isNull);
    }
  });
}

class _Reply implements HttpClientAdapter {
  _Reply(this.payload);
  final dynamic payload;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (options.method != 'GET' ||
        options.path != '/company/requests/HK-RELEASE-FIXTURE') {
      throw StateError('Unexpected fixture request');
    }
    return ResponseBody.fromString(jsonEncode(payload), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}
