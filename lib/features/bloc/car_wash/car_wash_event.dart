import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:equatable/equatable.dart';

abstract class CarWashEvent extends Equatable {
  const CarWashEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarWashConfig extends CarWashEvent {
  const LoadCarWashConfig();
}

class CreateCarWashPackage extends CarWashEvent {
  final CarWashPackageMutationRequest request;

  const CreateCarWashPackage(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateCarWashPackage extends CarWashEvent {
  final String packageId;
  final CarWashPackageMutationRequest request;

  const UpdateCarWashPackage({
    required this.packageId,
    required this.request,
  });

  @override
  List<Object?> get props => [packageId, request];
}

class DeleteCarWashPackage extends CarWashEvent {
  final String packageId;

  const DeleteCarWashPackage(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

class ToggleCarWashPackageAssignment extends CarWashEvent {
  final String vehicleTypeId;
  final String packageId;
  final bool isAssigned;

  const ToggleCarWashPackageAssignment({
    required this.vehicleTypeId,
    required this.packageId,
    required this.isAssigned,
  });

  @override
  List<Object?> get props => [vehicleTypeId, packageId, isAssigned];
}

class SaveCarWashPricing extends CarWashEvent {
  const SaveCarWashPricing();
}

class UpsertCarWashAreaFee extends CarWashEvent {
  final String areaId;
  final double fee;

  const UpsertCarWashAreaFee({required this.areaId, required this.fee});

  @override
  List<Object?> get props => [areaId, fee];
}

class DeleteCarWashAreaFee extends CarWashEvent {
  final String areaId;

  const DeleteCarWashAreaFee(this.areaId);

  @override
  List<Object?> get props => [areaId];
}

class UpdateCarWashWorkingHour extends CarWashEvent {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const UpdateCarWashWorkingHour({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime];
}

class RemoveCarWashWorkingHour extends CarWashEvent {
  final int dayOfWeek;

  const RemoveCarWashWorkingHour({required this.dayOfWeek});

  @override
  List<Object?> get props => [dayOfWeek];
}

class ApplyCarWashWorkingHourToWeek extends CarWashEvent {
  final CarWashWorkingHour hour;

  const ApplyCarWashWorkingHourToWeek({required this.hour});

  @override
  List<Object?> get props => [hour];
}

class SaveCarWashWorkingHours extends CarWashEvent {
  const SaveCarWashWorkingHours();
}
