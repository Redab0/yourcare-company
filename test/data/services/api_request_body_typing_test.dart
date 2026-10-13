import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API services use typed request bodies', () {
    final serviceFiles = Directory('lib/data/services')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'),
        );
    final rawRetrofitBody = RegExp(
      r'@Body\(\)\s+(?:Map\s*<|dynamic\b|Object\b)',
      multiLine: true,
    );
    final serializedDirectBody = RegExp(
      r'data:\s*(?:\w+\.toJson\(\)|<String,\s*dynamic>|\{)',
      multiLine: true,
    );
    final violations = <String>[];

    for (final file in serviceFiles) {
      final source = file.readAsStringSync();
      if (rawRetrofitBody.hasMatch(source)) {
        violations.add('${file.path}: raw Retrofit body');
      }
      if (serializedDirectBody.hasMatch(source)) {
        violations.add('${file.path}: directly serialized body');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Create a dedicated JSON-serializable request model and pass it '
          'directly to the API service.\n${violations.join('\n')}',
    );
  });
}
