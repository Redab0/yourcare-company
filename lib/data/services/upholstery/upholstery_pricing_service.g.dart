// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upholstery_pricing_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _UpholsteryPricingService implements UpholsteryPricingService {
  _UpholsteryPricingService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<ResponsePayload<List<UpholsteryBusinessCategory>>>>
      getActiveCategories(String languageCode) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Accept-Language': languageCode};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<
        ApiResponse<ResponsePayload<List<UpholsteryBusinessCategory>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business-categories/active',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<UpholsteryBusinessCategory>>> _value;
    try {
      _value = ApiResponse<
          ResponsePayload<List<UpholsteryBusinessCategory>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<UpholsteryBusinessCategory>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<UpholsteryBusinessCategory>(
                    (i) => UpholsteryBusinessCategory.fromJson(
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
  Future<ApiResponse<ResponsePayload<List<UpholsteryPricingGroup>>>>
      getMyUpholsteryPackages() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<
        ApiResponse<ResponsePayload<List<UpholsteryPricingGroup>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business/upholstery-packages',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<UpholsteryPricingGroup>>> _value;
    try {
      _value =
          ApiResponse<ResponsePayload<List<UpholsteryPricingGroup>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<UpholsteryPricingGroup>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<UpholsteryPricingGroup>(
                    (i) => UpholsteryPricingGroup.fromJson(
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
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateMyUpholsteryPricing(UpholsteryPricingRequest request) async {
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
            '/business/my-business/upholstery-pricing',
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
