import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/update_user_model.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class UpdateUserUseCase {
  final StaffRepository _staffRepository;

  const UpdateUserUseCase(this._staffRepository);

  Future<User> call(UpdateUserModel model, String id) async {
    try {
      final response = await _staffRepository.updateUser(model, id);
      return response;
    } catch (e) {
      throw Exception("Error updating user $e");
    }
  }
}
