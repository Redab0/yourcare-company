import 'dart:typed_data';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:cleaning_service_driver/data/repositories/documents/documents_repository.dart';

class DocumentsUseCases {
  final DocumentsRepository repository;
  const DocumentsUseCases(this.repository);
  Future<DocumentPage> list({int page = 1, String? search, String? category}) =>
      repository.list(page: page, search: search, category: category);
  Future<Uint8List> download(String id) => repository.download(id);
}
