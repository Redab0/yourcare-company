import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:cleaning_service_driver/data/services/auto_bid/auto_bid_categories_service.dart';

class AutoBidCategoriesRepository {
  final AutoBidCategoriesService _service;

  AutoBidCategoriesRepository(this._service);

  Future<AutoBidDeepCleaningCategories?> getDeepCleaningCategories(
      String serviceType) async {
    final response = await _service.getAutoBidCategories(serviceType);
    if (response.success) {
      final raw = response.data?.data ?? {};
      return AutoBidDeepCleaningCategories.fromJson(raw);
    } else {
      throw Exception(response.message);
    }
  }

  Future<AutoBidUpholsteryCategories?> getUpholsteryCategories(
      String serviceType) async {
    final response = await _service.getAutoBidCategories(serviceType);
    if (response.success) {
      final raw = response.data?.data ?? {};
      return AutoBidUpholsteryCategories.fromJson(raw);
    } else {
      throw Exception(response.message);
    }
  }
}
