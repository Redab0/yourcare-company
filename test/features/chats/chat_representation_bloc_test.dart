import 'dart:async';
import 'package:cleaning_service_driver/data/models/chats/chat_history_result.dart';
import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chats_bloc.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_history_service.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_memory_store.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessageModel msg(String id, String text, int minute) => ChatMessageModel(
    id: id,
    conversationId: 'one',
    senderId: 'customer',
    text: text,
    isMine: false,
    sentAt: DateTime.utc(2026, 10, 21, 0, minute));

class _Socket implements ChatSocketService {
  final messages = StreamController<ChatMessageModel>.broadcast();
  @override
  Stream<ChatMessageModel> get messagesStream => messages.stream;
  @override
  Stream<String> get statusStream => const Stream.empty();
  @override
  Future<void> connect() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _History implements ChatHistoryService {
  final pages = <int>[];
  @override
  Future<ChatHistoryResult> loadHistory(
      {required String conversationId,
      required String? currentUserId,
      required bool fallbackMineWhenCustomer,
      int page = 1,
      int limit = 20}) async {
    pages.add(page);
    return ChatHistoryResult(
        conversation: null,
        messages: page == 1
            ? [msg('same', 'history-fresh', 2)]
            : [msg('same', 'page-fresh', 2), msg('older', 'older', 1)],
        page: page,
        limit: 1,
        total: 2);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> until(bool Function() ready) async {
  for (var i = 0; i < 100; i++) {
    if (ready()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  throw StateError('Local BLoC fixture did not settle');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'history/socket same-ID renewal preserves unique order, pagination and incoming scroll intent',
      () async {
    FlutterSecureStorage.setMockInitialValues({});
    final socket = _Socket(), history = _History();
    final memory = ChatMemoryStore()..addMessage('one', msg('same', 'old', 2));
    final bloc = ChatsBloc(socket, memory, history);
    addTearDown(() async {
      await bloc.close();
      await socket.messages.close();
    });
    bloc.add(const ConnectChatEvent('one'));
    await until(() => bloc.state.conversationId == 'one');
    bloc.add(const LoadChatHistoryEvent(force: true));
    await until(() => bloc.state.messages.single.text == 'history-fresh');
    bloc.add(const LoadOlderChatHistoryEvent());
    await until(() => bloc.state.historyPage == 2);
    expect(history.pages, [1, 2]);
    expect(bloc.state.messages.map((m) => m.id), ['older', 'same']);
    expect(bloc.state.messages.last.text, 'page-fresh');
    expect(bloc.state.shouldScrollToBottom, isFalse);
    socket.messages.add(msg('same', 'socket-fresh', 2));
    await until(() => bloc.state.messages.last.text == 'socket-fresh');
    expect(bloc.state.messages, hasLength(2));
    expect(bloc.state.shouldScrollToBottom, isFalse);
    socket.messages.add(msg('new', 'new-message', 3));
    await until(() => bloc.state.messages.length == 3);
    expect(bloc.state.shouldScrollToBottom, isTrue);
  });
}
