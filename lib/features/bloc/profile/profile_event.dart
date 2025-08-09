import 'dart:io';

import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class GetAreasEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UpdateBusinessProfileModel model;

  const UpdateProfileEvent(this.model);

  @override
  List<Object?> get props => [model];
}

class UploadMediaEvent extends ProfileEvent {
  final List<File> files;
  const UploadMediaEvent(this.files);

  @override
  List<Object> get props => [files];
}
