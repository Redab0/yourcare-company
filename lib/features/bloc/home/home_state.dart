import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeFailure extends HomeState {}

class HomeDataFetched extends HomeState {
  const HomeDataFetched();

  @override
  List<Object> get props => [];
}

class UserFetched extends HomeState {
  final User user;
  const UserFetched(this.user);
  @override
  List<Object> get props => [user];
}
