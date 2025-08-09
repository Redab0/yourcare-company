import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A simple widget that displays a location icon. When tapped,
/// it opens Google Maps centered at the given latitude and longitude.
class OpenMapAction extends StatelessWidget {
  /// The latitude coordinate.
  final double latitude;

  /// The longitude coordinate.
  final double longitude;

  const OpenMapAction({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  Future<void> _openMap() async {
    // Construct the Google Maps URL
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (!await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.location_on,
      ),
      onPressed: _openMap,
      tooltip: 'Open in Google Maps',
    );
  }
}
