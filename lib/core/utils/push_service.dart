// push_service.dart
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _fln = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point') // needed for background on newer Flutter
Future<void> _bgHandler(RemoteMessage message) async {
  // If you need, do minimal processing here (no UI).
}

class PushService {
  static Future<void> init({
    required Future<void> Function(String token) onRegisterToken,
    String androidChannelId = 'general',
    String androidChannelName = 'General',
    String? appLabelForLogging,
  }) async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    // iOS permission prompt
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Push permission: ${settings.authorizationStatus}');

    // Foreground presentation on iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications (for foreground)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _fln.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (resp) {
        if (resp.payload != null) {
          _handleDeeplinkFromPayload(resp.payload!);
        }
      },
    );

    // Android channel (once)
    const androidChannel = AndroidNotificationChannel(
      'general',
      'General',
      description: 'General notifications',
      importance: Importance.high,
    );
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Register / refresh token
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await onRegisterToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(onRegisterToken);

    // Foreground messages → show a local notification
    FirebaseMessaging.onMessage.listen((msg) async {
      final n = msg.notification;
      final data = msg.data;

      await _fln.show(
        0,
        n?.title ?? 'Update',
        n?.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails('general', 'General',
              importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(data), // include deeplink in data
      );
    });

    // Opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final payload = jsonEncode(msg.data);
      _handleDeeplinkFromPayload(payload);
    });

    // If launched from a notification (terminated state)
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      final payload = jsonEncode(initialMsg.data);
      _handleDeeplinkFromPayload(payload);
    }
  }
}

void _handleDeeplinkFromPayload(String payload) {
  try {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final link = data['deeplink'] as String?;
    if (link != null) {
      // TODO: route in your app (use go_router or your Navigator)
      // Example: AppRouter.instance.open(link);
    }
  } catch (_) {}
}
