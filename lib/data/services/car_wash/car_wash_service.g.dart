// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_wash_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _CarWashService implements CarWashService {
  _CarWashService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<ResponsePayload<CarWashCategoryResponse>>>
      getCarWashCategories() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<CarWashCategoryResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business-categories/car-wash',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<CarWashCategoryResponse>> _value;
    try {
      _value = ApiResponse<ResponsePayload<CarWashCategoryResponse>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<CarWashCategoryResponse>.fromJson(
          json as Map<String, dynamic>,
          (json) =>
              CarWashCategoryResponse.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> getMyCarWashPackages() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-packages',
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

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> createMyCarWashPackage(
    Map<String, dynamic> request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-packages',
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

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> updateMyCarWashPackage(
    String packageId,
    Map<String, dynamic> request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-packages/${packageId}',
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

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> deleteMyCarWashPackage(
    String packageId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-packages/${packageId}',
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

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> updateMyCarWashPricing(
    Map<String, dynamic> request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-pricing',
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

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> upsertMyCarWashAreaFee(
    Map<String, dynamic> request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-area-fees',
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

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> deleteMyCarWashAreaFee(
    String areaId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-area-fees/${areaId}',
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

  @override
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateMyCarWashWorkingHours(CarWashWorkingHoursRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<BusinessProfileModel>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/car-wash-working-hours',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<BusinessProfileModel>> _value;
    try {
      _value = ApiResponse<ResponsePayload<BusinessProfileModel>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<BusinessProfileModel>.fromJson(
          json as Map<String, dynamic>,
          (json) => BusinessProfileModel.fromJson(json as Map<String, dynamic>),
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
