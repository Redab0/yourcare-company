import 'dart:io';

import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/notifications/register_token.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/play_services_check.dart';
import 'package:cleaning_service_driver/data/services/notifications/notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class NotificationsRepository {
  final NotificationsService _notificationsService;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationsRepository(
    this._notificationsService,
    this._messaging, {
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  // Notification channel for Android
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // ID
    'High Importance Notifications', // Name
    description: 'Used for important notifications.',
    importance: Importance.max,
  );

  Future<void> initializeAndRegister() async {
    if (Platform.isAndroid) {
      final ok = await PlayServices.ensureAvailable();
      if (!ok) {
        debugPrint(
            'Play services not available; FCM won’t work. Skipping init.');
        return; // bail out early; no token/notifications without Play services
      }
    }

    await _initializeLocalNotifications();

    // 2) Ask permission once (optional on Android 13+ it matters)
    final asked =
        await SecureStorageService().getAskedForNotificationsPermission();
    if (asked == null) {
      final settings = await _messaging.requestPermission(
          alert: true, badge: true, sound: true);
      await SecureStorageService().askedForNotificationsPermission();
      print('Notification permission status: ${settings.authorizationStatus}');
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
    print('Prev saved FCM token: $prev');
    print('Using deviceId: $deviceId');

    // 4) Obtain a token (with a quick retry if null)
    String? token = await _messaging.getToken();
    if (token == null) {
      await Future.delayed(const Duration(seconds: 2));
      token = await _messaging.getToken();
    }
    print('DEVICE TOKEN: $token');

    // 5) Register if new or not saved yet
    final shouldRegister = token != null && token != prev;
    print('Should register with backend? $shouldRegister');

    if (shouldRegister) {
      await _notificationsService.registerDeviceToken(
        RegisterToken(
          fcmToken: token!, // safe due to `shouldRegister`
          deviceId: deviceId,
          platform: Platform.isAndroid ? "android" : "ios",
        ),
      );
      await SecureStorageService().saveFcmToken(token);
      print('Device token registered and saved.');
    }

    // 6) Always listen for future refreshes
    _messaging.onTokenRefresh.listen((t) async {
      print('FCM token refreshed: $t');
      await _notificationsService.registerDeviceToken(
        RegisterToken(
          fcmToken: t, // <-- use the new token
          deviceId: deviceId,
          platform: Platform.isAndroid ? "android" : "ios",
        ),
      );
      await SecureStorageService().saveFcmToken(t);
    });

    // 7) Foreground notifications
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  Future<void> _initializeLocalNotifications() async {
    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(
          'ic_notifications'), // Match drawable icon
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        if (payload != null) {
          print('Notification tapped: $payload');
          // Handle navigation, e.g., to DeepCleaningJobDetailsScreen
          // Example: Navigate based on payload
          // if (payload == 'deep_cleaning_job_details') {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => DeepCleaningJobDetailsScreen(...)));
          // }
        }
      },
    );
  }

  void _handleMessage(RemoteMessage message) {
    print("NOTIFICATION RECEIVED 1");
    if (message.notification != null) {
      print("NOTIFICATION RECEIVED 2");
      _localNotifications.show(
        message.notification.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['screen'],
      );
    }
  }

  Future<void> onLogoutCleanup() async {
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
