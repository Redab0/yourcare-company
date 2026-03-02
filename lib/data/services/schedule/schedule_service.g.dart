// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _ScheduleService implements ScheduleService {
  _ScheduleService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<ResponsePayload<List<CleanerAvailabilitySlot>>>>
      getCleanerAvailability() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<
        ApiResponse<ResponsePayload<List<CleanerAvailabilitySlot>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/company/cleaner-availability',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<CleanerAvailabilitySlot>>> _value;
    try {
      _value =
          ApiResponse<ResponsePayload<List<CleanerAvailabilitySlot>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<CleanerAvailabilitySlot>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<CleanerAvailabilitySlot>(
                    (i) => CleanerAvailabilitySlot.fromJson(
                      i as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : List.empty(),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>>
      createCleanerAvailability(CleanerAvailabilityRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/company/cleaner-availability',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<CleanerAvailabilitySlot>> _value;
    try {
      _value = ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<CleanerAvailabilitySlot>.fromJson(
          json as Map<String, dynamic>,
          (json) =>
              CleanerAvailabilitySlot.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>>
      updateCleanerAvailability(
          String id, CleanerAvailabilityRequest body) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/company/cleaner-availability/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<CleanerAvailabilitySlot>> _value;
    try {
      _value = ApiResponse<ResponsePayload<CleanerAvailabilitySlot>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<CleanerAvailabilitySlot>.fromJson(
          json as Map<String, dynamic>,
          (json) =>
              CleanerAvailabilitySlot.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> deleteCleanerAvailability(
    String id,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/company/cleaner-availability/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<dynamic>> _value;
    try {
      _value = ApiResponse<ResponsePayload<dynamic>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<dynamic>.fromJson(
          json as Map<String, dynamic>,
          (json) => json as dynamic,
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
