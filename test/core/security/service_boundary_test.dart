import 'package:cleaning_service_driver/core/security/request_security_interceptor.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/services/profile/business/business_profile_service.dart';
import 'package:cleaning_service_driver/data/services/staff/staff_service.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  final dispatched = <RequestOptions>[];
  setUp(() {
    dispatched.clear();
    dio = Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api'));
    dio.interceptors.add(RequestSecurityInterceptor(
        trustedApiUrl: 'https://fixture.invalid/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      dispatched.add(options);
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'message': '',
        'data': {'data': <String, dynamic>{}, 'locale': 'en'}
      }));
    }));
  });
  tearDown(() => dio.close());

  test('staff save rejects malformed field before dispatch', () async {
    final service = StaffService(dio);
    await expectLater(
        service.createUser(CreateUserModel(
            username: 'bad username',
            role: 'worker',
            image: '',
            email: null,
            password: null,
            phone: null)),
        throwsA(isA<DioException>()));
    expect(dispatched, isEmpty);
    await service.createUser(CreateUserModel(
        username: 'worker_1',
        role: 'worker',
        image: '',
        email: null,
        password: null,
        phone: null));
    expect(dispatched, hasLength(1));
    expect((dispatched.single.data as Map).containsKey('password'), isFalse);
  });

  test(
      'company profile saves retain optional clears and normalize Arabic human fields',
      () async {
    await BusinessProfileService(dio).updateCompanyProfile(
        UpdateBusinessProfileModel(' شركة الرعاية ', ' O\'Brien <b>تنظيف</b> ',
            '', null, [], '', '', '', []));
    expect(dispatched, hasLength(1));
    expect(dispatched.single.data['name'], 'شركة الرعاية');
    expect(dispatched.single.data['description'], "O'Brien <b>تنظيف</b>");
    expect(dispatched.single.data['phone'], '');
    expect(dispatched.single.data['logo'], isNull);
    await expectLater(
        BusinessProfileService(dio).updateCompanyProfile(
            UpdateBusinessProfileModel(
                null, null, null, null, null, '+1234567', null, null, null)),
        throwsA(isA<DioException>()));
    expect(dispatched, hasLength(1));
  });

  test(
      'invoice save rejects negative/nonfinite amounts and unsafe reason controls',
      () async {
    final service = JobsService(dio);
    for (final amount in [-1.0, double.nan, double.infinity, 0.0]) {
      await expectLater(
          service.addExtraFees(
              'request-id',
              AddExtraFeesRequest(
                  extraFees: amount, extraFeesDescription: 'سبب')),
          throwsA(isA<DioException>()));
    }
    expect(dispatched, isEmpty);
    await service.addExtraFees(
        'request-id',
        const AddExtraFeesRequest(
            extraFees: 0.001, extraFeesDescription: 'سبب عربي\nسطر جديد'));
    expect(dispatched.single.data['extraFees'], 0.001);
  });
}
