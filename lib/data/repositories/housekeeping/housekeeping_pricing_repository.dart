import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/services/housekeeping/housekeeping_pricing_service.dart';

class HousekeepingPricingRepository {
  final HousekeepingPricingService _service;

  HousekeepingPricingRepository(this._service);

  Future<HousekeepingPricing?> getHousekeepingPricing() async {
    final response = await _service.getHousekeepingPricing();
    if (response.success) {
      return response.data?.data;
    } else {
      throw Exception(response.message);
    }
  }

  Future<HousekeepingPricing> upsertHousekeepingPricing(
      HousekeepingPricingRequest request) async {
    final response = await _service.upsertHousekeepingPricing(request);
    if (response.success && response.data != null) {
      return response.data!.data ??
          HousekeepingPricing(
            areaFees: request.areaFees,
            isActive: request.isActive,
            cleaningProductsPrice: request.cleaningProductsPrice,
            singlePricingModel: request.singlePricingModel,
            multiplePricingModel: request.multiplePricingModel,
          );
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> upsertAreaFee(HousekeepingAreaFeeRequest request) async {
    final response = await _service.upsertAreaFee(request);
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
