import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/utils/app_remote_config.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';

void main() {
  test('development config and notification lifecycle need no Firebase project',
      () async {
    if (!ApiEnvironment.isDevelopment) return;
    expect(ApiEnvironment.firebaseEnabled, false);
    final config = AppRemoteConfig.instance;
    await config.initialize();
    expect(config.showRegister, true);
    expect(config.forceUpdate, false);
    final dio = Dio();
    addTearDown(dio.close);
    final notifications =
        NotificationsRepository(NotificationsService(dio), null);
    await notifications.initializeAndRegister();
    await notifications.onLogoutCleanup();
  });
}
