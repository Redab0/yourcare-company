import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/core/diagnostics/mobile_telemetry.dart';

void main() {
  test('telemetry stays disabled in every environment/build define', () {
    expect(MobileTelemetry.collectionEnabled, isFalse);
  });
}
