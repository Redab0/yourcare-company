import 'dart:convert';

import 'package:cleaning_service/core/storage/secure_storage_service.dart';
import 'package:cleaning_service/data/services/notifications/notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationsRepository {
  final NotificationsService _notificationsService;

  const NotificationsRepository(this._notificationsService);

  final FirebaseMessaging _messaging;

  // PushRepositoryImpl(this._messaging, this.SecureStorageService(), this._api, this._auth);

  Future<void> initializeAndRegister() async {
    // 1) Ask permission (once)
    final asked = await SecureStorageService().read(key: _kAskedPermKey);
    if (asked != '1') {
      final settings = await _messaging.requestPermission(
          alert: true, badge: true, sound: true);
      await SecureStorageService().write(key: _kAskedPermKey, value: '1');
      // you can react to settings.authorizationStatus if you want
    }

    // 2) Get token and register to backend when changed
    final token = await _messaging.getToken();
    final prev = await SecureStorageService().read(key: _kTokenKey);

    if (token != null && token != prev) {
      // await _api.registerDeviceToken(
      //   token: token,
      //   app: app,
      //   platform: Platform.isIOS ? 'ios' : 'android',
      //   // optionally include userId from _auth.currentUserId
      // );
      await SecureStorageService().write(key: _kTokenKey, value: token);
    }

    // 3) Handle future refreshes
    _messaging.onTokenRefresh.listen((t) async {
      // await _api.registerDeviceToken(
      //   token: t,
      //   app: app,
      //   platform: Platform.isIOS ? 'ios' : 'android',
      // );
      await SecureStorageService().write(key: _kTokenKey, value: t);
    });
  }

  Future<void> subscribeTopic(String topic) async {
    // idempotent locally + prevents duplicate writes
    final topics = await _loadTopics();
    if (topics.add(topic)) {
      await _messaging.subscribeToTopic(topic);
      await _saveTopics(topics);
    }
  }

  Future<void> unsubscribeAll() async {
    final topics = await _loadTopics();
    for (final t in topics) {
      await _messaging.unsubscribeFromTopic(t);
    }
    await SecureStorageService().delete(key: _kTopicsKey);
  }

  Future<void> onLogoutCleanup() async {
    // tell backend to delete token, unsubscribe topics, clear local state
    final token = await SecureStorageService().read(key: _kTokenKey);
    if (token != null) {
      // await _api.unRegisterDeviceToken(token);
      await _messaging.deleteToken(); // invalidates local token
    }
    await unsubscribeAll();
    await SecureStorageService().delete(key: _kTokenKey);
  }

  // Helpers
  Future<Set<String>> _loadTopics() async {
    final raw = await SecureStorageService().read(key: _kTopicsKey);
    if (raw == null || raw.isEmpty) return <String>{};
    return (jsonDecode(raw) as List).map((e) => e.toString()).toSet();
  }

  Future<void> _saveTopics(Set<String> topics) async {
    await SecureStorageService()
        .write(key: _kTopicsKey, value: jsonEncode(topics.toList()));
  }
}
