// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laundry_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _LaundryService implements LaundryService {
  _LaundryService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<ResponsePayload<LaundrySettings>>> getSettings() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundrySettings>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-settings',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundrySettings>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundrySettings>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundrySettings>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundrySettings.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<LaundrySettings>>> updateSettings(
    LaundrySettingsRequest body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundrySettings>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-settings',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundrySettings>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundrySettings>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundrySettings>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundrySettings.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<List<LaundryServiceDefinition>>>>
      getServices() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<
        ApiResponse<ResponsePayload<List<LaundryServiceDefinition>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-services',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<LaundryServiceDefinition>>> _value;
    try {
      _value =
          ApiResponse<ResponsePayload<List<LaundryServiceDefinition>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<LaundryServiceDefinition>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<LaundryServiceDefinition>(
                    (i) => LaundryServiceDefinition.fromJson(
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
  Future<ApiResponse<ResponsePayload<List<LaundryCategory>>>>
      getCategories() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<List<LaundryCategory>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-categories',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<LaundryCategory>>> _value;
    try {
      _value = ApiResponse<ResponsePayload<List<LaundryCategory>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<LaundryCategory>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<LaundryCategory>(
                    (i) => LaundryCategory.fromJson(i as Map<String, dynamic>),
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
  Future<ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>> getCatalog({
    CancelToken? cancelToken,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-catalog',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<LaundryCatalogItem>>> _value;
    try {
      _value = ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<LaundryCatalogItem>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<LaundryCatalogItem>(
                    (i) => LaundryCatalogItem.fromJson(
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
  Future<ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>> updatePrices(
    LaundryBulkPricesRequest body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-catalog/prices',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<LaundryCatalogItem>>> _value;
    try {
      _value = ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<LaundryCatalogItem>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<LaundryCatalogItem>(
                    (i) => LaundryCatalogItem.fromJson(
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
  Future<ApiResponse<ResponsePayload<LaundryCatalogItem>>> configureProduct(
    String productId,
    LaundryProductConfig body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryCatalogItem>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-products/${productId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryCatalogItem>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryCatalogItem>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryCatalogItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryCatalogItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<LaundryCatalogItem>>> createItem(
    LaundryCatalogMutation body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryCatalogItem>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-catalog',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryCatalogItem>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryCatalogItem>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryCatalogItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryCatalogItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<LaundryCatalogItem>>> updateItem(
    String itemId,
    LaundryCatalogMutation body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryCatalogItem>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-catalog/${itemId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryCatalogItem>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryCatalogItem>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryCatalogItem>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryCatalogItem.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<dynamic>>> deactivateItem(
    String itemId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ApiResponse<ResponsePayload<dynamic>>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/laundry-catalog/${itemId}',
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
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> getOrder(
    String id,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryHistory>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/requests/laundry/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryHistory>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryHistory>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryHistory>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryHistory.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> updateStatus(
    String id,
    LaundryStatusRequest body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryHistory>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/requests/laundry/${id}/status',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryHistory>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryHistory>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryHistory>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryHistory.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> saveInvoice(
    String id,
    LaundryInvoiceRequest body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryHistory>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/requests/laundry/${id}/invoice',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryHistory>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryHistory>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryHistory>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryHistory.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> sendInvoice(
    String id,
    LaundryInvoiceSendRequest body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<LaundryHistory>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/requests/laundry/${id}/invoice/send',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<LaundryHistory>> _value;
    try {
      _value = ApiResponse<ResponsePayload<LaundryHistory>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<LaundryHistory>.fromJson(
          json as Map<String, dynamic>,
          (json) => LaundryHistory.fromJson(json as Map<String, dynamic>),
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
