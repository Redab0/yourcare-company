import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsRepository {
  final NotificationsService _notificationsService;
  final FirebaseMessaging _messaging;
  const NotificationsRepository(this._notificationsService, this._messaging);

  Future<void> initializeAndRegister() async {
    // 1) Ask permission (once)
    final asked =
        await SecureStorageService().getAskedForNotificationsPermission();
    if (asked == null) {
      final settings = await _messaging.requestPermission(
          alert: true, badge: true, sound: true);
      await SecureStorageService().askedForNotificationsPermission();
      // you can react to settings.authorizationStatus if you want
    }

    // 2) Get token and register to backend when changed
    final token = await _messaging.getToken();
    final prev = await SecureStorageService().getFcmToken();

    if (token != null && token != prev) {
      // await _api.registerDeviceToken(
      //   token: token,
      //   app: app,
      //   platform: Platform.isIOS ? 'ios' : 'android',
      //   // optionally include userId from _auth.currentUserId
      // );
      await SecureStorageService().saveFcmToken(token);
    }

    // 3) Handle future refreshes
    _messaging.onTokenRefresh.listen((t) async {
      // await _api.registerDeviceToken(
      //   token: t,
      //   app: app,
      //   platform: Platform.isIOS ? 'ios' : 'android',
      // );
      await SecureStorageService().saveFcmToken(t);
    });
  }

  Future<void> onLogoutCleanup() async {
    await _messaging.deleteToken();
    await SecureStorageService().deleteFcmToken();
  }
}
