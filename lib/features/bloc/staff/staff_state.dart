import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:equatable/equatable.dart';

class StaffState extends Equatable {
  final List<User> all;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  const StaffState({
    this.all = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  StaffState copyWith({
    List<User>? all,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return StaffState(
      all: all ?? this.all,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [all, hasMore, isLoading, error];
}

class StaffInitial extends StaffState {}

class StaffFailure extends StaffState {
  final String message;

  const StaffFailure(this.message);

  @override
  List<Object> get props => [message];
}

class StaffUsersFetched extends StaffState {
  final List<User> user;
  const StaffUsersFetched(this.user);
  @override
  List<Object?> get props => [user];
}

class TeamsFetched extends StaffState {
  final List<TeamModel> teamModels;
  const TeamsFetched(this.teamModels);
  @override
  List<Object?> get props => [teamModels];
}
