import 'package:json_annotation/json_annotation.dart';

part 'custom_service_item_request.g.dart';

@JsonSerializable(createFactory: false)
class CustomServiceItemRequest {
  final String serviceType;
  final String titleEn;
  final String titleAr;

  const CustomServiceItemRequest({
    required this.serviceType,
    required this.titleEn,
    required this.titleAr,
  });

  Map<String, dynamic> toJson() => _$CustomServiceItemRequestToJson(this);
}
