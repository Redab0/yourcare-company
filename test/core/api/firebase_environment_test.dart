import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/utils/app_remote_config.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';

void main() {
  test(
      'messaging opt-in requires development and debug; production is unchanged',
      () {
    for (final debug in [false, true]) {
      for (final optIn in [false, true]) {
        expect(
          ApiEnvironment.messagingEnabledFor(
              environment: 'production', debug: debug, optIn: optIn),
          true,
        );
        expect(
          ApiEnvironment.messagingEnabledFor(
              environment: 'development', debug: debug, optIn: optIn),
          debug && optIn,
        );
      }
    }
    expect(
      () => ApiEnvironment.messagingEnabledFor(
          environment: 'invalid', debug: true, optIn: true),
      throwsStateError,
    );
  });

  test('build messaging flag preserves API, storage and general Firebase gates',
      () {
    const optIn = bool.fromEnvironment('DEV_PUSH_TEST');
    expect(ApiEnvironment.firebaseMessagingEnabled,
        !ApiEnvironment.isDevelopment || (kDebugMode && optIn));
    expect(ApiEnvironment.firebaseEnabled, !ApiEnvironment.isDevelopment);
    expect(
        ApiEnvironment.apiUrl,
        ApiEnvironment.isDevelopment
            ? ApiEnvironment.developmentUrl
            : ApiEnvironment.productionUrl);
    expect(
        ApiEnvironment.storageKey('access_token'),
        ApiEnvironment.isDevelopment
            ? 'development_access_token'
            : 'access_token');
  });

  test('development config and notification lifecycle need no Firebase project',
      () async {
    if (!ApiEnvironment.isDevelopment) return;
    expect(ApiEnvironment.firebaseEnabled, false);
    final config = AppRemoteConfig.instance;
    await config.initialize();
    expect(config.showRegister, true);
    expect(config.forceUpdate, false);
    // Opted-in debug initializes native Messaging on the device; this local
    // branch instead verifies the ordinary dev no-SDK path.
    if (ApiEnvironment.firebaseMessagingEnabled) return;
    final dio = Dio();
    addTearDown(dio.close);
    final notifications =
        NotificationsRepository(NotificationsService(dio), null);
    await notifications.initializeAndRegister();
    await notifications.onLogoutCleanup(expectedToken: 'fixture-token');
  });
}
