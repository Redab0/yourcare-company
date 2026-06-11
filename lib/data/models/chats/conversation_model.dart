class ConversationModel {
  final String id;
  final String? customerId;
  final String? businessId;
  final String? requestId;
  final String? status;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? closedAt;
  final String? customerName;
  final String? customerPhone;
  final String? businessName;
  final String? requestReadableId;
  final String? requestType;
  final String? requestStatus;
  final num? requestTotalPrice;

  const ConversationModel({
    required this.id,
    this.customerId,
    this.businessId,
    this.requestId,
    this.status,
    this.lastMessage,
    this.lastMessageAt,
    this.closedAt,
    this.customerName,
    this.customerPhone,
    this.businessName,
    this.requestReadableId,
    this.requestType,
    this.requestStatus,
    this.requestTotalPrice,
  });

  bool get hasLastMessage => (lastMessage?.trim().isNotEmpty ?? false);
  bool get isClosed => status?.toLowerCase() == 'closed';

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final customerMap = _toMap(json['customer']);
    final businessMap = _toMap(json['business']);
    final requestMap = _toMap(json['request']);
    return ConversationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      customerId: json['customerId']?.toString(),
      businessId: json['businessId']?.toString(),
      requestId: json['requestId']?.toString(),
      status: json['status']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _toDate(json['lastMessageAt']),
      closedAt: _toDate(json['closedAt']),
      customerName: customerMap?['username']?.toString(),
      customerPhone: customerMap?['phone']?.toString(),
      businessName: businessMap?['name']?.toString(),
      requestReadableId: requestMap?['readableId']?.toString(),
      requestType: requestMap?['type']?.toString(),
      requestStatus: requestMap?['requestStatus']?.toString(),
      requestTotalPrice: _toNum(requestMap?['totalPrice']),
    );
  }

  static Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
