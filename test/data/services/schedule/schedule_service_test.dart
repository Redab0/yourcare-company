import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';
import 'package:cleaning_service_driver/data/services/schedule/schedule_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GET availability sends every supported service type as a query',
      () async {
    final requestedServiceTypes = <String>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestedServiceTypes.add(
            options.queryParameters['serviceType'] as String,
          );
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Success',
                'data': {
                  'data': [
                    {
                      'id': 'slot-id',
                      'dayOfWeek': 4,
                      'startHour': 8,
                      'endHour': 17,
                      'totalCleaners': 5,
                    },
                  ],
                  'locale': 'en',
                },
              },
            ),
          );
        },
      ),
    );
    final service = ScheduleService(dio);

    for (final serviceType in AvailabilityServiceType.values) {
      final response = await service.getCleanerAvailability(
        serviceType.apiValue,
      );
      expect(response.data?.data, hasLength(1));
      expect(response.data?.data?.single.serviceType, isNull);
    }

    expect(
      requestedServiceTypes,
      AvailabilityServiceType.values
          .map((serviceType) => serviceType.apiValue)
          .toList(),
    );
  });

  test('create sends serviceType while editing omits it', () async {
    final capturedRequests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedRequests.add(options);
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Success',
                'data': {
                  'data': {
                    'id': 'slot-id',
                    'dayOfWeek': 4,
                    'startHour': 8,
                    'endHour': 17,
                    'totalCleaners': 5,
                  },
                  'locale': 'en',
                },
              },
            ),
          );
        },
      ),
    );
    final repository = ScheduleRepository(ScheduleService(dio));
    const request = CleanerAvailabilityRequest(
      dayOfWeek: 4,
      startHour: 8,
      endHour: 17,
      totalCleaners: 5,
      serviceType: AvailabilityServiceType.carWash,
    );

    await repository.createCleanerAvailability(request);
    await repository.updateCleanerAvailability('slot-id', request);

    final createBody = capturedRequests[0].data as Map<String, dynamic>;
    final updateBody = capturedRequests[1].data as Map<String, dynamic>;
    expect(capturedRequests[0].method, 'POST');
    expect(createBody['serviceType'], 'carWash');
    expect(capturedRequests[1].method, 'PATCH');
    expect(updateBody, isNot(contains('serviceType')));
    expect(updateBody, {
      'dayOfWeek': 4,
      'startHour': 8,
      'endHour': 17,
      'totalCleaners': 5,
    });
  });
}
