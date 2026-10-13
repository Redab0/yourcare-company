import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';

class LaundryRepository {
  final LaundryService _service;
  final Duration catalogTimeout;
  LaundryRepository(this._service,
      {this.catalogTimeout = const Duration(seconds: 30)});

  T _data<T>(ApiResponse<ResponsePayload<T>> response) {
    final value = response.data?.data;
    if (response.success && value != null) return value;
    throw Exception(response.message);
  }

  Future<LaundrySettings> getSettings() async =>
      _data(await _service.getSettings());
  Future<LaundrySettings> updateSettings(LaundrySettingsRequest body) async =>
      _data(await _service.updateSettings(body));

  Future<List<LaundryServiceDefinition>> getServices() async =>
      _data(await _service.getServices());

  Future<List<LaundryCategory>> getCategories() async =>
      _data(await _service.getCategories());

  Future<List<LaundryCatalogItem>> getCatalog() async {
    final cancelToken = CancelToken();
    // Dio's receive timeout is an inactivity timeout, not a deadline for the
    // whole request (including interceptors). Bound this read and cancel it so
    // retry cannot pile another catalog download onto an abandoned request.
    final response =
        await _service.getCatalog(cancelToken: cancelToken).timeout(
      catalogTimeout,
      onTimeout: () {
        cancelToken.cancel('Laundry catalog deadline exceeded');
        throw TimeoutException(
            'Laundry catalog request timed out', catalogTimeout);
      },
    );
    return _data(response);
  }

  Future<List<LaundryCatalogItem>> updatePrices(
          LaundryBulkPricesRequest body) async =>
      _data(await _service.updatePrices(body));

  Future<LaundryCatalogItem> configureProduct(
          String productId, LaundryProductConfig body) async =>
      _data(await _service.configureProduct(productId, body));
  Future<LaundryCatalogItem> saveItem(LaundryCatalogMutation body,
          {String? id}) async =>
      _data(id == null
          ? await _service.createItem(body)
          : await _service.updateItem(id, body));
  Future<void> deactivateItem(String id) async {
    final response = await _service.deactivateItem(id);
    if (!response.success) throw Exception(response.message);
  }

  Future<LaundryHistory> getOrder(String id) async =>
      _data(await _service.getOrder(id));
  Future<LaundryHistory> updateStatus(String id, String status) async =>
      _data(await _service.updateStatus(id, LaundryStatusRequest(status)));
  Future<LaundryHistory> saveInvoice(
          String id, LaundryInvoiceRequest body) async =>
      _data(await _service.saveInvoice(id, body));
  Future<LaundryHistory> sendInvoice(String id,
          {String? expectedRevision}) async =>
      _data(await _service.sendInvoice(
          id, LaundryInvoiceSendRequest(expectedRevision: expectedRevision)));
}
