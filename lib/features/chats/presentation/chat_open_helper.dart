import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/domain/usecases/chats/create_conversation_usecase.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chat_launcher_cubit.dart';
import 'package:cleaning_service_driver/features/chats/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

Future<void> openChatForRequest({
  required BuildContext context,
  String? businessId,
  required String requestId,
}) async {
  try {
    final conversation = await sl<CreateConversationUseCase>().call(
      requestId: requestId,
    );

    sl<ChatLauncherCubit>().setActiveChat(
      conversationId: conversation.id,
      requestId: requestId,
      businessId: businessId,
      hasLastMessage: conversation.hasLastMessage,
    );

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.chat_created_successfully),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          shouldLoadHistory: conversation.hasLastMessage,
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    context.showErrorToast(e.toString());
  }
}
