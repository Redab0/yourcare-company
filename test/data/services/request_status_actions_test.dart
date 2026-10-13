import 'package:cleaning_service_driver/core/utils/request_action_error.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';
import 'package:cleaning_service_driver/domain/usecases/jobs/complete_job_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refresh requests the selected company request and maps its status',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.method, 'GET');
      expect(options.path, '/company/requests/CW12');
      expect(options.data, isNull);
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': {
            'id': 'CW12',
            'type': 'carWash',
            'requestStatus': 'inProgress',
            'totalPrice': 10,
            'createdAt': '2026-09-13T10:00:00Z',
            'updatedAt': '2026-09-13T10:00:00Z',
            'customer': {},
            'CarWash': {},
          },
        },
      }));
    }));
    final request = await JobsRepository(JobsService(dio)).getJob('CW12');
    expect(request.requestStatus, RequestStatus.inProgress);
    expect(request.id, 'CW12');
  });

  test(
      'completion preserves the backend rejection for the localized error toast',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.method, 'PATCH');
      expect(options.path, '/requests/CW12/completed');
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'message': 'يرجى تأكيد الطلب أولاً'}),
      ));
    }));
    Object? error;
    try {
      await CompleteJobUseCase(JobsRepository(JobsService(dio))).call('CW12');
    } catch (e) {
      error = e;
    }
    expect(error, isA<DioException>());
    expect(requestActionErrorMessage(error!), 'يرجى تأكيد الطلب أولاً');
  });
}
