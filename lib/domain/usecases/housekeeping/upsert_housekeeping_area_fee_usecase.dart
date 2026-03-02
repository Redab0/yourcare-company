import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/repositories/housekeeping/housekeeping_pricing_repository.dart';

class UpsertHousekeepingAreaFeeUseCase {
  final HousekeepingPricingRepository _repository;

  UpsertHousekeepingAreaFeeUseCase(this._repository);

  Future<void> call(HousekeepingAreaFeeRequest request) async {
    try {
      await _repository.upsertAreaFee(request);
    } catch (e) {
      throw Exception('Updating area fee failed ${e.toString()}');
    }
  }
}
