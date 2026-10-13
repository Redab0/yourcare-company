import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';

Future<bool> saveBusinessDocument(
    BusinessDocument document, Uint8List bytes) async {
  final String? savedPath;
  if (kIsWeb) {
    savedPath = await FileSaver.instance.saveFile(
      name: document.fileName,
      bytes: bytes,
      includeExtension: false,
      mimeType: MimeType.custom,
      customMimeType: document.mimeType,
    );
  } else {
    savedPath = await FileSaver.instance.saveAs(
      name: document.fileName,
      bytes: bytes,
      fileExtension: document.fileName.split('.').last,
      includeExtension: false,
      mimeType: MimeType.custom,
      customMimeType: document.mimeType,
    );
  }
  return savedPath != null;
}
