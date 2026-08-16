import 'dart:io';
import 'dart:developer' as developer;

import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/core/models/response_payload.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
import 'package:cleaning_service_driver/data/models/profile/custom_service_item_request.dart';
import 'package:cleaning_service_driver/data/models/profile/media_upload_response.dart';
import 'package:cleaning_service_driver/data/models/profile/update_covered_service_items_request.dart';
import 'package:cleaning_service_driver/data/models/profile/update_custom_service_item_request.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/data/services/profile/business/business_profile_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class BusinessProfileRepository {
  final BusinessProfileService _profileService;

  BusinessProfileRepository(this._profileService);

  void _logError(String action, Object error, [StackTrace? stackTrace]) {
    developer.log(
      '[BusinessProfileRepository] $action failed: $error',
      name: 'BusinessProfileRepository',
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<BusinessProfileModel> getBusinessProfile() async {
    try {
      final response = await _profileService.getCompanyProfile();
      if (response.success && response.data != null) {
        return response.data!.data!;
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _logError('getBusinessProfile', e, s);
      rethrow;
    }
  }

  Future<BusinessProfileModel> updateBusinessProfile(
      UpdateBusinessProfileModel model) async {
    try {
      final response = await _profileService.updateCompanyProfile(model);
      if (response.success && response.data != null) {
        return response.data!.data!;
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _logError('updateBusinessProfile', e, s);
      rethrow;
    }
  }

  Future<List<CoveredServiceGroup>> getCoveredServiceItems({
    BusinessProfileModel? profile,
  }) async {
    try {
      final response = await _profileService.getCoveredServiceItems();
      ApiResponse<ResponsePayload<BusinessProfileModel>>? profileResponse;
      if (profile == null) {
        try {
          profileResponse = await _profileService.getCompanyProfile();
        } catch (e, s) {
          _logError('getCoveredServiceItems->getCompanyProfile', e, s);
        }
      }

      if (response.success && response.data != null) {
        final apiGroups = response.data!.data ?? const [];
        final profileGroups =
            profile?.coveredServices ??
                profileResponse?.data?.data?.coveredServices ??
                const [];
        return _mergeAndDedupeCoveredGroups(
          apiGroups: apiGroups,
          profileGroups: profileGroups,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _logError('getCoveredServiceItems', e, s);
      rethrow;
    }
  }

  Future<List<CoveredServiceGroup>> updateCoveredServiceItems(
      List<String> serviceItemIds) async {
    try {
      final response = await _profileService.updateCoveredServiceItems(
        UpdateCoveredServiceItemsRequest(serviceItemIds),
      );

      if (response.success && response.data != null) {
        final groups = await _profileService.getCoveredServiceItems();
        final apiGroups = groups.data?.data ?? const [];
        final profileGroups = response.data!.data?.coveredServices ?? const [];
        return _mergeAndDedupeCoveredGroups(
          apiGroups: apiGroups,
          profileGroups: profileGroups,
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e, s) {
      _logError('updateCoveredServiceItems', e, s);
      rethrow;
    }
  }

  Future<List<CoveredServiceGroup>> createCustomServiceItem({
    required String serviceType,
    required String titleEn,
    required String titleAr,
  }) async {
    try {
      final response = await _profileService.createCustomServiceItem(
        CustomServiceItemRequest(
          serviceType: serviceType,
          titleEn: titleEn,
          titleAr: titleAr,
        ),
      );

      if (response.success && response.data != null) {
        final groups = await _profileService.getCoveredServiceItems();
        final apiGroups = groups.data?.data ?? const [];
        final profileGroups = response.data!.data?.coveredServices ?? const [];
        return _mergeAndDedupeCoveredGroups(
          apiGroups: apiGroups,
          profileGroups: profileGroups,
        );
      }
      throw Exception(response.message);
    } catch (e, s) {
      _logError('createCustomServiceItem', e, s);
      rethrow;
    }
  }

  Future<List<CoveredServiceGroup>> updateCustomServiceItem({
    required String serviceItemId,
    required String titleEn,
    required String titleAr,
  }) async {
    try {
      final response = await _profileService.updateCustomServiceItem(
        serviceItemId,
        UpdateCustomServiceItemRequest(
          titleEn: titleEn,
          titleAr: titleAr,
        ),
      );

      if (response.success && response.data != null) {
        final groups = await _profileService.getCoveredServiceItems();
        final apiGroups = groups.data?.data ?? const [];
        final profileGroups = response.data!.data?.coveredServices ?? const [];
        return _mergeAndDedupeCoveredGroups(
          apiGroups: apiGroups,
          profileGroups: profileGroups,
        );
      }
      throw Exception(response.message);
    } catch (e, s) {
      _logError('updateCustomServiceItem', e, s);
      rethrow;
    }
  }

  Future<List<CoveredServiceGroup>> deleteCustomServiceItem(
      String serviceItemId) async {
    try {
      final response =
          await _profileService.deleteCustomServiceItem(serviceItemId);

      if (response.success && response.data != null) {
        final groups = await _profileService.getCoveredServiceItems();
        final apiGroups = groups.data?.data ?? const [];
        final profileGroups = response.data!.data?.coveredServices ?? const [];
        return _mergeAndDedupeCoveredGroups(
          apiGroups: apiGroups,
          profileGroups: profileGroups,
        );
      }
      throw Exception(response.message);
    } catch (e, s) {
      _logError('deleteCustomServiceItem', e, s);
      rethrow;
    }
  }

  List<CoveredServiceGroup> _mergeAndDedupeCoveredGroups({
    required List<CoveredServiceGroup> apiGroups,
    required List<CoveredServiceGroup> profileGroups,
  }) {
    final selectedIds = _extractSelectedIds(profileGroups);
    final byType = <String, Map<String, CoveredServiceItem>>{};

    void addItems(List<CoveredServiceGroup> source, {required bool fromApi}) {
      for (final group in source) {
        final type = group.serviceType.trim();
        if (type.isEmpty) continue;
        final typedItems = byType.putIfAbsent(type, () => {});

        for (final item in group.services) {
          final key = _itemKey(item);
          final existing = typedItems[key];
          final isSelected =
              item.id.isNotEmpty && selectedIds.contains(item.id);

          final incoming = item.copyWith(
            selected: isSelected || item.selected,
            canManage: !fromApi,
          );

          if (existing == null) {
            typedItems[key] = incoming;
            continue;
          }

          typedItems[key] = existing.copyWith(
            titleEn: (existing.titleEn == null || existing.titleEn!.isEmpty)
                ? incoming.titleEn
                : existing.titleEn,
            titleAr: (existing.titleAr == null || existing.titleAr!.isEmpty)
                ? incoming.titleAr
                : existing.titleAr,
            selected: existing.selected || incoming.selected,
            canManage: existing.canManage && incoming.canManage,
          );
        }
      }
    }

    // API is canonical for standard items; profile adds selected state/custom extras.
    addItems(apiGroups, fromApi: true);
    addItems(profileGroups, fromApi: false);

    return byType.entries
        .map(
          (e) => CoveredServiceGroup(
            serviceType: e.key,
            services: e.value.values.toList(),
          ),
        )
        .toList();
  }

  String _itemKey(CoveredServiceItem item) {
    if (item.id.isNotEmpty) return item.id;
    return '${item.titleEn ?? ''}|${item.titleAr ?? ''}';
  }

  Set<String> _extractSelectedIds(List<CoveredServiceGroup> coveredServices) {
    final ids = <String>{};
    for (final group in coveredServices) {
      for (final item in group.services) {
        if (item.id.isNotEmpty) ids.add(item.id);
      }
    }
    return ids;
  }

  Future<List<AreaResponse>> getAreas() async {
    try {
      late List<AreaResponse> areas;
      var response = await _profileService.getAreas();
      if (response.success && response.data != null) {
        areas = response.data!.data!;
        // await SecureStorageService().saveAreas(areas);
      } else {
        throw Exception(response.message);
      }
      return areas;
    } catch (e, s) {
      _logError('getAreas', e, s);
      rethrow;
    }
  }

  Future<List<MediaUploadResponse>> uploadMedia(List<File> files) async {
    try {
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
    } catch (e, s) {
      _logError('uploadMedia', e, s);
      rethrow;
    }
  }
}
