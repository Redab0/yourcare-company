import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final LoginCredentials loginCredentials;

  const LoginEvent({
    required this.loginCredentials,
  });

  @override
  List<Object> get props => [loginCredentials];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}
