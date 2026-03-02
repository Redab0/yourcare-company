import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:equatable/equatable.dart';

abstract class EmployeeAvailabilityEvent extends Equatable {
  const EmployeeAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailabilityData extends EmployeeAvailabilityEvent {
  const LoadAvailabilityData();
}

class CreateAvailabilitySlot extends EmployeeAvailabilityEvent {
  final CleanerAvailabilityRequest request;

  const CreateAvailabilitySlot(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateAvailabilitySlot extends EmployeeAvailabilityEvent {
  final String id;
  final CleanerAvailabilityRequest request;

  const UpdateAvailabilitySlot(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}

class DeleteAvailabilitySlot extends EmployeeAvailabilityEvent {
  final String id;

  const DeleteAvailabilitySlot(this.id);

  @override
  List<Object?> get props => [id];
}
