import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../api/api_environment.dart';
import 'app_diagnostics.dart';

/// These checkouts have production Firebase projects only. Development never sends telemetry.
abstract final class MobileTelemetry {
  static const collectionEnabled = !ApiEnvironment.isDevelopment &&
      bool.fromEnvironment('TELEMETRY_ENABLED', defaultValue: true);

  static Future<void> initialize() async {
    if (kIsWeb || !ApiEnvironment.firebaseEnabled) return;
    final crashlytics = FirebaseCrashlytics.instance;
    final analytics = FirebaseAnalytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(collectionEnabled);
    await analytics.setAnalyticsCollectionEnabled(collectionEnabled);
    if (!collectionEnabled) {
      await crashlytics.deleteUnsentReports();
      AppDiagnostics.sink = null;
      return;
    }
    final package = await PackageInfo.fromPlatform();
    await crashlytics.setCustomKey('environment', ApiEnvironment.name);
    await crashlytics.setCustomKey(
        'release', '${package.version}+${package.buildNumber}');
    await analytics
        .setDefaultEventParameters({'environment': ApiEnvironment.name});
    AppDiagnostics.sink = (record) async {
      if (record.event == 'client_error') {
        // Error messages may contain server payloads or credentials. Send the type and stack only.
        await crashlytics.recordError(
          StateError('Unhandled ${record.fields['error_type']}'),
          record.stack,
          fatal: true,
        );
      } else if (record.event == 'api_result') {
        await crashlytics.setCustomKey(
            'last_request_id', record.fields['request_id']!);
        // Measure write outcomes for key journeys, excluding user IDs, URLs and payloads.
        if (record.fields['method'] != 'GET' &&
            const {'requests', 'laundry', 'payments', 'jobs'}
                .contains(record.fields['operation'])) {
          await analytics.logEvent(name: 'journey_api_result', parameters: {
            'operation': record.fields['operation']!,
            'method': record.fields['method']!,
            'status': record.fields['status']!,
          });
        }
      }
    };
  }
}
