import 'package:dio/dio.dart';

/// Conservative client policy. Server validation/authorization remains mandatory.
/// Resource ceilings are client safeguards, not new persisted business limits.
abstract final class RequestSecurity {
  static const maxDepth = 16;
  static const maxCollection = 1000;
  static const maxNodes = 10000;
  static const maxText = 16384;
  static const maxTotalText = 1024 * 1024;
  static final _controls = RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]');
  static final _phone = RegExp(r'^[4569][0-9]{7}$');
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _humanFields = {
    'name',
    'nameEn',
    'nameAr',
    'titleEn',
    'titleAr',
    'description',
    'descriptionEn',
    'descriptionAr',
    'descriptionBusinessOffer',
    'timelineBusinessOffer',
    'extraFeesDescription',
    'address',
    'search',
    'email',
    'phone',
    'unitLabel',
  };
  static const _moneyFields = {
    'price',
    'fee',
    'basePricePerCleanerPerHour',
    'cleaningProductsPrice',
    'totalPrice',
    'extraFees',
    'pickupFee',
    'deliveryFee',
    'discount',
    'minimumCharge',
  };
  static const _services = {
    'houseCleaning',
    'deepCleaning',
    'carWash',
    'upholsteryCleaning',
    'laundry',
  };

  static String normalizePhone(String value) =>
      value.trim().replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
        final code = match[0]!.codeUnitAt(0);
        return '${code >= 0x6f0 ? code - 0x6f0 : code - 0x660}';
      });

  static bool validPhone(String value) =>
      _phone.hasMatch(normalizePhone(value));
  static bool validEmail(String value) =>
      value.length <= 254 && _email.hasMatch(value.trim());
  static bool safeText(String value) =>
      value.length <= maxText && !_controls.hasMatch(value);

  static Uri webUri(String value, {bool httpsOnly = false}) {
    if (value.length > 2048 ||
        !safeText(value) ||
        value.trim() != value ||
        value.contains(RegExp(r'[\s\\]'))) {
      throw const FormatException('Invalid web address.');
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        !(httpsOnly
            ? uri.scheme == 'https'
            : {'http', 'https'}.contains(uri.scheme))) {
      throw const FormatException('Invalid web address.');
    }
    return uri;
  }

  static void destination(RequestOptions options, String trustedApiUrl) {
    final trusted = webUri(trustedApiUrl, httpsOnly: true);
    final uri = options.uri;
    if (uri.scheme != trusted.scheme ||
        uri.host != trusted.host ||
        uri.port != trusted.port ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment ||
        !(uri.path == trusted.path ||
            uri.path.startsWith('${trusted.path}/')) ||
        options.path.startsWith('//') ||
        options.path.contains('\\') ||
        options.path.contains('#') ||
        options.path.contains('?')) {
      throw const FormatException('Untrusted API destination.');
    }
    // Uri normalizes dot segments. Validate the original path before parsing can
    // erase an injected path parameter such as ../auth/login.
    var path = options.path.replaceFirst(RegExp(r'^https://[^/]+'), '');
    for (var i = 0; i < 4; i++) {
      if (path.contains('\\') ||
          path.contains('//') ||
          path.split('/').any((part) => part == '.' || part == '..') ||
          RegExp(r'%(?:2f|5c)', caseSensitive: false).hasMatch(path)) {
        throw const FormatException('Invalid API path.');
      }
      final decoded = Uri.decodeComponent(path);
      if (decoded == path) break;
      path = decoded;
    }
    if (path.contains('%')) throw const FormatException('Invalid API path.');
    if (!safeText(path) || path.length > 4096) {
      throw const FormatException('Invalid API path.');
    }
    options.followRedirects = false;
    options.maxRedirects = 0;
    options.sendTimeout ??= const Duration(seconds: 30);
    options.receiveTimeout ??= const Duration(seconds: 30);
    for (final entry in options.headers.entries) {
      final value = entry.value?.toString() ?? '';
      if (!safeText(entry.key) ||
          !safeText(value) ||
          value.contains('\r') ||
          value.contains('\n') ||
          entry.key.contains(RegExp(r'[\s:]'))) {
        throw const FormatException('Invalid request header.');
      }
    }
  }

  static void socketDestination(String value, String configuredChatUrl) {
    final uri = webUri(value, httpsOnly: true);
    final trusted = webUri(configuredChatUrl, httpsOnly: true);
    if (uri.origin != trusted.origin ||
        uri.path != trusted.path ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('Untrusted chat destination.');
    }
  }

  static dynamic prepare(dynamic value,
      {String endpoint = '', bool query = false}) {
    final walker = _RequestWalker(endpoint, query);
    final result = walker.walk(value, '', 0);
    if (result is Map) _validateRoot(result, endpoint, query);
    return result;
  }

  static void _validateRoot(Map data, String endpoint, bool query) {
    if (query) {
      final start = data['startDate'];
      final end = data['endDate'];
      if (start is String &&
          end is String &&
          DateTime.parse(start).isAfter(DateTime.parse(end))) {
        throw const FormatException('Invalid date range.');
      }
      return;
    }
    void requiredText(String key) {
      final value = data[key];
      if (value is! String || value.trim().isEmpty) {
        throw const FormatException('A required field is missing.');
      }
    }

    if (endpoint.endsWith('/auth/login')) {
      requiredText('phone');
      // Do not impose a new password policy on existing accounts or trim it.
      final password = data['password'];
      if (password is! String || password.isEmpty) {
        throw const FormatException('Password is required.');
      }
    }
    if (endpoint == '/business-company/users' ||
        endpoint.startsWith('/business-company/users/')) {
      final username = data['username'];
      if (username != null &&
          (username is! String ||
              !RegExp(r'^[a-zA-Z0-9_-]{3,20}$').hasMatch(username))) {
        throw const FormatException('Invalid staff username.');
      }
      if (endpoint == '/business-company/users') {
        requiredText('username');
        requiredText('role');
      }
      if (data['email'] != null && !validEmail(data['email'] as String)) {
        throw const FormatException('Invalid staff email.');
      }
      if (data['phone'] != null && !validPhone(data['phone'] as String)) {
        throw const FormatException('Invalid staff phone.');
      }
      final password = data['password'];
      if (password != null) {
        final pattern = endpoint == '/business-company/users'
            ? RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9]{8,}$')
            : RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[a-zA-Z0-9@$!%*?&]{8,}$');
        if (password is! String || !pattern.hasMatch(password)) {
          throw const FormatException('Invalid staff password.');
        }
      }
      if (data['role'] != null &&
          !{'business_owner', 'manager', 'worker', 'driver'}
              .contains(data['role'])) {
        throw const FormatException('Invalid staff role.');
      }
    }
    if (endpoint == '/chat/sendMessage') {
      requiredText('conversationId');
      requiredText('content');
      if (data['type'] != 'text') {
        throw const FormatException('Unsupported chat message type.');
      }
    }
    if (endpoint == '/teams' || endpoint.startsWith('/teams/')) {
      requiredText('name');
      requiredText('business');
      if (data['users'] is! List || (data['users'] as List).isEmpty) {
        throw const FormatException('Select at least one team member.');
      }
    }
    if (endpoint.contains('/cleaner-availability')) {
      if (data['startHour'] is num &&
          data['endHour'] is num &&
          data['startHour'] >= data['endHour']) {
        throw const FormatException('Invalid availability range.');
      }
    }
    if (endpoint.endsWith('/prices') && endpoint.contains('/laundry-catalog')) {
      final items = data['items'];
      if (items is! List || items.isEmpty || items.length > 200) {
        throw const FormatException('Use between 1 and 200 price updates.');
      }
      for (final item in items) {
        if (item is! Map ||
            (item['productId'] == null) == (item['itemId'] == null)) {
          throw const FormatException('Select one item per price update.');
        }
      }
    }
    if (endpoint.contains('/requests/laundry/') &&
        endpoint.endsWith('/invoice')) {
      final items = data['items'];
      if (items is! List || items.isEmpty || items.length > 100) {
        throw const FormatException('Use between 1 and 100 invoice items.');
      }
    }
    if (endpoint.contains('/requests/laundry/') &&
        endpoint.endsWith('/status') &&
        !{'completed', 'cancelled', 'pickup_rejected'}
            .contains(data['status'])) {
      throw const FormatException('Invalid laundry status action.');
    }
  }
}

class _RequestWalker {
  _RequestWalker(this.endpoint, this.query);
  final String endpoint;
  final bool query;
  int nodes = 0;
  int textUnits = 0;

  Never invalid() =>
      throw const FormatException('Invalid or oversized request field.');

  dynamic walk(dynamic value, String field, int depth, {String parent = ''}) {
    if (++nodes > RequestSecurity.maxNodes ||
        depth > RequestSecurity.maxDepth) {
      invalid();
    }
    if (value == null) return value;
    const booleanFields = {
      'available',
      'active',
      'enabled',
      'isActive',
      'isEnabled',
      'sameDayEnabled',
      'send',
      'allowPagination'
    };
    const numericFields = {
      'price',
      'fee',
      'basePricePerCleanerPerHour',
      'cleaningProductsPrice',
      'totalPrice',
      'extraFees',
      'pickupFee',
      'deliveryFee',
      'discount',
      'minimumCharge',
      'discountPercentage',
      'feePercentage',
      'quantity',
      'dayOfWeek',
      'startHour',
      'endHour',
      'totalCleaners',
      'duration',
      'expectedTimeInDays',
      'latitude',
      'longitude',
      'page',
      'limit'
    };
    if (booleanFields.contains(field) && value is! bool) invalid();
    if (numericFields.contains(field) && value is! num) invalid();
    const textFields = {
      'password',
      'username',
      'fcmToken',
      'deviceId',
      'platform',
      'serviceType',
      'sortOrder',
      'type',
      'status',
      'periodType',
      'startDate',
      'endDate',
      'startTime',
      'endTime',
      'sameDayCutoffTime',
      'content',
      'unit',
      'role'
    };
    if ((RequestSecurity._humanFields.contains(field) ||
            textFields.contains(field) ||
            field.endsWith('Id') ||
            field == 'expectedRevision' ||
            field == '_id') &&
        value is! String) {
      invalid();
    }
    if (value is bool) return value;
    if (value is num) {
      if (!value.isFinite) invalid();
      semanticNumber(value, field, parent);
      return value;
    }
    if (value is String) {
      textUnits += value.length;
      final secret =
          {'password', 'token', 'refreshToken', 'accessToken'}.contains(field);
      if (value.length > RequestSecurity.maxText ||
          (!secret && !RequestSecurity.safeText(value)) ||
          textUnits > RequestSecurity.maxTotalText) {
        invalid();
      }
      var result =
          RequestSecurity._humanFields.contains(field) ? value.trim() : value;
      if (field == 'phone') result = RequestSecurity.normalizePhone(result);
      semanticString(result, field);
      return result;
    }
    if (value is List) {
      if (value.length > RequestSecurity.maxCollection) invalid();
      if (endpoint.contains('laundry')) {
        if ((field == 'sizes' && value.length > 50) ||
            (field == 'services' && value.length > 100) ||
            (field == 'workingHours' && value.length > 168)) {
          invalid();
        }
      }
      return value
          .map((item) => walk(item, field, depth + 1, parent: parent))
          .toList();
    }
    if (value is Map) {
      if (value.length > RequestSecurity.maxCollection) invalid();
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String ||
            key.isEmpty ||
            key.length > 128 ||
            !RequestSecurity.safeText(key) ||
            key.contains(RegExp(r'[.$\s]')) ||
            const {'__proto__', 'prototype', 'constructor'}.contains(key)) {
          invalid();
        }
        result[key] = walk(entry.value, key, depth + 1, parent: field);
      }
      if (result['startTime'] is String &&
          result['endTime'] is String &&
          (result['startTime'] as String)
                  .compareTo(result['endTime'] as String) >=
              0) {
        invalid();
      }
      return result;
    }
    // JSON-serializable DTOs occasionally remain nested in Retrofit payloads.
    try {
      return walk((value as dynamic).toJson(), field, depth + 1,
          parent: parent);
    } on NoSuchMethodError {
      invalid();
    }
  }

  void semanticString(String value, String field) {
    // Optional clearing values stay intact. Required fields are checked per route.
    if (value.isEmpty) {
      if (field.endsWith('Id') ||
          {
            'business',
            'users',
            'permissionIds',
            'areas',
            'serviceItemIds',
            'packageIds',
            'cleanerIds',
            'serviceType',
            'nameEn',
            'nameAr',
            'titleEn',
            'titleAr',
            'unit'
          }.contains(field)) {
        invalid();
      }
      return;
    }
    if (field == 'phone' && !RequestSecurity.validPhone(value)) invalid();
    if (field == 'search' && value.length > 1000) invalid();
    if (field == 'email' && !RequestSecurity.validEmail(value)) invalid();
    if (field == 'website' ||
        field == 'logo' ||
        field == 'image' ||
        field == 'imageUrl' ||
        field == 'images' ||
        field == 'media' ||
        field == 'files') {
      RequestSecurity.webUri(value);
    }
    if (field == 'serviceType' && !RequestSecurity._services.contains(value)) {
      invalid();
    }
    if (field == 'sortOrder' &&
        !{'asc', 'desc'}.contains(value.toLowerCase())) {
      invalid();
    }
    if (query &&
        {'startDate', 'endDate'}.contains(field) &&
        DateTime.tryParse(value) == null) {
      invalid();
    }
    if (field == 'startTime' ||
        field == 'sameDayCutoffTime' ||
        field == 'endTime') {
      if (!(field == 'endTime' && value == '24:00') &&
          !RegExp(r'^(?:[01][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
        invalid();
      }
    }
    if (endpoint.contains('laundry')) {
      if ({'nameEn', 'nameAr'}.contains(field) && value.length > 120) invalid();
      if (field == 'unitLabel' && value.length > 60) invalid();
      if (field == 'unit' && !{'item', 'meter', 'custom'}.contains(value)) {
        invalid();
      }
      if ({'specialNotes', 'notes'}.contains(field) && value.length > 2000) {
        invalid();
      }
    }
    if (field.endsWith('Id') ||
        field == 'expectedRevision' ||
        const {
          'business',
          'users',
          'permissionIds',
          'areas',
          'serviceItemIds',
          'packageIds',
          'cleanerIds'
        }.contains(field)) {
      // Opaque and readable IDs remain byte-exact; block path/query injection.
      if (value.length > 200 ||
          value.trim() != value ||
          value.contains(RegExp(r'[\s/\\?#%]'))) {
        invalid();
      }
    }
  }

  void semanticNumber(num value, String field, String parent) {
    if (RequestSecurity._moneyFields.contains(field)) {
      if (value < 0) invalid();
      if (field == 'extraFees' && value < 0.001) invalid();
      if (endpoint.contains('laundry')) {
        final maximum = field == 'minimumCharge' ? 100000 : 10000;
        if (value > maximum ||
            (value * 1000 - (value * 1000).round()).abs() > 0.000001) {
          invalid();
        }
        if (field == 'price' &&
            (parent == 'services' ||
                endpoint.contains('/laundry-products/') ||
                endpoint.endsWith('/prices')) &&
            value < 0.001) {
          invalid();
        }
      }
      if (endpoint.contains('housekeeping-pricing') &&
          field == 'price' &&
          value < 0.001) {
        invalid();
      }
    }
    if (field.endsWith('Percentage') && (value < 0 || value > 100)) invalid();
    if (field == 'latitude' && (value < -90 || value > 90)) invalid();
    if (field == 'longitude' && (value < -180 || value > 180)) invalid();
    if (field == 'quantity' &&
        endpoint.contains('laundry') &&
        (value < 0.001 ||
            value > 10000 ||
            (value * 1000 - (value * 1000).round()).abs() > 0.000001)) {
      invalid();
    }
    if (field == 'dayOfWeek' &&
        (value != value.roundToDouble() || value < 0 || value > 6)) {
      invalid();
    }
    if (field == 'startHour' &&
        (value != value.roundToDouble() || value < 0 || value > 23)) {
      invalid();
    }
    if (field == 'endHour' &&
        (value != value.roundToDouble() || value < 1 || value > 24)) {
      invalid();
    }
    if ({'page', 'limit', 'duration', 'totalCleaners'}.contains(field) &&
        (value != value.roundToDouble() || value < 1)) {
      invalid();
    }
    if (field == 'expectedTimeInDays' && value < 1) invalid();
  }
}
