/// No analytics/crash SDK is linked. This adapter stays for startup compatibility.
abstract final class MobileTelemetry {
  static const collectionEnabled = false;
  static Future<void> initialize() async {}
}
