import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/repositories/housekeeping/housekeeping_pricing_repository.dart';

class GetHousekeepingPricingUseCase {
  final HousekeepingPricingRepository _repository;

  GetHousekeepingPricingUseCase(this._repository);

  Future<HousekeepingPricing?> call() async {
    try {
      return await _repository.getHousekeepingPricing();
    } catch (e) {
      throw Exception('Getting housekeeping pricing failed ${e.toString()}');
    }
  }
}
