import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class GetPermissionsForUserUseCase {
  final StaffRepository staffRepository;

  GetPermissionsForUserUseCase(this.staffRepository);

  Future<User> call(String id) async {
    try {
      return await staffRepository.getUserPermission(id);
    } catch (e) {
      throw (Exception('Getting Permissions Failed ${e.toString()}'));
    }
  }
}
