class ChatMessageModel {
  final String id;
  final String? conversationId;
  final String? senderId;
  final String text;
  final bool isMine;
  final DateTime sentAt;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.isMine,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    required String? currentUserId,
    required bool fallbackMineWhenCustomer,
  }) {
    final senderType = json['senderType']?.toString().toLowerCase();
    final senderObj = json['sender'];
    final senderIdFromObj = senderObj is Map<String, dynamic>
        ? senderObj['id']?.toString() ?? senderObj['_id']?.toString()
        : null;
    final senderRaw = json['sender'];
    final senderId = json['senderId']?.toString() ??
        senderIdFromObj ??
        (senderRaw is String ? senderRaw : null);
    final bool isMine;
    if (senderType == 'company' || senderType == 'business') {
      isMine = true;
    } else if (senderType == 'customer') {
      isMine = false;
    } else {
      isMine = (currentUserId != null && senderId == currentUserId) ||
          (senderId == null &&
              fallbackMineWhenCustomer &&
              senderType == 'customer');
    }

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      conversationId: json['conversationId']?.toString(),
      senderId: senderId,
      text: (json['content'] ?? json['text'] ?? '').toString(),
      isMine: isMine,
      sentAt: _resolveTimestamp(json),
    );
  }

  static DateTime _resolveTimestamp(Map<String, dynamic> json) {
    final candidates = [
      json['createdAt'],
      json['timestamp'],
      json['sentAt'],
      json['updatedAt'],
    ];
    for (final c in candidates) {
      if (c == null) continue;
      final parsed = DateTime.tryParse(c.toString());
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }
}
