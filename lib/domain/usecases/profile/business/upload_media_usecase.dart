import 'dart:io';

import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';

class UploadMediaUseCase {
  final BusinessProfileRepository _repo;
  UploadMediaUseCase(this._repo);

  Future<List<MediaUploadResponse>> call(List<File> files) async {
    var response = await _repo.uploadMedia(files);
    return response;
  }
}
