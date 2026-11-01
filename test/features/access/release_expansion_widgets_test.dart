import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/release_expansion_journey.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    HttpOverrides.global = NoNetwork();
  });
  tearDownAll(() {
    HttpOverrides.global = null;
  });
  providerReleaseJourneys();
}
