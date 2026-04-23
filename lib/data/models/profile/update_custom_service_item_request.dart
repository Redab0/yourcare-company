class UpdateCustomServiceItemRequest {
  final String titleEn;
  final String titleAr;

  const UpdateCustomServiceItemRequest({
    required this.titleEn,
    required this.titleAr,
  });

  Map<String, dynamic> toJson() {
    return {
      'titleEn': titleEn,
      'titleAr': titleAr,
    };
  }
}
