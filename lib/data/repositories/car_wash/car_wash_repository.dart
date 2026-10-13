import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/services/car_wash/car_wash_service.dart';

class CarWashRepository {
  final CarWashService _service;

  CarWashRepository(this._service);

  Future<CarWashCategoryResponse> getCategories() async {
    final response = await _service.getCarWashCategories();
    if (response.success) {
      return response.data?.data ?? const CarWashCategoryResponse();
    }
    throw Exception(response.message);
  }

  Future<CarWashPackagesConfiguration> getPackagesConfiguration() async {
    final response = await _service.getMyCarWashPackages();
    if (response.success) {
      return CarWashPackagesConfiguration.fromJson(response.data?.data);
    }
    throw Exception(response.message);
  }

  Future<void> createPackage(CarWashPackageMutationRequest request) async {
    final response = await _service.createMyCarWashPackage(request);
    if (!response.success) throw Exception(response.message);
  }

  Future<void> updatePackage(
    String packageId,
    CarWashPackageMutationRequest request,
  ) async {
    final response = await _service.updateMyCarWashPackage(
      packageId,
      request,
    );
    if (!response.success) throw Exception(response.message);
  }

  Future<void> deletePackage(String packageId) async {
    final response = await _service.deleteMyCarWashPackage(packageId);
    if (!response.success) throw Exception(response.message);
  }

  Future<void> updatePricing(
    CarWashPricingAssignmentRequest request,
  ) async {
    final response = await _service.updateMyCarWashPricing(request);
    if (!response.success) throw Exception(response.message);
  }

  Future<void> upsertAreaFee(CarWashAreaFeeRequest request) async {
    final response = await _service.upsertMyCarWashAreaFee(request);
    if (!response.success) throw Exception(response.message);
  }

  Future<void> deleteAreaFee(String areaId) async {
    final response = await _service.deleteMyCarWashAreaFee(areaId);
    if (!response.success) throw Exception(response.message);
  }

  Future<BusinessProfileModel?> updateWorkingHours(
    CarWashWorkingHoursRequest request,
  ) async {
    final response = await _service.updateMyCarWashWorkingHours(request);
    if (response.success) return response.data?.data;
    throw Exception(response.message);
  }
}
