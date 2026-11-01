import 'package:flutter/foundation.dart';

class DiagnosticRecord {
  const DiagnosticRecord(this.event, this.fields, {this.stack});
  final String event;
  final Map<String, Object> fields;
  final StackTrace? stack;
}

typedef DiagnosticSink = Future<void> Function(DiagnosticRecord record);

/// Diagnostics are disabled in every build, including debug/background startup.
abstract final class AppDiagnostics {
  static const maxRecords = 0;
  static List<DiagnosticRecord> get records => const [];
  static DiagnosticSink? get sink => null;
  static set sink(DiagnosticSink? value) {}
  static void installErrorHandlers() {
    FlutterError.onError = (_) {};
    PlatformDispatcher.instance.onError = (_, __) => true;
  }

  static void recordError(Object error, StackTrace? stack,
      {String category = 'flutter'}) {}
  static void recordApi(
      {required String method,
      required String operation,
      required int status,
      required String requestId}) {}
}
