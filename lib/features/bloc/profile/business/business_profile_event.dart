import 'dart:io';

import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class BusinessProfileEvent extends Equatable {
  const BusinessProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends BusinessProfileEvent {
  final BusinessProfileModel? cachedProfile;

  const LoadProfileEvent({this.cachedProfile});

  @override
  List<Object?> get props => [cachedProfile];
}

class GetAreasEvent extends BusinessProfileEvent {}

class UpdateProfileEvent extends BusinessProfileEvent {
  final UpdateBusinessProfileModel model;

  const UpdateProfileEvent(this.model);

  @override
  List<Object?> get props => [model];
}

class UploadMediaEvent extends BusinessProfileEvent {
  final List<File> files;
  const UploadMediaEvent(this.files);

  @override
  List<Object> get props => [files];
}

class LoadCoveredServiceItemsEvent extends BusinessProfileEvent {
  final BusinessProfileModel? cachedProfile;

  const LoadCoveredServiceItemsEvent({this.cachedProfile});

  @override
  List<Object?> get props => [cachedProfile];
}

class UpdateCoveredServiceItemsEvent extends BusinessProfileEvent {
  final List<CoveredServiceGroup> groups;

  const UpdateCoveredServiceItemsEvent(this.groups);

  @override
  List<Object?> get props => [groups];
}

class CreateCustomServiceItemEvent extends BusinessProfileEvent {
  final String serviceType;
  final String titleEn;
  final String titleAr;

  const CreateCustomServiceItemEvent({
    required this.serviceType,
    required this.titleEn,
    required this.titleAr,
  });

  @override
  List<Object?> get props => [serviceType, titleEn, titleAr];
}

class UpdateCustomServiceItemEvent extends BusinessProfileEvent {
  final String serviceItemId;
  final String titleEn;
  final String titleAr;

  const UpdateCustomServiceItemEvent({
    required this.serviceItemId,
    required this.titleEn,
    required this.titleAr,
  });

  @override
  List<Object?> get props => [serviceItemId, titleEn, titleAr];
}

class DeleteCustomServiceItemEvent extends BusinessProfileEvent {
  final String serviceItemId;

  const DeleteCustomServiceItemEvent(this.serviceItemId);

  @override
  List<Object?> get props => [serviceItemId];
}
