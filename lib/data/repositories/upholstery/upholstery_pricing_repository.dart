import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/data/services/upholstery/upholstery_pricing_service.dart';

class UpholsteryPricingRepository {
  final UpholsteryPricingService _service;

  UpholsteryPricingRepository(this._service);

  Future<List<UpholsteryType>> getTypes() async {
    final localizedTypes = await Future.wait([
      _getTypesForLanguage('en'),
      _getTypesForLanguage('ar'),
    ]);
    final english = localizedTypes[0];
    final arabic = localizedTypes[1];
    if (english.isEmpty && arabic.isEmpty) {
      throw Exception('No furniture types are available');
    }
    return mergeLocalizedUpholsteryTypes(english, arabic);
  }

  Future<List<UpholsteryType>> _getTypesForLanguage(String languageCode) async {
    final response = await _service.getActiveCategories(languageCode);
    if (!response.success) throw Exception(response.message);

    final categories = response.data?.data ?? const [];
    for (final category in categories) {
      if (category.isUpholsteryCleaning) return category.upholsteryTypes;
    }
    return const [];
  }

  Future<List<UpholsteryPricingGroup>> getPackages() async {
    final response = await _service.getMyUpholsteryPackages();
    if (response.success) return response.data?.data ?? const [];
    throw Exception(response.message);
  }

  Future<BusinessProfileModel?> updatePricing(
    UpholsteryPricingRequest request,
  ) async {
    final response = await _service.updateMyUpholsteryPricing(request);
    if (response.success) return response.data?.data;
    throw Exception(response.message);
  }
}
