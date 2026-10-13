/// Status notifications reuse the shared push channel and point to a scoped
/// request lookup. Chat notifications retain their existing conversation route.
String? laundryRequestIdFromNotification(Map<String, dynamic> data) {
  if (data['notificationType'] == 'chat_message' ||
      data['conversationId'] != null) {
    return null;
  }
  if (data['requestType'] != 'laundry' &&
      data['notificationType'] != 'laundry_status_changed') {
    return null;
  }
  final id = (data['requestId'] ?? data['request_id'])?.toString().trim();
  return id == null || id.isEmpty ? null : id;
}
