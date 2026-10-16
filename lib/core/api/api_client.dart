import 'package:cleaning_service_driver/core/api/api_diagnostics_interceptor.dart';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import '../security/request_security_interceptor.dart';
import '../security/bounded_response_adapter.dart';
import '../security/session_state.dart';
import '../security/session_renewal_coordinator.dart';
import '../security/session_renewal_transport.dart';
import 'session_error_interceptor.dart';
import '../../features/chats/data/chat_socket_service.dart';
import 'package:cleaning_service_driver/core/api/session_request_interceptor.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:dio/dio.dart';

/// A simple, reusable API client using Dio.
/// You can extend this for auth and error handling.
class ApiClient {
  final Dio _dio;
  late final SessionRenewalCoordinator sessions;

  /// Base URL for your API (change as needed)
  // static const String baseUrl = 'https://be-cleaning.yourcarehere.com/api';
  static const String prod_baseUrl = 'https://be-cleaning.yourcarehere.com/api';
  static const String dev_baseUrl =
      'https://dev-be-cleaning.yourcarehere.com/api';
  static const String baseUrl = ApiEnvironment.apiUrl;

  /// Singleton instance
  static final ApiClient _instance = ApiClient._internal();

  /// Factory constructor to return the same instance
  factory ApiClient() => _instance;

  /// Private constructor for singleton
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            followRedirects: false,
            maxRedirects: 0,
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json', 'channel': 'MANAGER'},
          ),
        ) {
    ApiEnvironment.validate();
    _dio.httpClientAdapter = BoundedResponseAdapter(_dio.httpClientAdapter);
    sessions = SessionRenewalCoordinator(
      storage: SecureStorageService(),
      onTerminal: clearSessionState,
      onRotated: () async {
        if (sl.isRegistered<ChatSocketService>()) {
          await sl<ChatSocketService>().refreshCredentials();
        }
      },
      transport: DioSessionRenewalTransport(
        adapter: () => _dio.httpClientAdapter,
        languageTag: () => sl<LocaleCubit>().state.toLanguageTag(),
      ),
    );
    _dio.interceptors.add(RequestSecurityInterceptor(
        accountGeneration: () => sessions.storage.authGeneration));
    _dio.interceptors.add(ApiDiagnosticsInterceptor());
    _dio.interceptors.add(SessionRequestInterceptor(
      readAccessToken: () async => (await sessions.ensureSession())?.token,
      accountGeneration: () => sessions.storage.authGeneration,
      languageTag: () => sl<LocaleCubit>().state.toLanguageTag(),
    ));
    _dio.interceptors.add(SessionErrorInterceptor(sessions, _dio));
  }

  /// Expose Dio if you need full access
  Dio get dio => _dio;

  /// Generic GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Generic DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
