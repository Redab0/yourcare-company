import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/features/screens/home/business_home_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyProfileState {
  final BusinessProfileModel? profile;
  final bool isLoading;

  const CompanyProfileState({
    this.profile,
    this.isLoading = false,
  });

  Set<CompanyProvidedService>? get companyServices {
    final values = profile?.services;
    if (values == null) return null;
    return values
        .map(CompanyProvidedService.fromApiValue)
        .whereType<CompanyProvidedService>()
        .toSet();
  }
}

class CompanyProfileCubit extends Cubit<CompanyProfileState> {
  final GetBusinessProfileUseCase _getBusinessProfileUseCase;
  bool _hasLoaded = false;
  int _generation = 0;
  Future<void>? _preloadFuture;

  CompanyProfileCubit(this._getBusinessProfileUseCase)
      : super(const CompanyProfileState());

  Future<void> preload({bool force = false}) async {
    if (state.isLoading && _preloadFuture != null) return _preloadFuture;
    if (_hasLoaded && !force) return;
    final future = _loadProfile();
    _preloadFuture = future;
    await future;
    if (identical(_preloadFuture, future)) _preloadFuture = null;
  }

  Future<void> _loadProfile() async {
    final generation = _generation;
    emit(CompanyProfileState(profile: state.profile, isLoading: true));
    try {
      final profile = await _getBusinessProfileUseCase.call();
      if (generation != _generation || isClosed) return;
      _hasLoaded = true;
      emit(CompanyProfileState(profile: profile));
    } catch (_) {
      if (generation != _generation || isClosed) return;

      emit(CompanyProfileState(profile: state.profile));
    }
  }

  void clear() {
    _generation++;
    _hasLoaded = false;
    _preloadFuture = null;
    if (!isClosed) emit(const CompanyProfileState());
  }

  int get generation => _generation;

  void setProfile(BusinessProfileModel profile, {int? expectedGeneration}) {
    if ((expectedGeneration != null && _generation != expectedGeneration) ||
        isClosed) {
      return;
    }
    _generation++;
    _hasLoaded = true;
    emit(CompanyProfileState(profile: profile));
  }
}
