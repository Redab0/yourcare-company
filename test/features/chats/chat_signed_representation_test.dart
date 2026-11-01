import 'package:flutter_test/flutter_test.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_memory_store.dart';
import 'package:cleaning_service_driver/data/models/chats/chat_message_model.dart';

ChatMessageModel message(String id, String text,
        {int minute = 1, String conversation = 'one'}) =>
    ChatMessageModel(
        id: id,
        conversationId: conversation,
        senderId: 'sender',
        text: text,
        isMine: false,
        sentAt: DateTime.utc(2026, 10, 21, 0, minute));
void main() {
  test(
      'renewed same-ID signed representation replaces one row and retains order',
      () {
    final store = ChatMemoryStore();
    store.addMessage('one', message('later', 'later', minute: 2));
    store.addMessage('one', message('same', 'https://signed.invalid/old'));
    expect(
        store.addMessage(
            'one', message('same', 'https://signed.invalid/fresh')),
        isTrue);
    final rows = store.getMessages('one');
    expect(rows.map((m) => m.id), ['same', 'later']);
    expect(rows.first.text, 'https://signed.invalid/fresh');
    expect(
        store.addMessage(
            'one', message('same', 'https://signed.invalid/fresh')),
        isFalse);
    expect(store.getMessages('one'), hasLength(2));
  });
  test('updated timestamp is reordered without duplicating identity', () {
    final store = ChatMemoryStore();
    store.addMessage('one', message('same', 'old'));
    store.addMessage('one', message('middle', 'middle', minute: 2));
    store.addMessage('one', message('same', 'new', minute: 3));
    expect(store.getMessages('one').map((m) => m.id), ['middle', 'same']);
  });
  test('conversation scope and account clear never reuse another cached row',
      () {
    final store = ChatMemoryStore();
    expect(
        store.addMessage(
            'one', message('same', 'foreign', conversation: 'other')),
        isFalse);
    store.addMessage('one', message('same', 'one'));
    store.addMessage('other', message('same', 'other', conversation: 'other'));
    store.clearConversation('one');
    expect(store.getMessages('one'), isEmpty);
    expect(store.getMessages('other').single.text, 'other');
    store.clearAll();
    expect(store.getMessages('other'), isEmpty);
    expect(store.addMessage('one', message('same', 'new-account')), isTrue);
    expect(store.getMessages('one').single.text, 'new-account');
  });
  test('history merge and single incoming delivery use the same upsert path',
      () {
    final store = ChatMemoryStore();
    store.addMessage('one', message('same', 'old'));
    store.mergeMessages('one',
        [message('same', 'renewed'), message('earlier', 'earlier', minute: 0)]);
    expect(store.getMessages('one').map((m) => m.id), ['earlier', 'same']);
    expect(store.getMessages('one').last.text, 'renewed');
    store.addMessage('one', message('same', 'socket-renewed'));
    expect(store.getMessages('one'), hasLength(2));
    expect(store.getMessages('one').last.text, 'socket-renewed');
  });
}
