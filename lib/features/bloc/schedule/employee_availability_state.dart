import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:equatable/equatable.dart';

class EmployeeAvailabilityState extends Equatable {
  final List<CleanerAvailabilitySlot> slots;
  final List<User> employees;
  final bool isLoading;
  final String? error;

  const EmployeeAvailabilityState({
    this.slots = const [],
    this.employees = const [],
    this.isLoading = false,
    this.error,
  });

  EmployeeAvailabilityState copyWith({
    List<CleanerAvailabilitySlot>? slots,
    List<User>? employees,
    bool? isLoading,
    String? error,
  }) {
    return EmployeeAvailabilityState(
      slots: slots ?? this.slots,
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [slots, employees, isLoading, error];
}

class EmployeeAvailabilityInitial extends EmployeeAvailabilityState {}
