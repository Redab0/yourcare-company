import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/services/car_wash/car_wash_service.dart';
import 'package:dio/dio.dart';

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
    final response = await _service.createMyCarWashPackage(request.toJson());
    if (!response.success) throw Exception(response.message);
  }

  Future<void> updatePackage(
    String packageId,
    CarWashPackageMutationRequest request,
  ) async {
    final response = await _service.updateMyCarWashPackage(
      packageId,
      request.toJson(),
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
    try {
      final response = await _service.updateMyCarWashPricing(request.toJson());
      if (response.success) return;
      await _retryLegacyPricingKey(request, response.message);
    } on DioException catch (error) {
      if (!_canRetryAssignment(error)) rethrow;
      await _retryLegacyPricingKey(request, error.message ?? '');
    }
  }

  Future<void> upsertAreaFee(CarWashAreaFeeRequest request) async {
    final response = await _service.upsertMyCarWashAreaFee(request.toJson());
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

  Future<void> _retryLegacyPricingKey(
    CarWashPricingAssignmentRequest request,
    String originalMessage,
  ) async {
    final response = await _service.updateMyCarWashPricing(
      request.toJson(useLegacyPackagesKey: true),
    );
    if (!response.success) {
      throw Exception(
        response.message.isEmpty ? originalMessage : response.message,
      );
    }
  }

  bool _canRetryAssignment(DioException error) {
    final status = error.response?.statusCode;
    return status == 400 || status == 422;
  }
}
