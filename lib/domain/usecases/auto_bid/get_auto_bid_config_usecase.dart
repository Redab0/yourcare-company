import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_config_repository.dart';

class GetAutoBidConfigUseCase {
  final AutoBidConfigRepository repository;

  GetAutoBidConfigUseCase(this.repository);

  Future<AutoBidConfig?> call(String serviceType) async {
    try {
      return await repository.getAutoBidConfig(serviceType);
    } catch (e) {
      throw Exception('Getting auto bid config failed ${e.toString()}');
    }
  }
}
