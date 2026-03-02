import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/repositories/housekeeping/housekeeping_pricing_repository.dart';

class UpsertHousekeepingPricingUseCase {
  final HousekeepingPricingRepository _repository;

  UpsertHousekeepingPricingUseCase(this._repository);

  Future<HousekeepingPricing> call(HousekeepingPricingRequest request) async {
    try {
      return await _repository.upsertHousekeepingPricing(request);
    } catch (e) {
      throw Exception('Saving housekeeping pricing failed ${e.toString()}');
    }
  }
}
