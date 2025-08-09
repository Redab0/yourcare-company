import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class AssignPermissionsForUserUseCase {
  final StaffRepository staffRepository;

  AssignPermissionsForUserUseCase(this.staffRepository);

  Future<User> call(AssignPermissionModel model) async {
    try {
      return await staffRepository.assignPermissionsToUser(model);
    } catch (e) {
      throw (Exception('Assigning Permissions Failed ${e.toString()}'));
    }
  }
}
