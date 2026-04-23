import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:version/version.dart';

class AppRemoteConfig {
  AppRemoteConfig._();

  static final AppRemoteConfig instance = AppRemoteConfig._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _configured = false;

  Future<void> initialize() async {
    if (!_configured) {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 5),
        ),
      );

      await _remoteConfig.setDefaults(const {
        'minimum_version': '1.0.0',
        'latest_version': '1.0.0',
        'force_update': false,
        'force_update_ios_url':
            'https://apps.apple.com/kw/app/yourcare-partner/id6759683278',
        'force_update_android_url':
            'https://play.google.com/store/apps/details?id=com.yourcarehere.partner',
        'show_deactivate_account': true,
        'show_register': true,
      });
      _configured = true;
    }

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep defaults/cached values when fetch fails.
    }
  }

  String get minimumVersion =>
      _remoteConfig.getString('minimum_version').trim();

  String get latestVersion => _remoteConfig.getString('latest_version').trim();

  bool get forceUpdate => _remoteConfig.getBool('force_update');

  String get forceUpdateIosUrl =>
      _remoteConfig.getString('force_update_ios_url').trim();

  String get forceUpdateAndroidUrl =>
      _remoteConfig.getString('force_update_android_url').trim();

  bool get showDeactivateAccount =>
      _remoteConfig.getBool('show_deactivate_account');

  bool get showRegister => _remoteConfig.getBool('show_register');

  bool isMinimumVersionSatisfied(String currentVersion) {
    final minVersion = minimumVersion;
    if (minVersion.isEmpty) return true;
    try {
      final current = Version.parse(currentVersion);
      final minimum = Version.parse(minVersion);
      return current >= minimum;
    } catch (_) {
      return true;
    }
  }
}
