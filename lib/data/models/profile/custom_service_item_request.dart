class CustomServiceItemRequest {
  final String serviceType;
  final String titleEn;
  final String titleAr;

  const CustomServiceItemRequest({
    required this.serviceType,
    required this.titleEn,
    required this.titleAr,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'titleEn': titleEn,
      'titleAr': titleAr,
    };
  }
}
