import 'package:cleaning_service_driver/core/models/page_wrapper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class GetAllUsersUseCase {
  final StaffRepository _staffRepository;

  GetAllUsersUseCase(this._staffRepository);

  Future<PaginatedData<User>> call(int page, int limit) async {
    try {
      return await _staffRepository.getUsers(page, limit);
    } catch (e) {
      throw (Exception('Getting Users Failed ${e.toString()}'));
    }
  }
}
