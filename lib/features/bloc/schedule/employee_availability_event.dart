import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:equatable/equatable.dart';

abstract class EmployeeAvailabilityEvent extends Equatable {
  const EmployeeAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailabilityData extends EmployeeAvailabilityEvent {
  final AvailabilityServiceType serviceType;

  const LoadAvailabilityData(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
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
  final AvailabilityServiceType serviceType;

  const DeleteAvailabilitySlot(this.id, this.serviceType);

  @override
  List<Object?> get props => [id, serviceType];
}

class ReplaceAvailabilityDays extends EmployeeAvailabilityEvent {
  final AvailabilityServiceType serviceType;
  final Map<int, List<CleanerAvailabilityRequest>> scheduleByDay;

  const ReplaceAvailabilityDays({
    required this.serviceType,
    required this.scheduleByDay,
  });

  @override
  List<Object?> get props => [serviceType, scheduleByDay];
}
