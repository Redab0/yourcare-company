import 'dart:typed_data';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
import 'package:cleaning_service_driver/data/services/documents/documents_service.dart';

class DocumentsRepository {
  final DocumentsService service;
  const DocumentsRepository(this.service);
  Future<DocumentPage> list(
      {int page = 1, String? search, String? category}) async {
    final result = await service.list(page, 20, search, category);
    if (!result.success || result.data == null) {
      throw StateError(result.message);
    }
    return result.data!;
  }

  Future<Uint8List> download(String id) async =>
      Uint8List.fromList(await service.download(id));
}
