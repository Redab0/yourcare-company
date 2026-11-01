import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../api/session_request_interceptor.dart';
import '../../data/models/auth/login_response.dart';
import 'price_access.dart';

class PriceAccessInterceptor extends Interceptor {
  PriceAccessInterceptor(this.storage,
      {PriceAccess? access, this.storageWait = const Duration(seconds: 4)})
      : access = access ?? PriceAccess.instance;
  static const epochKey = 'priceAccessEpoch';
  final SecureStorageService storage;
  final PriceAccess access;
  final Duration storageWait;

  DioException _stale(RequestOptions options) => DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
      message: 'Access changed. Please refresh.');

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final options = response.requestOptions;
    final generation =
        options.extra[SessionRequestInterceptor.expectedGenerationKey];
    if (generation != storage.authGeneration ||
        options.extra[epochKey] != access.epoch) {
      handler.reject(_stale(options));
      return;
    }
    try {
      final path = options.uri.path;
      final ownProfile = path.endsWith('/users/profile');
      final userDetail = RegExp(r'/users/[a-fA-F0-9]{24}$').hasMatch(path);
      if (ownProfile || userDetail) {
        dynamic json = response.data;
        for (var i = 0;
            i < 3 && json is Map && json['id'] == null && json['_id'] == null;
            i++) {
          json = json['data'];
        }
        if (json is Map) {
          final user = User.fromJson(Map<String, dynamic>.from(json));
          var publicationEpoch = access.epoch;
          // A known current-user downgrade hides UI before any native I/O.
          if ((ownProfile || user.id == access.userId) &&
              (!user.effectiveCanSeePrices ||
                  (access.canManage && !user.canManagePriceAccess))) {
            access.deny();
            publicationEpoch = access.epoch;
          }
          final current = await storage.getUser().timeout(storageWait);
          if (current?.id == user.id) {
            if (access.epoch != publicationEpoch) {
              handler.reject(_stale(options));
              return;
            }
            final saved = await storage
                .saveUser(user,
                    expectedGeneration: generation as int,
                    expectedAccessEpoch: publicationEpoch,
                    authoritativeAccess: true)
                .timeout(storageWait);
            if (!saved) {
              handler.reject(_stale(options));
              return;
            }
          }
        }
      } else if (_containsHidden(response.data)) {
        // Revocation cannot wait for a slow or unavailable keychain. Persist
        // best effort under the same account lock; operational data stays usable.
        access.deny();
        bool? updated;
        try {
          updated = await storage
              .markPricesHidden(
                  generation: generation as int, accessEpoch: access.epoch)
              .timeout(storageWait);
        } catch (_) {/* In-memory denial remains effective. */}
        if (updated == false || storage.authGeneration != generation) {
          handler.reject(_stale(options));
          return;
        }
      }
      handler.next(response);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  static bool _containsHidden(dynamic value) {
    if (value is Map) {
      return value['pricesHidden'] == true || value.values.any(_containsHidden);
    }
    return value is List && value.any(_containsHidden);
  }
}
