import 'package:cleaning_service_driver/data/models/profile/company_services.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_company_services_usecase.dart';
import 'package:cleaning_service_driver/features/screens/home/business_home_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/secure_storage_service.dart';

class CompanyServicesState {
  final CompanyServices? context;
  final bool isLoading;
  final bool failed;

  const CompanyServicesState({
    this.context,
    this.isLoading = false,
    this.failed = false,
  });

  Set<CompanyProvidedService>? get companyServices {
    final values = context?.services;
    if (values == null) return null;
    return values
        .map(CompanyProvidedService.fromApiValue)
        .whereType<CompanyProvidedService>()
        .toSet();
  }
}

class CompanyServicesCubit extends Cubit<CompanyServicesState> {
  final GetCompanyServicesUseCase _getCompanyServicesUseCase;
  bool _hasLoaded = false;
  int _generation = 0;
  Future<void>? _preloadFuture;

  CompanyServicesCubit(this._getCompanyServicesUseCase)
      : super(const CompanyServicesState());

  Future<void> preload({bool force = false}) async {
    if (state.isLoading && _preloadFuture != null) return _preloadFuture;
    if (_hasLoaded && !force) return;
    final future = _loadContext();
    _preloadFuture = future;
    await future;
    if (identical(_preloadFuture, future)) _preloadFuture = null;
  }

  Future<void> _loadContext() async {
    final generation = _generation;
    final account = SecureStorageService().authGeneration;
    emit(CompanyServicesState(context: state.context, isLoading: true));
    try {
      final context = await _getCompanyServicesUseCase
          .call()
          .timeout(const Duration(seconds: 15));
      if (generation != _generation ||
          account != SecureStorageService().authGeneration ||
          isClosed) {
        return;
      }
      _hasLoaded = true;
      emit(CompanyServicesState(context: context));
    } catch (_) {
      if (generation != _generation ||
          account != SecureStorageService().authGeneration ||
          isClosed) {
        return;
      }

      emit(CompanyServicesState(context: state.context, failed: true));
    }
  }

  void clear() {
    _generation++;
    _hasLoaded = false;
    _preloadFuture = null;
    if (!isClosed) emit(const CompanyServicesState());
  }
}
