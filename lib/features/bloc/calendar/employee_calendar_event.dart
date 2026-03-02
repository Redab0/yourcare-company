import 'package:equatable/equatable.dart';

abstract class EmployeeCalendarEvent extends Equatable {
  const EmployeeCalendarEvent();

  @override
  List<Object?> get props => [];
}

class FetchEmployeeCalendar extends EmployeeCalendarEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? employeeId;
  final String? teamId;
  final String? requestType;
  final String? requestStatus;

  const FetchEmployeeCalendar({
    required this.startDate,
    required this.endDate,
    this.employeeId,
    this.teamId,
    this.requestType,
    this.requestStatus,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, employeeId, teamId, requestType, requestStatus];
}

class LoadEmployeeCalendarFilters extends EmployeeCalendarEvent {
  const LoadEmployeeCalendarFilters();
}
