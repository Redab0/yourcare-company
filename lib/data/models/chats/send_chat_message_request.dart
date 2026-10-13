import 'package:json_annotation/json_annotation.dart';

part 'send_chat_message_request.g.dart';

@JsonSerializable(createFactory: false)
class SendChatMessageRequest {
  final String conversationId;
  final String content;
  final String type;

  const SendChatMessageRequest({
    required this.conversationId,
    required this.content,
    this.type = 'text',
  });

  Map<String, dynamic> toJson() => _$SendChatMessageRequestToJson(this);
}
