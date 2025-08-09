import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchHomeDataEvent extends HomeEvent {
  const FetchHomeDataEvent();

  @override
  List<Object> get props => [];
}

class FetchUserDetails extends HomeEvent {
  final String userId;

  const FetchUserDetails(this.userId);
  @override
  List<Object> get props => [];
}
