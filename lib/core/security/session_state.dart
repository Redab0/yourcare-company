import '../../data/repositories/notifications/notifications_repository.dart';
import '../di/dependency_injection.dart';
import '../../features/screens/home/company_profile_cubit.dart';
import '../../features/chats/data/chat_socket_service.dart';
import '../../features/chats/data/chat_memory_store.dart';
import '../../features/chats/bloc/chat_launcher_cubit.dart';

/// Called while the secure-storage session lock is held, before another login.
Future<void> clearSessionState() async {
  if (sl.isRegistered<NotificationsRepository>()) {
    sl<NotificationsRepository>().invalidateLocalSession();
  }
  if (sl.isRegistered<CompanyProfileCubit>()) sl<CompanyProfileCubit>().clear();
  if (sl.isRegistered<ChatMemoryStore>()) sl<ChatMemoryStore>().clearAll();
  if (sl.isRegistered<ChatLauncherCubit>()) sl<ChatLauncherCubit>().clear();
  if (sl.isRegistered<ChatSocketService>()) {
    await sl<ChatSocketService>().disconnect();
  }
}
