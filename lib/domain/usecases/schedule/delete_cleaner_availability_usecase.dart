import 'package:cleaning_service_driver/data/repositories/schedule/schedule_repository.dart';

class DeleteCleanerAvailabilityUseCase {
  final ScheduleRepository _scheduleRepository;

  DeleteCleanerAvailabilityUseCase(this._scheduleRepository);

  Future<void> call(String id) async {
    try {
      await _scheduleRepository.deleteCleanerAvailability(id);
    } catch (e) {
      throw Exception('Deleting availability failed ${e.toString()}');
    }
  }
}
