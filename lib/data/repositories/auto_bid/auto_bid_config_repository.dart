import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/data/services/auto_bid/auto_bid_config_service.dart';

class AutoBidConfigRepository {
  final AutoBidConfigService _service;

  AutoBidConfigRepository(this._service);

  Future<AutoBidConfig?> getAutoBidConfig(String serviceType) async {
    final response = await _service.getAutoBidConfig(serviceType);
    if (response.success) {
      return response.data?.data;
    } else {
      throw Exception(response.message);
    }
  }

  Future<AutoBidConfig> upsertAutoBidConfig(
      AutoBidConfigRequest request) async {
    final response = await _service.upsertAutoBidConfig(request);
    if (response.success && response.data != null) {
      return response.data!.data ??
          AutoBidConfig(
            serviceType: request.serviceType,
            isEnabled: request.isEnabled,
            deepCleaningPricing: request.deepCleaningPricing,
            upholsteryPricing: request.upholsteryPricing,
          );
    } else {
      throw Exception(response.message);
    }
  }
}
