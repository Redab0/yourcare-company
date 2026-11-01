import 'dart:io';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test/helpers/release_expansion_journey.dart';

/// Deliberately does not import main(), initialize Firebase, DI, sockets or the
/// production API client. Only actual feature widgets with synthetic authority
/// and local BLoCs are mounted. Unexpected HTTP fails before opening a socket.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    HttpOverrides.global = NoNetwork();
  });
  tearDownAll(() {
    HttpOverrides.global = null;
  });
  providerReleaseJourneys(screenshot: (tester, name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  });
}
