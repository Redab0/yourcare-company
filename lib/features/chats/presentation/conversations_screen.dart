import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/domain/usecases/chats/get_conversations_usecase.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chat_launcher_cubit.dart';
import 'package:cleaning_service_driver/features/chats/presentation/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  static const _pageSize = 50;

  final List<ConversationModel> _conversations = [];
  int _page = 1;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<List<ConversationModel>> _loadPage(int page) {
    return sl<GetConversationsUseCase>().call(page: page, limit: _pageSize);
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingInitial = true;
      _error = null;
    });
    try {
      final items = await _loadPage(1);
      if (!mounted) return;
      setState(() {
        _page = 1;
        _conversations
          ..clear()
          ..addAll(items);
        _hasMore = items.length == _pageSize;
        _isLoadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final items = await _loadPage(1);
      if (!mounted) return;
      setState(() {
        _page = 1;
        _conversations
          ..clear()
          ..addAll(items);
        _hasMore = items.length == _pageSize;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final items = await _loadPage(nextPage);
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _mergeConversations(items);
        _hasMore = items.length == _pageSize;
        _error = null;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingMore = false;
      });
    }
  }

  void _mergeConversations(List<ConversationModel> items) {
    final byId = <String, ConversationModel>{
      for (final conversation in _conversations) conversation.id: conversation,
    };
    for (final item in items) {
      byId[item.id] = item;
    }
    _conversations
      ..clear()
      ..addAll(byId.values);
  }

  Future<void> _openConversation(ConversationModel conversation) async {
    final launcher = sl<ChatLauncherCubit>();
    final hasLastMessage = conversation.hasLastMessage ||
        launcher.state.conversationPreviews.containsKey(conversation.id);
    launcher.setActiveChat(
      conversationId: conversation.id,
      requestId: conversation.requestId,
      businessId: conversation.businessId,
      hasLastMessage: hasLastMessage,
    );
    launcher.clearConversationUnread(conversation.id);
    launcher.dismissFab();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          shouldLoadHistory: hasLastMessage,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  List<ConversationModel> _sortedConversations(
    List<ConversationModel> conversations,
    Map<String, ChatConversationPreview> livePreviews,
  ) {
    final sorted = List<ConversationModel>.of(conversations);
    sorted.sort((a, b) {
      final aTime = _effectivePreviewTime(a, livePreviews);
      final bTime = _effectivePreviewTime(b, livePreviews);
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  DateTime? _effectivePreviewTime(
    ConversationModel conversation,
    Map<String, ChatConversationPreview> livePreviews,
  ) {
    final live = livePreviews[conversation.id];
    if (_shouldUseLivePreview(conversation, live)) return live!.sentAt;
    return conversation.lastMessageAt;
  }

  String _effectivePreviewText(
    BuildContext context,
    ConversationModel conversation,
    Map<String, ChatConversationPreview> livePreviews,
  ) {
    final live = livePreviews[conversation.id];
    if (_shouldUseLivePreview(conversation, live)) return live!.text;
    final lastMessage = conversation.lastMessage?.trim();
    if (lastMessage != null && lastMessage.isNotEmpty) return lastMessage;
    return context.l10n.chat_no_messages;
  }

  bool _shouldUseLivePreview(
    ConversationModel conversation,
    ChatConversationPreview? live,
  ) {
    if (live == null) return false;
    final apiTime = conversation.lastMessageAt;
    return apiTime == null || !live.sentAt.isBefore(apiTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chat_fab_title)),
      body: BlocBuilder<ChatLauncherCubit, ChatLauncherState>(
        builder: (context, chatState) {
          if (_isLoadingInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          final conversations = _sortedConversations(
            _conversations,
            chatState.conversationPreviews,
          );
          if (conversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  Center(
                    child: Text(_error ?? context.l10n.chat_no_conversations),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: conversations.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == conversations.length) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: _isLoadingMore
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: _loadMore,
                              child:
                                  Text(context.l10n.chat_load_older_messages),
                            ),
                    ),
                  );
                }
                final c = conversations[index];
                final hasUnread =
                    chatState.unreadConversationIds.contains(c.id);
                final subtitle = _effectivePreviewText(
                  context,
                  c,
                  chatState.conversationPreviews,
                );
                final dt = _effectivePreviewTime(
                  c,
                  chatState.conversationPreviews,
                );
                final trailing = dt == null
                    ? null
                    : Text(
                        DateFormat('MM/dd hh:mm a').format(dt.toLocal()),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                return ListTile(
                  leading: _ChatLeadingIcon(hasUnread: hasUnread),
                  title: Row(
                    children: [
                      Expanded(child: Text('#${c.requestId ?? c.id}')),
                      if (c.isClosed)
                        Chip(
                          label: Text(context.l10n.chat_closed_status),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: trailing,
                  onTap: () => _openConversation(c),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatLeadingIcon extends StatelessWidget {
  final bool hasUnread;

  const _ChatLeadingIcon({required this.hasUnread});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const CircleAvatar(
          child: Icon(Icons.chat_bubble_outline),
        ),
        if (hasUnread)
          PositionedDirectional(
            top: -1,
            end: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
