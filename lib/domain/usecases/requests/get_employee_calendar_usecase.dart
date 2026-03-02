import 'package:cleaning_service_driver/data/models/calendar/employee_calendar_response.dart';
import 'package:cleaning_service_driver/data/repositories/requests/requests_repository.dart';
import 'package:intl/intl.dart';

class GetEmployeeCalendarUseCase {
  final RequestsRepository requestsRepository;

  GetEmployeeCalendarUseCase(this.requestsRepository);

  Future<EmployeeCalendarResponse> call({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeId,
    String? teamId,
    String? requestType,
    String? requestStatus,
  }) async {
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      return await requestsRepository.getEmployeeCalendar(
        startDate: fmt.format(startDate),
        endDate: fmt.format(endDate),
        employeeId: employeeId,
        teamId: teamId,
        requestType: requestType,
        requestStatus: requestStatus,
      );
    } catch (e) {
      throw Exception('Getting Calendar Failed ${e.toString()}');
    }
  }
}
