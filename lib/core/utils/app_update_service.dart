import 'dart:io';

import 'package:cleaning_service_driver/core/utils/app_remote_config.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class AppUpdateService {
  AppUpdateService(this._remoteConfig);

  final AppRemoteConfig _remoteConfig;
  bool _checkedOnce = false;

  Future<bool> checkForUpdate(BuildContext context) async {
    if (_checkedOnce) return false;
    _checkedOnce = true;

    await _remoteConfig.initialize();

    final minVersion = _remoteConfig.minimumVersion;
    final latestVersion = _remoteConfig.latestVersion;

    final pkg = await PackageInfo.fromPlatform();
    final current = _parseVersion(pkg.version);
    final min = _parseVersion(minVersion);
    final latest = _parseVersion(latestVersion);

    final forceRequired = current != null && min != null && current < min;
    final updateAvailable =
        current != null && latest != null && current < latest;

    if (!forceRequired && !updateAvailable) return false;
    if (!context.mounted) return forceRequired;

    final storeUrl = _storeUrl();
    if (storeUrl == null || storeUrl.isEmpty) return forceRequired;

    await showDialog<void>(
      context: context,
      barrierDismissible: !forceRequired,
      builder: (ctx) => PopScope(
        canPop: !forceRequired,
        child: AlertDialog(
          title: Text(context.l10n.force_update_title),
          content: Text(
            forceRequired
                ? '${context.l10n.force_update_message}\n'
                    '${context.l10n.force_update_minimum_label}: $minVersion'
                : context.l10n.update_available_message,
          ),
          actions: [
            if (!forceRequired)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.general_cancel),
              ),
            TextButton(
              onPressed: () => _launchStore(storeUrl),
              child: Text(context.l10n.update_now),
            ),
          ],
        ),
      ),
    );

    return forceRequired;
  }

  Future<void> _launchStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String? _storeUrl() {
    if (Platform.isIOS) return _remoteConfig.forceUpdateIosUrl;
    if (Platform.isAndroid) return _remoteConfig.forceUpdateAndroidUrl;
    return null;
  }

  Version? _parseVersion(String value) {
    final numbers = RegExp(r'\d+')
        .allMatches(value)
        .map((m) => m.group(0)!)
        .toList(growable: false);
    if (numbers.isEmpty) return null;
    final major = numbers[0];
    final minor = numbers.length > 1 ? numbers[1] : '0';
    final patch = numbers.length > 2 ? numbers[2] : '0';
    return Version.parse('$major.$minor.$patch');
  }
}
