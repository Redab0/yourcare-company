// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _BusinessProfileService implements BusinessProfileService {
  _BusinessProfileService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      getCompanyProfile() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<BusinessProfileModel>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business',
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

  @override
  Future<ApiResponse<ResponsePayload<BusinessProfileModel>>>
      updateCompanyProfile(UpdateBusinessProfileModel model) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(model.toJson());
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<BusinessProfileModel>>>(
      Options(method: 'PATCH', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/business/my-business',
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

  @override
  Future<ApiResponse<ResponsePayload<List<AreaResponse>>>> getAreas() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<List<AreaResponse>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/areas/grouped',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<AreaResponse>>> _value;
    try {
      _value = ApiResponse<ResponsePayload<List<AreaResponse>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<AreaResponse>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<AreaResponse>(
                    (i) => AreaResponse.fromJson(i as Map<String, dynamic>),
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
  Future<ApiResponse<ResponsePayload<List<MediaUploadResponse>>>> uploadMedia(
    List<MultipartFile> files,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.addAll(files.map((i) => MapEntry('images', i)));
    final _options =
        _setStreamType<ApiResponse<ResponsePayload<List<MediaUploadResponse>>>>(
      Options(
        method: 'POST',
        headers: _headers,
        extra: _extra,
        contentType: 'multipart/form-data',
      )
          .compose(
            _dio.options,
            '/upload/multiple',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ApiResponse<ResponsePayload<List<MediaUploadResponse>>> _value;
    try {
      _value = ApiResponse<ResponsePayload<List<MediaUploadResponse>>>.fromJson(
        _result.data!,
        (json) => ResponsePayload<List<MediaUploadResponse>>.fromJson(
          json as Map<String, dynamic>,
          (json) => json is List<dynamic>
              ? json
                  .map<MediaUploadResponse>(
                    (i) => MediaUploadResponse.fromJson(
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
