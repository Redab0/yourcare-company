import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/data/models/chats/create_conversation_request.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'chat_service.g.dart';

@RestApi()
abstract class ChatApi {
  factory ChatApi(Dio dio, {String baseUrl}) = _ChatApi;

  @POST('/chat/conversations')
  Future<dynamic> createOrGetConversation(
    @Body() CreateConversationRequest request,
  );

  @GET('/chat/conversations/{conversationId}/messages')
  Future<dynamic> getConversationMessages(
    @Path('conversationId') String conversationId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/chat/conversations')
  Future<dynamic> getConversations(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @PATCH('/chat/conversations/{conversationId}/close')
  Future<dynamic> closeConversation(
    @Path('conversationId') String conversationId,
  );

  @PATCH('/chat/conversations/{conversationId}/open')
  Future<dynamic> openConversation(
    @Path('conversationId') String conversationId,
  );
}

class ChatService {
  final ChatApi _api;

  ChatService(Dio dio) : _api = ChatApi(dio);

  Future<ApiResponse<ConversationModel>> createOrGetConversation(
    CreateConversationRequest request,
  ) async {
    final response = await _api.createOrGetConversation(request);
    return _conversationResponse(_responseMap(response));
  }

  Future<ApiResponse<RawChatHistoryResult>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.getConversationMessages(
      conversationId,
      page,
      limit,
    );

    final json = _responseMap(response);
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
    final response = await _api.getConversations(page, limit);

    final json = _responseMap(response);
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
    final response = await _api.closeConversation(conversationId);
    return _conversationResponse(_responseMap(response));
  }

  Future<ApiResponse<ConversationModel>> openConversation(
      String conversationId) async {
    final response = await _api.openConversation(conversationId);
    return _conversationResponse(_responseMap(response));
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

  Map<String, dynamic> _responseMap(Object? response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
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
