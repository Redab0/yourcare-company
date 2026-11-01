import 'package:flutter/foundation.dart';

/// Build-time API selection. Production retains existing storage keys.
abstract final class ApiEnvironment {
  static const name =
      String.fromEnvironment('API_ENV', defaultValue: 'production');
  static const isDevelopment = name == 'development';
  static const productionUrl = 'https://be-cleaning.yourcarehere.com/api';
  static const developmentUrl = 'https://dev-be-cleaning.yourcarehere.com/api';
  static const apiUrl = isDevelopment ? developmentUrl : productionUrl;
  static const firebaseEnabled = !isDevelopment;
  static const _devPushTest = bool.fromEnvironment('DEV_PUSH_TEST');
  static bool get firebaseMessagingEnabled => messagingEnabledFor(
        environment: name,
        debug: kDebugMode,
        optIn: _devPushTest,
      );
  static const developmentPrefix = 'development_';

  @visibleForTesting
  static bool messagingEnabledFor({
    required String environment,
    required bool debug,
    required bool optIn,
  }) {
    validate(environment);
    return environment != 'development' || (debug && optIn);
  }

  static void validate([String value = name]) {
    if (value != 'production' && value != 'development') {
      throw StateError('API_ENV must be production or development.');
    }
  }

  static String storageKey(String key) {
    validate();
    return isDevelopment ? '$developmentPrefix$key' : key;
  }

  static bool ownsStorageKey(String key) =>
      key.startsWith(developmentPrefix) == isDevelopment;

  static String get chatUrl {
    validate();
    return Uri.parse(apiUrl).replace(path: '/chat').toString();
  }
}
