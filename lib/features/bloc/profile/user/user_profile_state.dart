import 'package:equatable/equatable.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends UserProfileState {}

class ProfileUpdated extends UserProfileState {}

class ProfileLoaded extends UserProfileState {}

class ProfileFailure extends UserProfileState {
  final String error;

  const ProfileFailure(this.error);

  @override
  List<Object> get props => [error];
}
