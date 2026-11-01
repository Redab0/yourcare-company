import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/data/repositories/upholstery/upholstery_pricing_repository.dart';
import 'package:cleaning_service_driver/data/services/upholstery/upholstery_pricing_service.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/update_upholstery_pricing_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _envelope(Object? data, {bool success = true}) => {
      'success': success,
      'message': success ? 'Success' : 'Permission denied',
      'data': {'data': data, 'locale': 'en'},
    };

const _stored = {
  'upholsteryTypeId': 'sofa-id',
  'enabled': false,
  'packages': [
    {
      '_id': 'stable-package-id',
      'titleEn': 'Single seat',
      'titleAr': 'مقعد واحد',
      'price': 1.125,
      'discountPercentage': 12.5,
    },
  ],
};

void main() {
  test('provider GET opts into disabled pricing and PATCH retains its flag',
      () async {
    final calls = <RequestOptions>[];
    final repository = _repository((options) {
      calls.add(options);
      if (options.method == 'GET') return _envelope([_stored]);
      return _envelope({
        'id': 'business-id',
        'upholsteryPricing': [_stored]
      });
    });
    final groups = await repository.getPackages();
    expect(calls.single.queryParameters, {'includeDisabled': true});
    expect(groups.single.isEnabled, isFalse);
    final saved = await UpdateUpholsteryPricingUseCase(repository)(
      UpholsteryPricingRequest(pricing: groups),
    );
    expect(calls.last.path, '/business/my-business/upholstery-pricing');
    expect(calls.last.method, 'PATCH');
    expect(calls.last.queryParameters, {'includeDisabled': true});
    expect((calls.last.data as Map)['pricing'], [
      {
        'upholsteryTypeId': 'sofa-id',
        'enabled': false,
        'packages': [
          {
            'titleEn': 'Single seat',
            'titleAr': 'مقعد واحد',
            'price': 1.125,
            'discountPercentage': 12.5,
          },
        ],
      },
    ]);
    expect(saved.single.packages.single.packageId, 'stable-package-id');
    expect(saved.single.isEnabled, isFalse);
    expect((await repository.getPackages()).single, saved.single);
  });

  test('availability uses typed body and server value with the double envelope',
      () async {
    final calls = <RequestOptions>[];
    final repository = _repository((options) {
      calls.add(options);
      return _envelope({'available': options.method == 'GET'});
    });
    expect((await repository.getAvailability()).available, isTrue);
    // The returned persisted state is authoritative even when it differs.
    expect(
        (await repository.updateAvailability(
          const UpdateUpholsteryAvailabilityRequest(available: true),
        ))
            .available,
        isFalse);
    expect(calls.map((call) => call.path),
        everyElement('/business/my-business/upholstery-availability'));
    expect(calls.last.method, 'PATCH');
    expect(calls.last.data, {'available': true});
    expect(calls.last.queryParameters, isEmpty);
  });

  test('missing canonical save response is an error, not guessed success',
      () async {
    final repository = _repository((_) => _envelope({'id': 'business-id'}));
    await expectLater(
      UpdateUpholsteryPricingUseCase(repository)(
          UpholsteryPricingRequest(pricing: [])),
      throwsFormatException,
    );
  });

  test('missing pricing GET is an error rather than an empty priced catalog',
      () async {
    final repository = _repository((_) => _envelope(null));
    await expectLater(repository.getPackages(), throwsFormatException);
  });

  for (final payload in [
    null,
    {},
    {'available': null},
    {'available': 'false'}
  ]) {
    test('availability rejects missing or malformed persisted state: $payload',
        () async {
      final repository = _repository((_) => _envelope(payload));
      await expectLater(repository.getAvailability(), throwsA(anything));
      await expectLater(
          repository.updateAvailability(
            const UpdateUpholsteryAvailabilityRequest(available: false),
          ),
          throwsA(anything));
    });
  }

  for (final code in [401, 403, 404, 500]) {
    test('availability preserves HTTP $code without fallback or extra write',
        () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final calls = <RequestOptions>[];
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        calls.add(options);
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: code),
        ));
      }));
      final repository =
          UpholsteryPricingRepository(UpholsteryPricingService(dio));
      await expectLater(
          repository.updateAvailability(
            const UpdateUpholsteryAvailabilityRequest(available: false),
          ),
          throwsA(isA<DioException>()
              .having((error) => error.response?.statusCode, 'status', code)));
      expect(calls, hasLength(1));
    });
  }

  test('unsuccessful envelope never yields availability success', () async {
    final repository =
        _repository((_) => _envelope({'available': false}, success: false));
    await expectLater(repository.getAvailability(), throwsException);
  });
}

UpholsteryPricingRepository _repository(
    Object? Function(RequestOptions) respond) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    handler.resolve(Response(
        requestOptions: options, statusCode: 200, data: respond(options)));
  }));
  return UpholsteryPricingRepository(UpholsteryPricingService(dio));
}
