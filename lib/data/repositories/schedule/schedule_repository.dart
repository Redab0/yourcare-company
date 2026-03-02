import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/services/schedule/schedule_service.dart';

class ScheduleRepository {
  final ScheduleService _scheduleService;

  ScheduleRepository(this._scheduleService);

  Future<List<CleanerAvailabilitySlot>> getCleanerAvailability() async {
    final response = await _scheduleService.getCleanerAvailability();
    if (response.success && response.data != null) {
      return response.data!.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleanerAvailabilitySlot> createCleanerAvailability(
      CleanerAvailabilityRequest request) async {
    final response = await _scheduleService.createCleanerAvailability(request);
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<CleanerAvailabilitySlot> updateCleanerAvailability(
      String id, CleanerAvailabilityRequest request) async {
    final response = await _scheduleService.updateCleanerAvailability(
      id,
      request,
    );
    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> deleteCleanerAvailability(String id) async {
    final response = await _scheduleService.deleteCleanerAvailability(id);
    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
