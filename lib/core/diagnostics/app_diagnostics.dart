import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_environment.dart';

class DiagnosticRecord {
  const DiagnosticRecord(this.event, this.fields, {this.stack});
  final String event;
  final Map<String, Object> fields;
  final StackTrace? stack;
}

typedef DiagnosticSink = Future<void> Function(DiagnosticRecord record);

/// Bounded, metadata-only diagnostics. Never stores payloads, URLs or credentials.
abstract final class AppDiagnostics {
  static const maxRecords = 50;
  static final List<DiagnosticRecord> _records = [];
  static DiagnosticSink? sink;
  static List<DiagnosticRecord> get records => List.unmodifiable(_records);

  static void installErrorHandlers() {
    FlutterError.onError = (details) {
      if (kDebugMode) FlutterError.presentError(details);
      recordError(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, category: 'platform');
      return true;
    };
  }

  static void recordError(Object error, StackTrace? stack,
      {String category = 'flutter'}) {
    _record(DiagnosticRecord(
        'client_error',
        {
          'error_type': error.runtimeType.toString(),
          'category': const {'flutter', 'platform', 'network', 'render'}
                  .contains(category)
              ? category
              : 'flutter',
          'environment': ApiEnvironment.name,
        },
        stack: stack));
  }

  static void recordApi(
      {required String method,
      required String operation,
      required int status,
      required String requestId}) {
    _record(DiagnosticRecord('api_result', {
      'method': const {'GET', 'POST', 'PUT', 'PATCH', 'DELETE'}.contains(method)
          ? method
          : 'OTHER',
      'operation': operation,
      'status': status,
      'request_id': requestId,
      'environment': ApiEnvironment.name,
    }));
  }

  static void _record(DiagnosticRecord record) {
    _records.add(record);
    if (_records.length > maxRecords) _records.removeAt(0);
    if (kDebugMode) debugPrint('YourCare ${record.event}: ${record.fields}');
    final target = sink;
    if (target != null) {
      unawaited(
          Future<void>.sync(() => target(record)).catchError((Object _) {}));
    }
  }
}
