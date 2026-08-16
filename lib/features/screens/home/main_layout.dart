import 'dart:async';

import 'package:cleaning_service_driver/components/custome_bottom_nav.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/chats/conversation_model.dart';
import 'package:cleaning_service_driver/domain/usecases/chats/get_conversations_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/chats/get_latest_conversation_usecase.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chat_launcher_cubit.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_socket_service.dart';
import 'package:cleaning_service_driver/features/chats/presentation/conversations_screen.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget? child;
  final String currentPath;

  const MainLayout({
    super.key,
    this.child,
    required this.currentPath,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _checkingLatestChat = false;
  StreamSubscription? _chatMessageSub;
  StreamSubscription? _chatConversationSub;
  StreamSubscription<String>? _chatStatusSub;
  bool _chatSocketWasUnavailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _startChatListeners();
    _preloadCompanyProfile();
    _bootstrapActiveChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _chatMessageSub?.cancel();
    _chatConversationSub?.cancel();
    _chatStatusSub?.cancel();
    super.dispose();
  }

  late final WidgetsBindingObserver _lifecycleObserver = _MainLayoutLifecycle(
    onResumed: () {
      _preloadCompanyProfile(force: true);
      unawaited(_bootstrapActiveChat(force: true));
    },
  );

  void _preloadCompanyProfile({bool force = false}) {
    unawaited(sl<CompanyProfileCubit>().preload(force: force));
  }

  void _startChatListeners() {
    final socket = sl<ChatSocketService>();
    unawaited(socket.connect());
    _chatStatusSub = socket.statusStream.listen((status) {
      if (status == 'disconnected' || status == 'error') {
        _chatSocketWasUnavailable = true;
        return;
      }
      if (status == 'connected' && _chatSocketWasUnavailable) {
        _chatSocketWasUnavailable = false;
        unawaited(_bootstrapActiveChat(force: true));
      }
    });
    _chatMessageSub = socket.messagesStream.listen((message) {
      final launcher = sl<ChatLauncherCubit>();
      final conversationId = message.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        launcher.updateConversationPreview(
          conversationId: conversationId,
          text: message.text,
          sentAt: message.sentAt,
        );
      }
      final isSameOpenConversation = launcher.state.isChatWindowOpen &&
          conversationId != null &&
          conversationId == launcher.state.openConversationId;
      if (!message.isMine &&
          conversationId != null &&
          conversationId.isNotEmpty &&
          !isSameOpenConversation) {
        launcher.markConversationUnread(conversationId);
        launcher.setActiveChat(
          conversationId: conversationId,
          requestId: launcher.state.conversationId == conversationId
              ? launcher.state.requestId
              : null,
          businessId: launcher.state.conversationId == conversationId
              ? launcher.state.businessId
              : null,
          hasLastMessage: true,
        );
      }
      if (conversationId == null || conversationId.isEmpty) {
        if (launcher.state.isChatWindowOpen) return;
        unawaited(_bootstrapActiveChat(force: true));
      }
    });
    _chatConversationSub = socket.conversationStream.listen((conversation) {
      final launcher = sl<ChatLauncherCubit>();
      if (conversation.isClosed &&
          conversation.id == launcher.state.conversationId) {
        if (launcher.state.openConversationId == conversation.id) return;
        if (launcher.state.isChatWindowOpen) {
          launcher.clearActiveChat();
        } else {
          launcher.clear();
        }
        unawaited(_bootstrapActiveChat(force: true));
        return;
      }
      if (!conversation.isClosed && conversation.hasLastMessage) {
        if (conversation.lastMessageAt != null) {
          launcher.updateConversationPreview(
            conversationId: conversation.id,
            text: conversation.lastMessage ?? '',
            sentAt: conversation.lastMessageAt!,
          );
        }
        if (!launcher.state.isChatWindowOpen) {
          launcher.setActiveChat(
            conversationId: conversation.id,
            requestId: conversation.requestId,
            businessId: conversation.businessId,
            hasLastMessage: true,
          );
        }
      }
    });
  }

  Future<void> _bootstrapActiveChat({bool force = false}) async {
    if (_checkingLatestChat) return;
    _checkingLatestChat = true;
    final launcher = sl<ChatLauncherCubit>();
    try {
      if (launcher.state.hasActiveChat && !force) {
        final conversations = await sl<GetConversationsUseCase>().call();
        if (!mounted) return;
        ConversationModel? activeConversation;
        for (final conversation in conversations) {
          if (conversation.id == launcher.state.conversationId) {
            activeConversation = conversation;
            break;
          }
        }
        if (activeConversation != null && !activeConversation.isClosed) {
          return;
        }
        if (launcher.state.isChatWindowOpen) {
          launcher.clearActiveChat();
        } else {
          launcher.clear();
        }
      }

      final latest = await sl<GetLatestConversationUseCase>().call();
      if (!mounted) return;
      if (latest == null) {
        if (force) {
          if (launcher.state.isChatWindowOpen) {
            launcher.clearActiveChat();
          } else {
            launcher.clear();
          }
        }
        return;
      }
      if (latest.id.isEmpty) return;
      if (_isDismissedWithoutNewerMessage(launcher, latest)) {
        return;
      }

      launcher.setActiveChat(
        conversationId: latest.id,
        requestId: latest.requestId,
        businessId: latest.businessId,
        hasLastMessage: latest.hasLastMessage,
      );
    } catch (_) {
    } finally {
      _checkingLatestChat = false;
    }
  }

  bool _isDismissedWithoutNewerMessage(
    ChatLauncherCubit launcher,
    ConversationModel latest,
  ) {
    if (latest.id != launcher.state.dismissedConversationId) return false;
    final dismissedAt = launcher.state.dismissedAt;
    final lastMessageAt = latest.lastMessageAt;
    if (dismissedAt == null || lastMessageAt == null) return true;
    return !lastMessageAt.isAfter(dismissedAt);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = AppLocalizations.of(context)?.localeName == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Builder(
        builder: (context) {
          final items = <NavItem>[
            NavItem(
              label: context.l10n.dashboard,
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              path: '/home',
            ),
            NavItem(
              label: context.l10n.profile,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              path: '/user-profile',
            ),
          ];

          var currentIndex =
              items.indexWhere((i) => widget.currentPath.startsWith(i.path));
          if (currentIndex < 0) currentIndex = 0;

          return ValueListenableBuilder<bool>(
            valueListenable: BusinessShowcaseInteractionLock.listenable,
            builder: (context, interactionLocked, _) => PopScope(
              canPop: !interactionLocked,
              child: Scaffold(
                body: AbsorbPointer(
                  absorbing: interactionLocked,
                  child: widget.child,
                ),
                floatingActionButton: AbsorbPointer(
                  absorbing: interactionLocked,
                  child: BlocBuilder<ChatLauncherCubit, ChatLauncherState>(
                    builder: (context, chatState) {
                      if (!chatState.hasActiveChat ||
                          chatState.isChatWindowOpen ||
                          (chatState.conversationId?.isEmpty ?? true)) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'dismiss_chat_fab',
                            onPressed: sl<ChatLauncherCubit>().dismissFab,
                            child: const Icon(Icons.close),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.extended(
                            heroTag: 'chat_fab',
                            onPressed: () async {
                              sl<ChatLauncherCubit>().dismissFab();
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ConversationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(context.l10n.chat_fab_title),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                bottomNavigationBar: AbsorbPointer(
                  absorbing: interactionLocked,
                  child: CustomBottomNav(
                    items: items,
                    currentIndex: currentIndex,
                    onTap: (i) => context.go(items[i].path),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MainLayoutLifecycle with WidgetsBindingObserver {
  final VoidCallback onResumed;

  _MainLayoutLifecycle({required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
