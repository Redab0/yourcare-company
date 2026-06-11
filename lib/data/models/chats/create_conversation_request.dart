class CreateConversationRequest {
  final String? requestId;

  const CreateConversationRequest({
    this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (requestId?.isNotEmpty ?? false) 'requestId': requestId,
    };
  }
}
