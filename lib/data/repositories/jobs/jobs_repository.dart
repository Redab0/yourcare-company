import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/assign_team_model.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
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

  Future<CleaningRequest> completeJob(String id) async {
    final response = await _jobsService.completeJob(id);
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
}
