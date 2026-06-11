import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/domain/usecases/chats/close_conversation_usecase.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chat_launcher_cubit.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chats_bloc.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

String _connectionStatusLabel(BuildContext context, String status) {
  return switch (status) {
    'connected' => context.l10n.chat_status_connected,
    'connecting' => context.l10n.chat_status_connecting,
    'disconnected' => context.l10n.chat_status_disconnected,
    'error' => context.l10n.chat_status_error,
    _ => status,
  };
}

class ChatScreen extends StatelessWidget {
  final String conversationId;
  final bool shouldLoadHistory;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.shouldLoadHistory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatsBloc>(),
      child: _ChatScreenView(
        conversationId: conversationId,
        shouldLoadHistory: shouldLoadHistory,
      ),
    );
  }
}

class _ChatScreenView extends StatefulWidget {
  final String conversationId;
  final bool shouldLoadHistory;

  const _ChatScreenView({
    required this.conversationId,
    required this.shouldLoadHistory,
  });

  @override
  State<_ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<_ChatScreenView> {
  final _controller = TextEditingController();
  final _messagesScrollController = ScrollController();
  StreamSubscription? _conversationSub;
  int _lastMessageCount = 0;
  int _handledSendSuccessCount = 0;
  bool _isClosed = false;
  double? _olderLoadPreviousMaxExtent;
  double? _olderLoadPreviousOffset;

  @override
  void initState() {
    super.initState();
    sl<ChatLauncherCubit>().setWindowOpen(
      true,
      conversationId: widget.conversationId,
    );
    sl<ChatLauncherCubit>().clearConversationUnread(widget.conversationId);
    final bloc = context.read<ChatsBloc>();
    bloc.add(ConnectChatEvent(widget.conversationId));
    bloc.add(const LoadChatHistoryEvent(force: true));
    _conversationSub =
        sl<ChatSocketService>().conversationStream.listen((conversation) {
      if (!conversation.isClosed || conversation.id != widget.conversationId) {
        return;
      }
      _isClosed = true;
      if (!mounted) return;
      context.read<ChatsBloc>().add(const LoadChatHistoryEvent(force: true));
    });
  }

  @override
  void dispose() {
    if (_isClosed) {
      _clearLauncherIfCurrent();
    }
    sl<ChatLauncherCubit>().setWindowOpen(false);
    _conversationSub?.cancel();
    _controller.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_messagesScrollController.hasClients) return;
    final target = _messagesScrollController.position.maxScrollExtent;
    if (animated) {
      _messagesScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _messagesScrollController.jumpTo(target);
    }
  }

  void _loadOlderMessages() {
    if (_messagesScrollController.hasClients) {
      _olderLoadPreviousMaxExtent =
          _messagesScrollController.position.maxScrollExtent;
      _olderLoadPreviousOffset = _messagesScrollController.offset;
    }
    context.read<ChatsBloc>().add(const LoadOlderChatHistoryEvent());
  }

  void _restoreScrollAfterOlderMessages() {
    final previousMax = _olderLoadPreviousMaxExtent;
    final previousOffset = _olderLoadPreviousOffset;
    if (previousMax == null || previousOffset == null) return;

    _olderLoadPreviousMaxExtent = null;
    _olderLoadPreviousOffset = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) return;
      final position = _messagesScrollController.position;
      final delta = position.maxScrollExtent - previousMax;
      final target = (previousOffset + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _messagesScrollController.jumpTo(target);
    });
  }

  Future<void> _confirmClose() async {
    final state = context.read<ChatsBloc>().state;
    if (state.conversation?.isClosed ?? false) {
      context.read<ChatsBloc>().add(const CloseChatEvent());
      _clearLauncherIfCurrent();
      Navigator.of(context).pop();
      return;
    }
    final close = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(ctx.l10n.chat_close_confirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(ctx.l10n.chat_close),
              ),
            ],
          ),
        ) ??
        false;

    if (!close || !mounted) return;
    try {
      await sl<CloseConversationUseCase>().call(widget.conversationId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chat_close_failed)),
      );
      return;
    }
    if (!mounted) return;
    context.read<ChatsBloc>().add(const CloseChatEvent());
    _clearLauncherIfCurrent();
    Navigator.of(context).pop();
  }

  void _minimizeChat() {
    if (_isClosed) {
      context.read<ChatsBloc>().add(const CloseChatEvent());
      _clearLauncherIfCurrent();
    }
    Navigator.of(context).pop();
  }

  void _clearLauncherIfCurrent() {
    final launcher = sl<ChatLauncherCubit>();
    if (launcher.state.conversationId == widget.conversationId) {
      launcher.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chat_with_customer),
        actions: [
          TextButton(
            onPressed: _minimizeChat,
            child: Text(context.l10n.chat_minimize),
          ),
          IconButton(
            onPressed: _confirmClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<ChatsBloc, ChatsState>(
          listenWhen: (previous, current) =>
              previous.sendSuccessCount != current.sendSuccessCount ||
              previous.error != current.error ||
              previous.conversation?.isClosed !=
                  current.conversation?.isClosed ||
              (previous.isLoadingOlder && !current.isLoadingOlder),
          listener: (context, state) {
            _isClosed = state.conversation?.isClosed ?? _isClosed;
            if (!state.isLoadingOlder) {
              _restoreScrollAfterOlderMessages();
            }
            if (state.sendSuccessCount > _handledSendSuccessCount) {
              _handledSendSuccessCount = state.sendSuccessCount;
              _controller.clear();
            }
            final error = state.error;
            if (error != null && error.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.chat_send_failed)),
              );
            }
          },
          child: Column(
            children: [
              BlocBuilder<ChatsBloc, ChatsState>(
                builder: (context, state) {
                  final isClosed = state.conversation?.isClosed ?? false;
                  final color = isClosed
                      ? Colors.red
                      : switch (state.status) {
                          'connected' => Colors.green,
                          'connecting' => Colors.orange,
                          'error' => Colors.red,
                          _ => Colors.grey,
                        };
                  final label = isClosed
                      ? context.l10n.chat_closed
                      : _connectionStatusLabel(context, state.status);
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        backgroundColor: color.withValues(alpha: 0.1),
                        label: Text(label),
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<ChatsBloc, ChatsState>(
                builder: (context, state) {
                  final conversation = state.conversation;
                  if (conversation == null) return const SizedBox.shrink();
                  return _RequestSummaryCard(conversation: conversation);
                },
              ),
              Expanded(
                child: BlocBuilder<ChatsBloc, ChatsState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.messages.length != _lastMessageCount &&
                        state.shouldScrollToBottom) {
                      _lastMessageCount = state.messages.length;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _scrollToBottom(animated: true);
                      });
                    }
                    return ListView.builder(
                      controller: _messagesScrollController,
                      reverse: false,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.messages.length +
                          (state.hasMoreHistory ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (state.hasMoreHistory && index == 0) {
                          return Center(
                            child: TextButton(
                              onPressed: state.isLoadingOlder
                                  ? null
                                  : _loadOlderMessages,
                              child: state.isLoadingOlder
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(context.l10n.chat_load_older_messages),
                            ),
                          );
                        }
                        final messageIndex =
                            state.hasMoreHistory ? index - 1 : index;
                        final m = state.messages[messageIndex];
                        final align = m.isMine
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart;
                        final bg = m.isMine
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade200;
                        final fg = m.isMine ? Colors.white : Colors.black87;
                        final crossAxis = m.isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start;
                        return Align(
                          alignment: align,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: crossAxis,
                              children: [
                                Text(m.text, style: TextStyle(color: fg)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('hh:mm a').format(m.sentAt),
                                  style: TextStyle(
                                    color: fg.withValues(alpha: 0.75),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: BlocBuilder<ChatsBloc, ChatsState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) {
                              final text = _controller.text.trim();
                              if (text.isEmpty || state.isSending) return;
                              context
                                  .read<ChatsBloc>()
                                  .add(SendChatMessageEvent(text));
                            },
                            decoration: InputDecoration(
                              hintText: context.l10n.chat_type_message,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: state.isSending
                              ? null
                              : () {
                                  final text = _controller.text.trim();
                                  if (text.isEmpty) return;
                                  context
                                      .read<ChatsBloc>()
                                      .add(SendChatMessageEvent(text));
                                },
                          icon: state.isSending
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  final ConversationModel conversation;

  const _RequestSummaryCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _summaryRow(
        context,
        context.l10n.chat_request,
        conversation.requestReadableId ?? conversation.requestId ?? '-',
      ),
      if (conversation.requestType?.isNotEmpty ?? false)
        _summaryRow(context, context.l10n.chat_type, conversation.requestType!),
      if (conversation.requestStatus?.isNotEmpty ?? false)
        _summaryRow(
          context,
          context.l10n.chat_status,
          conversation.requestStatus!,
        ),
      if (conversation.customerName?.isNotEmpty ?? false)
        _summaryRow(
          context,
          context.l10n.chat_customer,
          conversation.customerName!,
        ),
      if (conversation.customerPhone?.isNotEmpty ?? false)
        _summaryRow(
          context,
          context.l10n.chat_phone,
          conversation.customerPhone!,
        ),
      if (conversation.requestTotalPrice != null)
        _summaryRow(
          context,
          context.l10n.chat_price,
          conversation.requestTotalPrice.toString(),
        ),
    ];

    final requestLabel = conversation.requestReadableId ??
        conversation.requestId ??
        context.l10n.chat_request;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: const Icon(Icons.request_page_outlined),
          title: Text(
            requestLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(context.l10n.chat_request),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.labelMedium),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
