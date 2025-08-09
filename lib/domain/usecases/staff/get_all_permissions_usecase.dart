import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class GetAllPermissionsUseCase {
  final StaffRepository staffRepository;

  GetAllPermissionsUseCase(this.staffRepository);

  Future<List<PermissionModel>> call() async {
    try {
      return await staffRepository.getPermissions();
    } catch (e) {
      throw (Exception('Getting Permissions Failed ${e.toString()}'));
    }
  }
}
