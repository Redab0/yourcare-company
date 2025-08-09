import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();
  @override
  List<Object> get props => [];
}

/// Load page #1 (or refresh)
class FetchFirstPageStaff extends StaffEvent {}

/// Load the next page, if any
class FetchNextPageStaff extends StaffEvent {}

class FetchTeams extends StaffEvent {}
