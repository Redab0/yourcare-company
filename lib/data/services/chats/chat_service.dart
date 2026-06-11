import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/data/models/chats/create_conversation_request.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:dio/dio.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio);

  Future<ApiResponse<ConversationModel>> createOrGetConversation(
    CreateConversationRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/conversations',
      data: request.toJson(),
    );
    return _conversationResponse(response.data);
  }

  Future<ApiResponse<RawChatHistoryResult>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/chat/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );

    final json = response.data ?? <String, dynamic>{};
    final rawData = json['data'];

    List<Map<String, dynamic>> messages = const [];
    Map<String, dynamic>? conversation;

    if (rawData is List) {
      messages = _toMapList(rawData);
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['conversation'] is Map<String, dynamic>) {
        conversation = rawData['conversation'] as Map<String, dynamic>;
      } else if (rawData['conversation'] is Map) {
        conversation =
            Map<String, dynamic>.from(rawData['conversation'] as Map);
      }
      dynamic list = rawData['docs'];
      list ??= rawData['messages'];
      list ??= rawData['data'];
      if (list is List) {
        messages = _toMapList(list);
      }
    }

    return ApiResponse<RawChatHistoryResult>(
      success: (json['success'] as bool?) ?? false,
      message: json['message']?.toString() ?? '',
      data: RawChatHistoryResult(
        conversation: conversation,
        messages: messages,
        total: _toInt(rawData is Map ? rawData['total'] : null),
        page: _toInt(rawData is Map ? rawData['page'] : null) ?? page,
        limit: _toInt(rawData is Map ? rawData['limit'] : null) ?? limit,
      ),
    );
  }

  Future<ApiResponse<List<ConversationModel>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/chat/conversations',
      queryParameters: {'page': page, 'limit': limit},
    );

    final json = response.data ?? <String, dynamic>{};
    final rawData = json['data'];
    List<Map<String, dynamic>> docs = const [];

    if (rawData is List) {
      docs = _toMapList(rawData);
    } else if (rawData is Map<String, dynamic>) {
      dynamic list = rawData['docs'];
      list ??= rawData['data'];
      list ??= rawData['conversations'];
      if (list is List) {
        docs = _toMapList(list);
      }
    }

    return ApiResponse<List<ConversationModel>>(
      success: (json['success'] as bool?) ?? false,
      message: json['message']?.toString() ?? '',
      data: docs.map(ConversationModel.fromJson).toList(),
    );
  }

  Future<ApiResponse<ConversationModel>> closeConversation(
      String conversationId) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/chat/conversations/$conversationId/close',
    );
    return _conversationResponse(response.data);
  }

  Future<ApiResponse<ConversationModel>> openConversation(
      String conversationId) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/chat/conversations/$conversationId/open',
    );
    return _conversationResponse(response.data);
  }

  ApiResponse<ConversationModel> _conversationResponse(
      Map<String, dynamic>? json) {
    final body = json ?? <String, dynamic>{};
    final data = (body['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return ApiResponse<ConversationModel>(
      success: (body['success'] as bool?) ?? false,
      message: body['message']?.toString() ?? '',
      data: data.isEmpty ? null : ConversationModel.fromJson(data),
    );
  }

  List<Map<String, dynamic>> _toMapList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class RawChatHistoryResult {
  final Map<String, dynamic>? conversation;
  final List<Map<String, dynamic>> messages;
  final int? total;
  final int page;
  final int limit;

  const RawChatHistoryResult({
    required this.conversation,
    required this.messages,
    required this.total,
    required this.page,
    required this.limit,
  });
}
