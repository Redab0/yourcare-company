import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:equatable/equatable.dart';

const _notProvided = Object();

class CarWashState extends Equatable {
  final bool isLoading;
  final bool isSavingPackage;
  final bool isSavingPricing;
  final bool isSavingAreaFee;
  final bool isSavingWorkingHours;
  final String? error;
  final String? successMessage;
  final List<CarWashVehicleType> vehicleTypes;
  final List<CarWashPackage> packages;
  final List<CarWashVehiclePackageAssignment> assignments;
  final List<AreaResponse> areas;
  final Map<String, double> areaFees;
  final List<CarWashWorkingHour> workingHours;

  const CarWashState({
    this.isLoading = false,
    this.isSavingPackage = false,
    this.isSavingPricing = false,
    this.isSavingAreaFee = false,
    this.isSavingWorkingHours = false,
    this.error,
    this.successMessage,
    this.vehicleTypes = const [],
    this.packages = const [],
    this.assignments = const [],
    this.areas = const [],
    this.areaFees = const {},
    this.workingHours = const [],
  });

  CarWashState copyWith({
    bool? isLoading,
    bool? isSavingPackage,
    bool? isSavingPricing,
    bool? isSavingAreaFee,
    bool? isSavingWorkingHours,
    Object? error = _notProvided,
    Object? successMessage = _notProvided,
    List<CarWashVehicleType>? vehicleTypes,
    List<CarWashPackage>? packages,
    List<CarWashVehiclePackageAssignment>? assignments,
    List<AreaResponse>? areas,
    Map<String, double>? areaFees,
    List<CarWashWorkingHour>? workingHours,
  }) {
    return CarWashState(
      isLoading: isLoading ?? this.isLoading,
      isSavingPackage: isSavingPackage ?? this.isSavingPackage,
      isSavingPricing: isSavingPricing ?? this.isSavingPricing,
      isSavingAreaFee: isSavingAreaFee ?? this.isSavingAreaFee,
      isSavingWorkingHours: isSavingWorkingHours ?? this.isSavingWorkingHours,
      error: identical(error, _notProvided) ? this.error : error as String?,
      successMessage: identical(successMessage, _notProvided)
          ? this.successMessage
          : successMessage as String?,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      packages: packages ?? this.packages,
      assignments: assignments ?? this.assignments,
      areas: areas ?? this.areas,
      areaFees: areaFees ?? this.areaFees,
      workingHours: workingHours ?? this.workingHours,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSavingPackage,
        isSavingPricing,
        isSavingAreaFee,
        isSavingWorkingHours,
        error,
        successMessage,
        vehicleTypes,
        packages,
        assignments,
        areas,
        areaFees,
        workingHours,
      ];
}

class CarWashInitial extends CarWashState {
  const CarWashInitial();
}
