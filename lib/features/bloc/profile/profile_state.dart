import 'package:cleaning_service_driver/data/models/profile/area_model.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final BusinessProfileModel model;
  const ProfileLoaded(this.model);

  @override
  List<Object?> get props => [model];
}

class ProfileUpdated extends ProfileState {
  final BusinessProfileModel model;
  const ProfileUpdated(this.model);

  @override
  List<Object?> get props => [model];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class AreasLoaded extends ProfileState {
  final List<AreaModel> areas;

  const AreasLoaded(this.areas);
  @override
  List<Object> get props => [areas];
}

class MediaUploaded extends ProfileState {
  final List<MediaUploadResponse> media;
  const MediaUploaded(this.media);

  @override
  List<Object> get props => [media];
}
