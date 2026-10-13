import 'package:json_annotation/json_annotation.dart';

part 'create_conversation_request.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateConversationRequest {
  final String? requestId;

  CreateConversationRequest({String? requestId})
      : requestId = requestId?.trim().isEmpty == true ? null : requestId;

  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}
