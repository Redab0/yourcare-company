import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/auth/auth_user.dart';
import 'package:cleaning_service_driver/data/repositories/notifications/notifications_repository.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/login_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/logout_usecase.dart';
import 'package:cleaning_service_driver/features/chats/bloc/chat_launcher_cubit.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_memory_store.dart';
import 'package:cleaning_service_driver/features/chats/data/chat_socket_service.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final loginUseCase = sl<LoginUseCase>();
  final logoutUseCase = sl<LogoutUseCase>();
  final _loader = sl<LoadingController>();
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_logOut);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    _loader.show();
    try {
      final user = await loginUseCase.call(event.loginCredentials);
      try {
        await sl<NotificationsRepository>().initializeAndRegister();
      } catch (_) {}
      _loader.hide();
      emit(Authenticated(
        AuthUser(
          email: user.email ?? "",
          username: user.username ?? "",
          phone: user.phone,
        ),
      ));
    } catch (e) {
      _loader.hide();
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _logOut(LogoutEvent event, Emitter<AuthState> emit) async {
    _loader.show();
    try {
      try {
        await sl<NotificationsRepository>().onLogoutCleanup();
      } catch (_) {}
      try {
        await sl<ChatSocketService>().disconnect();
        sl<ChatMemoryStore>().clearAll();
        sl<ChatLauncherCubit>().clear();
      } catch (_) {}
      await logoutUseCase.call();
      _loader.hide();
      emit(Unauthenticated());
    } catch (e) {
      _loader.hide();
      emit(AuthError(e.toString()));
    }
  }
}
