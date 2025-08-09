import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/jobs/jobs_repository.dart';

class GetUpComingJobsUseCase {
  final JobsRepository jobsRepository;

  GetUpComingJobsUseCase(this.jobsRepository);

  Future<PaginatedData<CleaningRequest>> call({
    required int page,
    required int limit,
    String? status,
    String? type,
    String? sortBy,
    String? sortOrder,
    bool? allowPagination,
  }) async {
    try {
      return await jobsRepository.getJobs(
        page: page,
        limit: limit,
        status: status,
        type: type,
        sortOrder: sortOrder,
        sortBy: sortBy,
        allowPagination: allowPagination,
      );
    } catch (e) {
      throw (Exception('Getting Jobs Failed ${e.toString()}'));
    }
  }
}
