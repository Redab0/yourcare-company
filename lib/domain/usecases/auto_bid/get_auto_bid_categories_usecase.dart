import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:cleaning_service_driver/data/repositories/auto_bid/auto_bid_categories_repository.dart';

class GetAutoBidCategoriesUseCase {
  final AutoBidCategoriesRepository repository;

  GetAutoBidCategoriesUseCase(this.repository);

  Future<AutoBidDeepCleaningCategories?> getDeepCleaning(
      String serviceType) async {
    try {
      return await repository.getDeepCleaningCategories(serviceType);
    } catch (e) {
      throw Exception('Getting auto bid categories failed ${e.toString()}');
    }
  }

  Future<AutoBidUpholsteryCategories?> getUpholstery(
      String serviceType) async {
    try {
      return await repository.getUpholsteryCategories(serviceType);
    } catch (e) {
      throw Exception('Getting auto bid categories failed ${e.toString()}');
    }
  }
}
