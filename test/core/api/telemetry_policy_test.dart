import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/core/api/api_environment.dart';
import 'package:cleaning_service_driver/core/diagnostics/mobile_telemetry.dart';

void main() {
  test('development cannot send to the installed production Firebase project',
      () {
    if (ApiEnvironment.isDevelopment)
      expect(MobileTelemetry.collectionEnabled, isFalse);
    expect(
        MobileTelemetry.collectionEnabled,
        !ApiEnvironment.isDevelopment &&
            const bool.fromEnvironment('TELEMETRY_ENABLED',
                defaultValue: true));
  });
}
