part of 'chats_bloc.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

class ConnectChatEvent extends ChatsEvent {
  final String conversationId;

  const ConnectChatEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class LoadChatHistoryEvent extends ChatsEvent {
  final bool force;

  const LoadChatHistoryEvent({this.force = false});

  @override
  List<Object?> get props => [force];
}

class LoadOlderChatHistoryEvent extends ChatsEvent {
  const LoadOlderChatHistoryEvent();
}

class SendChatMessageEvent extends ChatsEvent {
  final String text;

  const SendChatMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class MinimizeChatEvent extends ChatsEvent {
  const MinimizeChatEvent();
}

class CloseChatEvent extends ChatsEvent {
  const CloseChatEvent();
}

class _IncomingMessageEvent extends ChatsEvent {
  final ChatMessageModel message;

  const _IncomingMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class _SocketStatusEvent extends ChatsEvent {
  final String status;

  const _SocketStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}
