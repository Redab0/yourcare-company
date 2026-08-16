import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/data/repositories/upholstery/upholstery_pricing_repository.dart';

class GetUpholsteryPricingConfigUseCase {
  final UpholsteryPricingRepository _repository;

  GetUpholsteryPricingConfigUseCase(this._repository);

  Future<
      ({
        List<UpholsteryType> types,
        List<UpholsteryPricingGroup> pricing,
      })> call() async {
    final results = await Future.wait([
      _repository.getTypes(),
      _repository.getPackages(),
    ]);
    return (
      types: results[0] as List<UpholsteryType>,
      pricing: results[1] as List<UpholsteryPricingGroup>,
    );
  }
}
