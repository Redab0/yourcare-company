// lib/core/storage/locale_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocaleStorage {
  static const _key = 'locale_code'; // e.g. 'en', 'ar'

  final SharedPreferences prefs;
  LocaleStorage(this.prefs);

  String? read() => prefs.getString(_key);

  Future<void> write(String code) => prefs.setString(_key, code);
}
