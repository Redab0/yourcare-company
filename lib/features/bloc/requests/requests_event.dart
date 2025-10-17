import 'package:equatable/equatable.dart';

abstract class RequestsEvent extends Equatable {
  const RequestsEvent();

  @override
  List<Object> get props => [];
}

/// Load page #1 (or refresh)
class FetchFirstPageRequests extends RequestsEvent {}

/// Load the next page, if any
class FetchNextPageRequests extends RequestsEvent {}

/// Load page #1 (or refresh)
class FetchExclusivesFirstPageRequests extends RequestsEvent {}

/// Load the next page, if any
class FetchExclusivesNextPageRequests extends RequestsEvent {}
