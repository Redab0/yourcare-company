class SendChatMessageRequest {
  final String conversationId;
  final String content;
  final String type;

  const SendChatMessageRequest({
    required this.conversationId,
    required this.content,
    this.type = 'text',
  });

  Map<String, dynamic> toJson() => {
        'conversationId': conversationId,
        'content': content,
        'type': type,
      };
}
