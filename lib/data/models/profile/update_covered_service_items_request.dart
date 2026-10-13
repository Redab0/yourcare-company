import 'package:json_annotation/json_annotation.dart';

part 'update_covered_service_items_request.g.dart';

@JsonSerializable(createFactory: false)
class UpdateCoveredServiceItemsRequest {
  final List<String> serviceItemIds;

  const UpdateCoveredServiceItemsRequest(this.serviceItemIds);

  Map<String, dynamic> toJson() =>
      _$UpdateCoveredServiceItemsRequestToJson(this);
}
