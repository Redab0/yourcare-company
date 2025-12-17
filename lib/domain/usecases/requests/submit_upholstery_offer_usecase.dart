import 'package:cleaning_service_driver/data/models/requests/business_offer.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer_response.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';

class SubmitUpholsteryOfferUseCase {
  final RequestsRepository requestsRepository;

  SubmitUpholsteryOfferUseCase(this.requestsRepository);

  Future<BusinessOfferResponse> call(BusinessOffer offer) async {
    try {
      return await requestsRepository.submitUpholsteryOffer(offer);
    } catch (e) {
      throw (Exception('Submitting Bid Failed ${e.toString()}'));
    }
  }
}
