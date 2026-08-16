import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:equatable/equatable.dart';

class EmployeeAvailabilityState extends Equatable {
  final List<CleanerAvailabilitySlot> slots;
  final AvailabilityServiceType? serviceType;
  final bool isLoading;
  final String? error;

  const EmployeeAvailabilityState({
    this.slots = const [],
    this.serviceType,
    this.isLoading = false,
    this.error,
  });

  EmployeeAvailabilityState copyWith({
    List<CleanerAvailabilitySlot>? slots,
    AvailabilityServiceType? serviceType,
    bool? isLoading,
    String? error,
  }) {
    return EmployeeAvailabilityState(
      slots: slots ?? this.slots,
      serviceType: serviceType ?? this.serviceType,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [slots, serviceType, isLoading, error];
}

class EmployeeAvailabilityInitial extends EmployeeAvailabilityState {}
