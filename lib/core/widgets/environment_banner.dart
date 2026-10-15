import 'package:flutter/material.dart';
import '../api/api_environment.dart';

/// Visible in all build modes so a development release is unmistakable.
class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ApiEnvironment.isDevelopment) return child;
    return Banner(
      message: 'DEV',
      location: BannerLocation.topEnd,
      color: const Color(0xFFD97706),
      textDirection: Directionality.of(context),
      child: child,
    );
  }
}
