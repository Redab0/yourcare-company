import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/notifications/register_token.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chat_launcher_cubit.dart';
import 'package:cleaning_service_driver/features/chats/presentation/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class NotificationsRepository {
  final NotificationsService _notificationsService;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  Map<String, dynamic>? _pendingChatNotificationData;
  bool _openingPendingChatNotification = false;
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
    _notificationsActive = true;
    _tokenRegistrationCompleted = false;

    try {
      await _initializeLocalNotifications();
      await _ensureNotificationPermission();

      // Explicitly allow foreground presentation on iOS.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get current saved token and deviceId (persist deviceId).
      final prev = await SecureStorageService().getFcmToken();
      final savedDeviceId = await SecureStorageService().getDeviceId();
      final deviceId = savedDeviceId ?? const Uuid().v4();
      if (savedDeviceId == null) {
        await SecureStorageService().saveDeviceId(deviceId);
      }
      debugPrint('Prev saved FCM token: $prev');
      debugPrint('Using deviceId: $deviceId');

      // Try immediate registration once, then keep retrying in background.
      final registered = await _tryRegisterCurrentToken(
        deviceId: deviceId,
        previousToken: prev,
      );
      if (!registered) {
        _startTokenRegistrationRetryLoop(deviceId);
      }

      // Always listen for future refreshes.
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

      // Foreground notifications.
      await _foregroundMessageSubscription?.cancel();
      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
        _handleMessage,
      );

      await _messageOpenedSubscription?.cancel();
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap,
      );

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
      _initialized = true;
    } catch (e) {
      _initialized = false;
      _notificationsActive = false;
      debugPrint('Failed to initialize notifications: $e');
      rethrow;
    }
  }

  Future<void> _ensureNotificationPermission() async {
    var settings = await _messaging.getNotificationSettings();
    debugPrint(
      'Notification authorization status before request: '
      '${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await SecureStorageService().askedForNotificationsPermission();
    }

    debugPrint(
      'Notification authorization status after request: '
      '${settings.authorizationStatus}',
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
      final tokenChanged = token != null && token != prev;
      debugPrint('FCM token changed locally? $tokenChanged');

      if (token == null) {
        _tokenRegistrationCompleted = false;
        return false;
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
        final data = _payloadToMap(response.payload);
        if (data == null) return;
        _openChatFromNotificationData(data);
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
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _openChatFromNotificationData(message.data);
  }

  Map<String, dynamic>? _payloadToMap(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return {'screen': payload};
    }
    return null;
  }

  void _openChatFromNotificationData(Map<String, dynamic> data) {
    if (!_isChatNotification(data)) return;
    final conversationId = _readConversationId(data);
    if (conversationId == null || conversationId.isEmpty) return;

    _pendingChatNotificationData = data;
    unawaited(_flushPendingChatNotification());
  }

  Future<void> _flushPendingChatNotification({int attempt = 0}) async {
    if (_openingPendingChatNotification) return;
    final data = _pendingChatNotificationData;
    if (data == null) return;

    final navigator = sl<GlobalKey<NavigatorState>>().currentState;
    if (navigator == null) {
      if (attempt < 20) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        return _flushPendingChatNotification(attempt: attempt + 1);
      }
      return;
    }

    final conversationId = _readConversationId(data);
    if (conversationId == null || conversationId.isEmpty) return;

    _openingPendingChatNotification = true;
    _pendingChatNotificationData = null;
    try {
      final launcher = sl<ChatLauncherCubit>();
      final openConversationId = launcher.state.openConversationId;
      final alreadyOpen = launcher.state.isChatWindowOpen &&
          openConversationId == conversationId;
      launcher.setActiveChat(
        conversationId: conversationId,
        hasLastMessage: true,
        requestId: _readString(data, const ['requestId', 'request_id']),
        businessId: _readString(data, const ['businessId', 'business_id']),
      );
      if (alreadyOpen) return;
      if (openConversationId != null &&
          openConversationId.isNotEmpty &&
          navigator.canPop()) {
        navigator.pop();
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
      unawaited(
        navigator.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversationId,
              shouldLoadHistory: true,
            ),
          ),
        ),
      );
    } finally {
      _openingPendingChatNotification = false;
      if (_pendingChatNotificationData != null) {
        unawaited(_flushPendingChatNotification());
      }
    }
  }

  bool _isChatNotification(Map<String, dynamic> data) {
    final type =
        _readString(data, const ['type', 'notificationType', 'screen']);
    final deeplink =
        _readString(data, const ['deeplink', 'deepLink', 'link', 'screen']);
    return type == 'chat_message' ||
        type == 'chat' ||
        (deeplink?.startsWith('/chat') ?? false) ||
        _readConversationId(data) != null;
  }

  String? _readConversationId(Map<String, dynamic> data) {
    final direct = _readString(
      data,
      const ['conversationId', 'conversation_id', 'chatConversationId'],
    );
    if (direct != null && direct.isNotEmpty) return direct;

    final deeplink =
        _readString(data, const ['deeplink', 'deepLink', 'link', 'screen']);
    if (deeplink == null || deeplink.isEmpty) return null;
    final uri = Uri.tryParse(deeplink);
    if (uri == null) return null;
    return uri.queryParameters['conversationId'] ??
        uri.queryParameters['conversation_id'];
  }

  String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
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
    await _messageOpenedSubscription?.cancel();
    _messageOpenedSubscription = null;
    _pendingChatNotificationData = null;

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
