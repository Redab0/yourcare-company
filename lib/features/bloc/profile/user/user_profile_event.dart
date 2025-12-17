import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfileEvent extends UserProfileEvent {
  final User user;
  const UpdateProfileEvent(this.user);

  @override
  List<Object> get props => [user];
}

class GetUserEvent extends UserProfileEvent {}
