import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// features/widgets/loading_overlay.dart
class LoadingOverlay implements LoadingController {
  LoadingOverlay(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;
  final Map<String, OverlayEntry> _entries = {};

  @override
  void show([String tag = 'global']) {
    if (_entries.containsKey(tag)) return; // already visible
    final overlay = OverlayEntry(
      builder: (_) => Lottie.asset(
        'assets/animations/loading_plane.json',
        width: 100,
        height: 100,
      ),
    );
    _navigatorKey.currentState!.overlay!.insert(overlay);
    _entries[tag] = overlay;
  }

  @override
  void hide([String tag = 'global']) {
    _entries.remove(tag)?.remove();
  }
}
