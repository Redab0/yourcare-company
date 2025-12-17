import 'dart:io';

import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class BusinessProfileEvent extends Equatable {
  const BusinessProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends BusinessProfileEvent {}

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
