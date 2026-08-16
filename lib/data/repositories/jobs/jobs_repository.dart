import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/assign_team_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/complete_job_media_request.dart';
import 'package:cleaning_service_driver/data/models/requests/update_request_frequency_request.dart';
import 'package:cleaning_service_driver/data/services/jobs/jobs_service.dart';

class JobsRepository {
  final JobsService _jobsService;

  JobsRepository(this._jobsService);

  Future<PaginatedData<CleaningRequest>> getJobs({
    required int page,
    required int limit,
    String? status,
    String? type,
    String? sortBy,
    String? sortOrder,
    bool? allowPagination,
  }) async {
    final response = await _jobsService.getJobs(
      page: page,
      limit: limit,
      status: status,
      type: type,
      sortOrder: sortOrder,
      sortBy: sortBy,
      allowPagination: allowPagination,
    );

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> startJob(String id) async {
    final response = await _jobsService.startJob(id);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> completeJob(String id,
      {CompleteJobRequest? completeJobRequest}) async {
    final response =
        await _jobsService.completeJob(id, body: completeJobRequest);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> cancelJob(String id) async {
    final response = await _jobsService.cancelJob(id);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> assignCleaners(
      String id, AcceptHouseKeepingModel model) async {
    final response = await _jobsService.assignCleaners(id, model);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> assignTeam(String id, AssignTeamModel model) async {
    final response = await _jobsService.assignTeam(id, model);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest> updateFrequencyStatus(
      String id, UpdateRequestFrequencyRequest body) async {
    final response = await _jobsService.updateFrequencyStatus(id, body);

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleaningRequest?> addExtraFees(
    String id,
    AddExtraFeesRequest body,
  ) async {
    final response = await _jobsService.addExtraFees(id, body);
    final statusCode = response.response.statusCode;
    if (statusCode != null && (statusCode < 200 || statusCode >= 300)) {
      throw Exception('Extra invoice request failed ($statusCode)');
    }

    return _tryParseCleaningRequest(response.data);
  }

  CleaningRequest? _tryParseCleaningRequest(Object? value) {
    Object? candidate = value;
    for (var depth = 0; depth < 4; depth++) {
      if (candidate is! Map) return null;
      final map = Map<String, dynamic>.from(candidate);
      final looksLikeRequest = map['type'] != null ||
          map.containsKey('DeepCleaning') ||
          map.containsKey('HouseCleaning') ||
          map.containsKey('houseCleaning') ||
          map.containsKey('UpholsteryCleaning') ||
          map.containsKey('upholsteryCleaning') ||
          map.containsKey('CarWash') ||
          map.containsKey('carWash');
      if (looksLikeRequest) {
        try {
          return CleaningRequest.fromJson(map);
        } catch (_) {
          return null;
        }
      }
      candidate = map['data'];
    }
    return null;
  }
}
