import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer.dart';
import 'package:cleaning_service_driver/data/models/requests/business_offer_response.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'requests_service.g.dart';

@RestApi()
abstract class RequestsService {
  factory RequestsService(Dio dio, {String baseUrl}) = _RequestsService;

  @GET("/requests/available")
  Future<ApiResponse<ResponsePayload<PaginatedData<CleaningRequest>>>>
      getAvailableRequests(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET("/company/requests/reorders")
  Future<ApiResponse<ResponsePayload<PaginatedData<CleaningRequest>>>>
      getReorders(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/requests/deep-cleaning/business-offer')
  Future<ApiResponse<ResponsePayload<BusinessOfferResponse>>> submitOffer(
      @Body() BusinessOffer body);

  @POST('/requests/upholstery-cleaning/business-offer')
  Future<ApiResponse<ResponsePayload<BusinessOfferResponse>>>
      submitUpholsteryOffer(@Body() BusinessOffer body);

  @PATCH('/requests/{id}/house-cleaning/accept')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>>
      obtainHouseKeepingRequest(
    @Path('id') String id,
    @Body() AcceptHouseKeepingModel? model,
  );

  @PATCH('/reorders/{id}/accept')
  Future<ApiResponse<ResponsePayload<CleaningRequest>>> acceptReorder(
    @Path('id') String id,
  );
}
