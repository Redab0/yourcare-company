import 'package:json_annotation/json_annotation.dart';

part 'update_custom_service_item_request.g.dart';

@JsonSerializable(createFactory: false)
class UpdateCustomServiceItemRequest {
  final String titleEn;
  final String titleAr;

  const UpdateCustomServiceItemRequest({
    required this.titleEn,
    required this.titleAr,
  });

  Map<String, dynamic> toJson() => _$UpdateCustomServiceItemRequestToJson(this);
}
