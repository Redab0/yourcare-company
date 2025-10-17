// app_icon_spinner.dart
import 'dart:math' as math;

import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:flutter/material.dart';

class LoadingOverlay implements LoadingController {
  LoadingOverlay(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;
  final Map<String, OverlayEntry> _entries = {};

  @override
  void show([String tag = 'global']) {
    if (_entries.containsKey(tag)) return;

    final entry = OverlayEntry(
      builder: (context) => Stack(
        children: const [
          // Dim the background and block gestures
          ModalBarrier(dismissible: false),
          // Center the animated app icon
          Center(
            child: AppIconSpinner(
              assetPath: 'assets/images/ic_yourcare.png', // <- your icon
              size: 96,
            ),
          ),
        ],
      ),
    );

    _navigatorKey.currentState!.overlay!.insert(entry);
    _entries[tag] = entry;
  }

  @override
  void hide([String tag = 'global']) {
    _entries.remove(tag)?.remove();
  }
}

class AppIconSpinner extends StatefulWidget {
  const AppIconSpinner({
    super.key,
    required this.assetPath,
    this.size = 96,
    this.duration = const Duration(milliseconds: 1200),
  });

  final String assetPath;
  final double size;
  final Duration duration;

  @override
  State<AppIconSpinner> createState() => _AppIconSpinnerState();
}

class _AppIconSpinnerState extends State<AppIconSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _turns; // 0..1
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
    _turns = CurvedAnimation(parent: _c, curve: Curves.linear);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 0.9), weight: 50),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Transform.rotate(
          angle: _turns.value * 2 * math.pi,
          child: Transform.scale(
            scale: _scale.value,
            child: Image.asset(
              widget.assetPath,
              width: widget.size,
              height: widget.size,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}
