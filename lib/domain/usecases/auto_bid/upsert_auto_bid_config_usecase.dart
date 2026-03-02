import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_config_repository.dart';

class UpsertAutoBidConfigUseCase {
  final AutoBidConfigRepository repository;

  UpsertAutoBidConfigUseCase(this.repository);

  Future<AutoBidConfig> call(AutoBidConfigRequest request) async {
    try {
      return await repository.upsertAutoBidConfig(request);
    } catch (e) {
      throw Exception('Saving auto bid config failed ${e.toString()}');
    }
  }
}
