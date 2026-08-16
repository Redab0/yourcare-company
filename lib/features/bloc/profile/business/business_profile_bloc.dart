import 'dart:async';
import 'dart:developer' as developer;

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/create_custom_service_item_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/delete_custom_service_item_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_areas_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_covered_service_items_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/update_covered_service_items_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/update_custom_service_item_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/update_business_profile_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/upload_media_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_event.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_state.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessProfileBloc
    extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final getProfileUseCase = sl<GetBusinessProfileUseCase>();
  final updateProfileUseCase = sl<UpdateBusinessProfileUseCase>();
  final getAreasUseCase = sl<GetAreasUseCase>();
  final uploadMediaUseCase = sl<UploadMediaUseCase>();
  final getCoveredServiceItemsUseCase = sl<GetCoveredServiceItemsUseCase>();
  final updateCoveredServiceItemsUseCase =
      sl<UpdateCoveredServiceItemsUseCase>();
  final createCustomServiceItemUseCase = sl<CreateCustomServiceItemUseCase>();
  final updateCustomServiceItemUseCase = sl<UpdateCustomServiceItemUseCase>();
  final deleteCustomServiceItemUseCase = sl<DeleteCustomServiceItemUseCase>();
  final _loader = sl<LoadingController>();

  void _logError(
    String action,
    Object error,
    StackTrace stackTrace,
  ) {
    developer.log(
      '[BusinessProfileBloc] $action failed: $error',
      name: 'BusinessProfileBloc',
      error: error,
      stackTrace: stackTrace,
    );
  }

  BusinessProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfileEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<GetAreasEvent>(_onGetAreas);
    on<UploadMediaEvent>(_upload);
    on<LoadCoveredServiceItemsEvent>(_onLoadCoveredServiceItems);
    on<UpdateCoveredServiceItemsEvent>(_onUpdateCoveredServiceItems);
    on<CreateCustomServiceItemEvent>(_onCreateCustomServiceItem);
    on<UpdateCustomServiceItemEvent>(_onUpdateCustomServiceItem);
    on<DeleteCustomServiceItemEvent>(_onDeleteCustomServiceItem);
  }

  FutureOr<void> _onLoadProfileEvent(
      LoadProfileEvent event, Emitter<BusinessProfileState> emit) async {
    final cachedProfile = event.cachedProfile;
    if (cachedProfile != null) {
      emit(ProfileLoaded(cachedProfile));
      return;
    }

    _loader.show();
    try {
      final profile = await getProfileUseCase.call();
      _loader.hide();
      sl<CompanyProfileCubit>().setProfile(profile);
      emit(ProfileLoaded(profile));
    } catch (e, s) {
      _logError('_onLoadProfileEvent', e, s);
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
      sl<CompanyProfileCubit>().setProfile(profile);
      emit(ProfileLoaded(profile));
    } catch (e, s) {
      _logError('_onUpdateProfileEvent', e, s);
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onGetAreas(
      GetAreasEvent event, Emitter<BusinessProfileState> emit) async {
    try {
      var areas = await getAreasUseCase.execute();
      emit(AreasLoaded(areas));
    } catch (e, s) {
      _logError('_onGetAreas', e, s);
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
    } catch (e, s) {
      _logError('_upload', e, s);
      _loader.hide();
      emit(ProfileError("Request Failed $e"));
    }
  }

  FutureOr<void> _onLoadCoveredServiceItems(LoadCoveredServiceItemsEvent event,
      Emitter<BusinessProfileState> emit) async {
    try {
      final groups =
          await getCoveredServiceItemsUseCase.call(profile: event.cachedProfile);
      emit(CoveredServiceItemsLoaded(groups));
    } catch (e, s) {
      _logError('_onLoadCoveredServiceItems', e, s);
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateCoveredServiceItems(
      UpdateCoveredServiceItemsEvent event,
      Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final ids = <String>{};
      for (final group in event.groups) {
        for (final item in group.services) {
          // Save button should only update standard covered-service-items.
          // Custom items are managed through their dedicated create/edit/delete APIs.
          if (!item.canManage && item.selected && item.id.trim().isNotEmpty) {
            ids.add(item.id.trim());
          }
        }
      }
      final groups = await updateCoveredServiceItemsUseCase.call(ids.toList());
      _loader.hide();
      emit(CoveredServiceItemsLoaded(groups));
    } catch (e, s) {
      _logError('_onUpdateCoveredServiceItems', e, s);
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onCreateCustomServiceItem(CreateCustomServiceItemEvent event,
      Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final groups = await createCustomServiceItemUseCase.call(
        serviceType: event.serviceType,
        titleEn: event.titleEn,
        titleAr: event.titleAr,
      );
      _loader.hide();
      emit(CoveredServiceItemsLoaded(groups));
    } catch (e, s) {
      _logError('_onCreateCustomServiceItem', e, s);
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateCustomServiceItem(UpdateCustomServiceItemEvent event,
      Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final groups = await updateCustomServiceItemUseCase.call(
        serviceItemId: event.serviceItemId,
        titleEn: event.titleEn,
        titleAr: event.titleAr,
      );
      _loader.hide();
      emit(CoveredServiceItemsLoaded(groups));
    } catch (e, s) {
      _logError('_onUpdateCustomServiceItem', e, s);
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }

  FutureOr<void> _onDeleteCustomServiceItem(DeleteCustomServiceItemEvent event,
      Emitter<BusinessProfileState> emit) async {
    _loader.show();
    try {
      final groups =
          await deleteCustomServiceItemUseCase.call(event.serviceItemId);
      _loader.hide();
      emit(CoveredServiceItemsLoaded(groups));
    } catch (e, s) {
      _logError('_onDeleteCustomServiceItem', e, s);
      _loader.hide();
      emit(ProfileError(e.toString()));
    }
  }
}
