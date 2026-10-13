import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cleaning_service_driver/core/utils/request_action_error.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LaundryCatalogFailure { timeout, unavailable }

class LaundryState {
  final bool loading;
  final bool loadingCatalog;
  final LaundryCatalogFailure? catalogFailure;
  final String? error;
  final List<LaundryCatalogItem> catalog;
  final LaundryHistory? order;
  const LaundryState(
      {this.loading = false,
      this.loadingCatalog = false,
      this.catalogFailure,
      this.error,
      this.catalog = const [],
      this.order});
}

/// One instance per journey, preserving loaded data during mutations and failures.
class LaundryCubit extends Cubit<LaundryState> {
  final LaundryRepository repository;
  LaundryCubit(this.repository, {LaundryHistory? order})
      : super(LaundryState(order: order));

  Future<void> _run(Future<LaundryState> Function() operation) async {
    if (state.loading) return;
    emit(LaundryState(
        loading: true, catalog: state.catalog, order: state.order));
    try {
      final next = await operation();
      if (!isClosed) emit(next);
    } catch (error) {
      if (!isClosed) {
        emit(LaundryState(
            catalog: state.catalog,
            order: state.order,
            error: requestActionErrorMessage(error)));
      }
    }
  }

  Future<void> loadCatalog() async {
    if (state.loading || isClosed) return;
    emit(LaundryState(
        loading: true,
        loadingCatalog: true,
        catalog: state.catalog,
        order: state.order));
    try {
      final catalog = await repository.getCatalog();
      if (!isClosed) emit(LaundryState(catalog: catalog, order: state.order));
    } catch (error) {
      if (isClosed) return;
      final timedOut = error is TimeoutException ||
          error is DioException &&
              (error.error is TimeoutException ||
                  const [
                    DioExceptionType.connectionTimeout,
                    DioExceptionType.receiveTimeout,
                    DioExceptionType.sendTimeout
                  ].contains(error.type));
      emit(LaundryState(
          catalog: state.catalog,
          order: state.order,
          error: requestActionErrorMessage(error),
          catalogFailure: timedOut
              ? LaundryCatalogFailure.timeout
              : LaundryCatalogFailure.unavailable));
    }
  }

  Future<void> saveItem(LaundryCatalogMutation body, {String? id}) =>
      _run(() async {
        final item = await repository.saveItem(body, id: id);
        return LaundryState(catalog: [
          ...state.catalog.where((entry) => entry.id != item.id),
          item
        ], order: state.order);
      });
  Future<void> configureProduct(String productId, LaundryProductConfig body) =>
      _run(() async {
        final item = await repository.configureProduct(productId, body);
        return LaundryState(catalog: [
          for (final existing in state.catalog)
            if (existing.productId == productId) item else existing,
        ], order: state.order);
      });

  /// Merge batch results without refetching the already-loaded catalog.
  void applyUpdatedPrices(List<LaundryCatalogItem> items) {
    final updated = {
      for (final item in items) item.productId ?? item.id: item,
    };
    emit(LaundryState(catalog: [
      for (final item in state.catalog)
        updated[item.productId ?? item.id] ?? item,
    ], order: state.order));
  }

  Future<void> deactivateItem(String id) => _run(() async {
        await repository.deactivateItem(id);
        return LaundryState(
            catalog: await repository.getCatalog(), order: state.order);
      });
  Future<void> refreshOrder() => _run(() async => LaundryState(
      catalog: state.catalog,
      order: await repository.getOrder(state.order!.id!)));
  void updateOrder(LaundryHistory order) =>
      emit(LaundryState(catalog: state.catalog, order: order));
  Future<void> updateStatus(String status) => _run(() async => LaundryState(
      catalog: state.catalog,
      order: await repository.updateStatus(state.order!.id!, status)));
  Future<void> saveInvoice(LaundryInvoiceRequest body) =>
      _run(() async => LaundryState(
          catalog: state.catalog,
          order: await repository.saveInvoice(state.order!.id!, body)));
  Future<void> sendInvoice() => _run(() async => LaundryState(
      catalog: state.catalog,
      order: await repository.sendInvoice(state.order!.id!,
          expectedRevision: state.order!.detail.invoice?.revision)));
}
