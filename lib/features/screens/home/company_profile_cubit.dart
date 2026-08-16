import 'dart:developer' as developer;

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
  Future<void>? _preloadFuture;

  CompanyProfileCubit(this._getBusinessProfileUseCase)
      : super(const CompanyProfileState());

  Future<void> preload({bool force = false}) async {
    if (state.isLoading && _preloadFuture != null) return _preloadFuture;
    if (_hasLoaded && !force) return;
    _preloadFuture = _loadProfile();
    await _preloadFuture;
    _preloadFuture = null;
  }

  Future<void> _loadProfile() async {
    emit(CompanyProfileState(profile: state.profile, isLoading: true));
    try {
      final profile = await _getBusinessProfileUseCase.call();
      _hasLoaded = true;
      emit(CompanyProfileState(profile: profile));
    } catch (e, s) {
      developer.log(
        'Company profile preload failed: $e',
        name: 'CompanyProfileCubit',
        error: e,
        stackTrace: s,
      );
      emit(CompanyProfileState(profile: state.profile));
    }
  }

  void setProfile(BusinessProfileModel profile) {
    _hasLoaded = true;
    emit(CompanyProfileState(profile: profile));
  }
}
