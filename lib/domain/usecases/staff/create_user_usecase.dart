import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class CreateUserUseCase {
  final StaffRepository _staffRepository;

  CreateUserUseCase(this._staffRepository);

  Future<User> call(CreateUserModel model) async {
    try {
      return await _staffRepository.createUser(model);
    } catch (e) {
      throw (Exception('Create User Failed ${e.toString()}'));
    }
  }
}
