import 'dart:async';
import 'dart:io';

import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/notifications/register_token.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class NotificationsRepository {
  final NotificationsService _notificationsService;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  bool _initialized = false;
  bool _notificationsActive = false;
  bool _tokenRegistrationCompleted = false;
  bool _tokenRetryLoopRunning = false;
  int _tokenRetryEpoch = 0;

  NotificationsRepository(
    this._notificationsService,
    this._messaging, {
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  // Notification channel for Android (default priority)
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_alert_channel',
    'Alert Notifications',
    description: 'Used for customer notifications.',
    importance: Importance.defaultImportance,
    playSound: true,
    enableVibration: true,
  );

  static const String _apnsTokenNotSetCode = 'apns-token-not-set';

  Future<void> initializeAndRegister() async {
    if (_initialized) return;
    _initialized = true;
    _notificationsActive = true;
    _tokenRegistrationCompleted = false;

    await _initializeLocalNotifications();

    // 2) Ask permission once (optional on Android 13+ it matters)
    final asked =
        await SecureStorageService().getAskedForNotificationsPermission();
    if (asked == null) {
      final settings = await _messaging.requestPermission(
          alert: true, badge: true, sound: true);
      await SecureStorageService().askedForNotificationsPermission();
      debugPrint(
        'Notification permission status: ${settings.authorizationStatus}',
      );
    }

    // 2b) Explicitly allow foreground presentation on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3) Get current saved token and deviceId (persist deviceId)
    final prev = await SecureStorageService().getFcmToken();
    final savedDeviceId = await SecureStorageService().getDeviceId();
    final deviceId = savedDeviceId ?? const Uuid().v4();
    if (savedDeviceId == null) {
      await SecureStorageService().saveDeviceId(deviceId);
    }
    debugPrint('Prev saved FCM token: $prev');
    debugPrint('Using deviceId: $deviceId');

    // 4) Try immediate registration once, then keep retrying in background.
    final registered = await _tryRegisterCurrentToken(
      deviceId: deviceId,
      previousToken: prev,
    );
    if (!registered) {
      _startTokenRegistrationRetryLoop(deviceId);
    }

    // 5) Always listen for future refreshes
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((t) async {
      if (!_notificationsActive) return;
      debugPrint('FCM token refreshed: $t');
      try {
        await _notificationsService.registerDeviceToken(
          RegisterToken(
            fcmToken: t,
            deviceId: deviceId,
            platform: Platform.isAndroid ? "android" : "ios",
          ),
        );
        await SecureStorageService().saveFcmToken(t);
        _tokenRegistrationCompleted = true;
      } catch (e) {
        _tokenRegistrationCompleted = false;
        debugPrint('Failed to register refreshed FCM token: $e');
        _startTokenRegistrationRetryLoop(deviceId);
      }
    });

    // 6) Foreground notifications
    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleMessage,
    );
  }

  Future<bool> _tryRegisterCurrentToken({
    required String deviceId,
    String? previousToken,
  }) async {
    if (!_notificationsActive) return false;
    try {
      final token = await _safeGetFcmToken();
      debugPrint('DEVICE TOKEN: $token');
      final prev = previousToken ?? await SecureStorageService().getFcmToken();
      final shouldRegister = token != null && token != prev;
      debugPrint('Should register with backend? $shouldRegister');

      if (!shouldRegister) {
        _tokenRegistrationCompleted = token != null;
        return _tokenRegistrationCompleted;
      }

      await _notificationsService.registerDeviceToken(
        RegisterToken(
          fcmToken: token,
          deviceId: deviceId,
          platform: Platform.isAndroid ? "android" : "ios",
        ),
      );
      await SecureStorageService().saveFcmToken(token);
      _tokenRegistrationCompleted = true;
      debugPrint('Device token registered and saved.');
      return true;
    } catch (e) {
      _tokenRegistrationCompleted = false;
      debugPrint('Failed to register current FCM token: $e');
      return false;
    }
  }

  void _startTokenRegistrationRetryLoop(String deviceId) {
    if (_tokenRetryLoopRunning) return;
    _tokenRetryLoopRunning = true;
    final loopEpoch = _tokenRetryEpoch;

    unawaited(() async {
      var attempt = 0;
      while (_notificationsActive &&
          loopEpoch == _tokenRetryEpoch &&
          !_tokenRegistrationCompleted) {
        attempt += 1;
        final delaySeconds = _retryDelaySeconds(attempt);
        await Future.delayed(Duration(seconds: delaySeconds));

        if (!_notificationsActive || loopEpoch != _tokenRetryEpoch) {
          break;
        }

        final ok = await _tryRegisterCurrentToken(deviceId: deviceId);
        if (ok) break;
      }
      _tokenRetryLoopRunning = false;
    }());
  }

  int _retryDelaySeconds(int attempt) {
    if (attempt <= 1) return 5;
    if (attempt <= 2) return 10;
    if (attempt <= 4) return 20;
    if (attempt <= 8) return 30;
    if (attempt <= 16) return 45;
    return 60;
  }

  Future<String?> _safeGetFcmToken() async {
    if (!Platform.isIOS) {
      return _getTokenWithRetry();
    }

    final apns = await _messaging.getAPNSToken();
    if (apns == null) {
      debugPrint('APNs token not ready yet on iOS; skipping FCM token fetch.');
      return null;
    }

    try {
      return await _getTokenWithRetry();
    } on FirebaseException catch (e) {
      if (e.code == _apnsTokenNotSetCode) {
        debugPrint('APNs token not set yet; will retry later.');
        return null;
      }
      rethrow;
    }
  }

  Future<String?> _getTokenWithRetry() async {
    String? token = await _messaging.getToken();
    if (token == null) {
      await Future.delayed(const Duration(seconds: 2));
      token = await _messaging.getToken();
    }
    return token;
  }

  Future<void> _initializeLocalNotifications() async {
    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notifications'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Notification received');

    // iOS handles foreground presentation via system when enabled.
    if (Platform.isIOS) {
      return;
    }

    if (message.notification != null) {
      _localNotifications.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['screen'],
      );
    }
  }

  Future<void> onLogoutCleanup() async {
    _notificationsActive = false;
    _tokenRegistrationCompleted = false;
    _tokenRetryLoopRunning = false;
    _tokenRetryEpoch += 1;
    _initialized = false;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;

    final storedToken = await SecureStorageService().getFcmToken();
    final deviceId = await SecureStorageService().getDeviceId();

    // Fetch latest token if not cached
    final token = storedToken ?? await _messaging.getToken();

    if (token != null && deviceId != null) {
      try {
        await _notificationsService.deactivateDeviceToken(
          RegisterToken(
            fcmToken: token,
            deviceId: deviceId,
            platform: Platform.isAndroid ? "android" : "ios",
          ),
        );
      } catch (e) {
        debugPrint('Failed to deactivate device token: $e');
      }
    }

    await _messaging.deleteToken();
    await SecureStorageService().deleteFcmToken();
  }
}
