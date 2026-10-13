import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'laundry_service.g.dart';

@RestApi()
abstract class LaundryService {
  factory LaundryService(Dio dio, {String baseUrl}) = _LaundryService;

  @GET('/business/my-business/laundry-settings')
  Future<ApiResponse<ResponsePayload<LaundrySettings>>> getSettings();

  @PATCH('/business/my-business/laundry-settings')
  Future<ApiResponse<ResponsePayload<LaundrySettings>>> updateSettings(
      @Body() LaundrySettingsRequest body);

  @GET('/business/my-business/laundry-services')
  Future<ApiResponse<ResponsePayload<List<LaundryServiceDefinition>>>>
      getServices();

  @GET('/business/my-business/laundry-categories')
  Future<ApiResponse<ResponsePayload<List<LaundryCategory>>>> getCategories();

  @GET('/business/my-business/laundry-catalog')
  Future<ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>> getCatalog(
      {@CancelRequest() CancelToken? cancelToken});

  @PATCH('/business/my-business/laundry-catalog/prices')
  Future<ApiResponse<ResponsePayload<List<LaundryCatalogItem>>>> updatePrices(
      @Body() LaundryBulkPricesRequest body);

  @PATCH('/business/my-business/laundry-products/{productId}')
  Future<ApiResponse<ResponsePayload<LaundryCatalogItem>>> configureProduct(
      @Path('productId') String productId, @Body() LaundryProductConfig body);

  @POST('/business/my-business/laundry-catalog')
  Future<ApiResponse<ResponsePayload<LaundryCatalogItem>>> createItem(
      @Body() LaundryCatalogMutation body);

  @PATCH('/business/my-business/laundry-catalog/{itemId}')
  Future<ApiResponse<ResponsePayload<LaundryCatalogItem>>> updateItem(
      @Path('itemId') String itemId, @Body() LaundryCatalogMutation body);

  @DELETE('/business/my-business/laundry-catalog/{itemId}')
  Future<ApiResponse<ResponsePayload<dynamic>>> deactivateItem(
      @Path('itemId') String itemId);

  @GET('/requests/laundry/{id}')
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> getOrder(
      @Path('id') String id);

  @PATCH('/requests/laundry/{id}/status')
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> updateStatus(
      @Path('id') String id, @Body() LaundryStatusRequest body);

  @POST('/requests/laundry/{id}/invoice')
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> saveInvoice(
      @Path('id') String id, @Body() LaundryInvoiceRequest body);

  @POST('/requests/laundry/{id}/invoice/send')
  Future<ApiResponse<ResponsePayload<LaundryHistory>>> sendInvoice(
      @Path('id') String id, @Body() LaundryInvoiceSendRequest body);
}
