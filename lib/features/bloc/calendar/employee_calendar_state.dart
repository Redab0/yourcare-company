import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/calendar/employee_calendar_response.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:equatable/equatable.dart';

class EmployeeCalendarState extends Equatable {
  final EmployeeCalendarResponse? data;
  final List<User> users;
  final List<TeamModel> teams;
  final bool isLoading;
  final bool isLoadingFilters;
  final String? error;

  const EmployeeCalendarState({
    this.data,
    this.users = const [],
    this.teams = const [],
    this.isLoading = false,
    this.isLoadingFilters = false,
    this.error,
  });

  EmployeeCalendarState copyWith({
    EmployeeCalendarResponse? data,
    List<User>? users,
    List<TeamModel>? teams,
    bool? isLoading,
    bool? isLoadingFilters,
    String? error,
  }) {
    return EmployeeCalendarState(
      data: data ?? this.data,
      users: users ?? this.users,
      teams: teams ?? this.teams,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFilters: isLoadingFilters ?? this.isLoadingFilters,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [data, users, teams, isLoading, isLoadingFilters, error];
}

class EmployeeCalendarInitial extends EmployeeCalendarState {}
