import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerLocationReminder extends StatelessWidget {
  const CustomerLocationReminder({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          context.l10n.request_location_reminder,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
}

/// A simple widget that displays a location icon. When tapped,
/// it opens Google Maps centered at the given latitude and longitude.
class OpenMapAction extends StatelessWidget {
  /// The latitude coordinate.
  final double latitude;

  /// The longitude coordinate.
  final double longitude;

  const OpenMapAction({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  static bool hasValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude.abs() > 90 || longitude.abs() > 180) return false;
    return latitude != 0 || longitude != 0;
  }

  static String? googleMapsLink(double? latitude, double? longitude) {
    if (!hasValidCoordinates(latitude, longitude)) return null;
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  Future<void> _openMap() async {
    final link = googleMapsLink(latitude, longitude);
    if (link == null) return;
    final googleMapsUrl = Uri.parse(link);

    if (!await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasValidCoordinates(latitude, longitude)) {
      return const SizedBox.shrink();
    }
    return TextButton.icon(
      onPressed: _openMap,
      icon: const Icon(Icons.location_on_outlined),
      label: Text(context.l10n.open_in_google_maps),
    );
  }
}
