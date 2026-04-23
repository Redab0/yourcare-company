import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:equatable/equatable.dart';

abstract class BusinessProfileState extends Equatable {
  const BusinessProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends BusinessProfileState {}

class ProfileLoaded extends BusinessProfileState {
  final BusinessProfileModel model;
  const ProfileLoaded(this.model);

  @override
  List<Object?> get props => [model];
}

class ProfileUpdated extends BusinessProfileState {
  final BusinessProfileModel model;
  const ProfileUpdated(this.model);

  @override
  List<Object?> get props => [model];
}

class ProfileError extends BusinessProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class AreasLoaded extends BusinessProfileState {
  final List<AreaResponse> areas;

  const AreasLoaded(this.areas);
  @override
  List<Object> get props => [areas];
}

class MediaUploaded extends BusinessProfileState {
  final List<MediaUploadResponse> media;
  const MediaUploaded(this.media);

  @override
  List<Object> get props => [media];
}

class CoveredServiceItemsLoaded extends BusinessProfileState {
  final List<CoveredServiceGroup> groups;

  const CoveredServiceItemsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}
