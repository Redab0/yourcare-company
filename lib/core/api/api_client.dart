import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// A simple, reusable API client using Dio.
/// You can extend this for auth, error handling, and logging.
class ApiClient {
  final Dio _dio;

  /// Base URL for your API (change as needed)
  static const String baseUrl = 'https://be-cleaning.yourcarehere.com/api';

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
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    // Optional: Add interceptors for logging or auth
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
    ));

    // Example: Auth header interceptor (you can modify this)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Language (use the SAME LocaleCubit instance you provided to the app)
          final langTag =
              sl<LocaleCubit>().state.toLanguageTag(); // e.g. "ar" or "ar-AE"
          options.headers['Accept-Language'] = langTag;
          options.headers['locale'] = langTag;
          final token = await SecureStorageService().getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors, e.g., token expired
          return handler.next(e);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
            requestBody: true,
            requestHeader: true,
            responseHeader: true,
            compact: false),
      );
    }
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
