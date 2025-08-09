import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer_response.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/services/requests/requests_service.dart';

class RequestsRepository {
  final RequestsService _requestsService;

  RequestsRepository(this._requestsService);

  Future<PaginatedData<CleaningRequest>> getRequests(
      int page, int limit) async {
    final response = await _requestsService.getAvailableRequests(
      page,
      limit,
    );

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<BusinessOfferResponse> submitOffer(BusinessOffer offer) async {
    final response = await _requestsService.submitOffer(offer);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> obtainHouseKeepingRequest(
      {required String id, AcceptHouseKeepingModel? model}) async {
    final response =
        await _requestsService.obtainHouseKeepingRequest(id, model);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }
}
