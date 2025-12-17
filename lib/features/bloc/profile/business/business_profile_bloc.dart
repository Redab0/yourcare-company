import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_areas_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/update_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/upload_media_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_event.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessProfileBloc
    extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final getProfileUseCase = sl<GetBusinessProfileUseCase>();
  final updateProfileUseCase = sl<UpdateBusinessProfileUseCase>();
  final getAreasUseCase = sl<GetAreasUseCase>();
  final uploadMediaUseCase = sl<UploadMediaUseCase>();
  final _loader = sl<LoadingController>();

  BusinessProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfileEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<GetAreasEvent>(_onGetAreas);
    on<UploadMediaEvent>(_upload);
  }

  FutureOr<void> _onLoadProfileEvent(
      LoadProfileEvent event, Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final profile = await getProfileUseCase.call();
      _loader.hide();
      emit(ProfileLoaded(profile));
    } catch (e) {
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateProfileEvent(
      UpdateProfileEvent event, Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final profile = await updateProfileUseCase(event.model);
      _loader.hide();
      emit(ProfileLoaded(profile));
    } catch (e) {
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onGetAreas(
      GetAreasEvent event, Emitter<BusinessProfileState> emit) async {
    try {
      var areas = await getAreasUseCase.execute();
      emit(AreasLoaded(areas));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _upload(
      UploadMediaEvent event, Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final response = await uploadMediaUseCase.call(event.files);
      _loader.hide();
      emit(MediaUploaded(response));
    } catch (e) {
      _loader.hide();
      emit(ProfileError("Request Failed $e"));
    }
  }
}
