class BusinessDocument {
  final String id, title, description, category, audience, fileName, mimeType;
  final int size;
  final DateTime? createdAt;
  const BusinessDocument(
      {required this.id,
      required this.title,
      this.description = '',
      required this.category,
      required this.audience,
      required this.fileName,
      required this.mimeType,
      required this.size,
      this.createdAt});
  factory BusinessDocument.fromJson(Map<String, dynamic> j) => BusinessDocument(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String? ?? '',
      category: j['category'] as String,
      audience: j['audience'] as String,
      fileName: j['fileName'] as String,
      mimeType: j['mimeType'] as String,
      size: (j['size'] as num).toInt(),
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''));
}

class DocumentPage {
  final List<BusinessDocument> docs;
  final int page, totalPages;
  const DocumentPage(
      {required this.docs, required this.page, required this.totalPages});
  factory DocumentPage.fromJson(Map<String, dynamic> j) => DocumentPage(
      docs: (j['docs'] as List)
          .map((d) => BusinessDocument.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
      page: (j['page'] as num).toInt(),
      totalPages: (j['totalPages'] as num).toInt());
}
