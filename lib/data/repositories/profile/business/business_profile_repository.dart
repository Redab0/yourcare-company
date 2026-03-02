import 'dart:io';

import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/data/services/profile/business/business_profile_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class BusinessProfileRepository {
  final BusinessProfileService _profileService;

  BusinessProfileRepository(this._profileService);

  Future<BusinessProfileModel> getBusinessProfile() async {
    final response = await _profileService.getCompanyProfile();

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<BusinessProfileModel> updateBusinessProfile(
      UpdateBusinessProfileModel model) async {
    final response = await _profileService.updateCompanyProfile(model);

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<AreaResponse>> getAreas() async {
    late List<AreaResponse> areas;
    var response = await _profileService.getAreas();
    if (response.success && response.data != null) {
      areas = response.data!.data!;
      // await SecureStorageService().saveAreas(areas);
    } else {
      throw Exception(response.message);
    }

    return areas;
  }

  Future<List<MediaUploadResponse>> uploadMedia(List<File> files) async {
    final parts = files
        .map((f) => MultipartFile.fromFileSync(
              f.path,
              filename: p.basename(f.path),
              contentType: MediaType('image', 'jpeg'),
            ))
        .toList();
    final response = await _profileService.uploadMedia(parts);

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception('Upload failed: ${response.message}');
    }
  }
}
