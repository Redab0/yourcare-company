import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayServices {
  static Future<bool> ensureAvailable() async {
    if (kIsWeb || Platform.isIOS) return true; // not applicable

    final gms = GoogleApiAvailability.instance;
    final status = await gms.checkGooglePlayServicesAvailability();
    debugPrint('Google Play services status: $status');

    if (status == GooglePlayServicesAvailability.success) return true;

    // These are user-fixable
    final resolvable = status ==
            GooglePlayServicesAvailability.serviceMissing ||
        status == GooglePlayServicesAvailability.serviceVersionUpdateRequired ||
        status == GooglePlayServicesAvailability.serviceDisabled;

    if (resolvable) {
      // Try Play Store first, then web fallback
      final candidates = <Uri>[
        Uri.parse('market://details?id=com.google.android.gms'),
        Uri.parse(
            'https://play.google.com/store/apps/details?id=com.google.android.gms'),
      ];
      for (final uri in candidates) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          break;
        }
      }
    }

    return false;
  }
}
