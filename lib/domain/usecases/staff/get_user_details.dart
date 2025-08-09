import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';

class GetUserDetails {
  final StaffRepository _staffRepository;

  GetUserDetails(this._staffRepository);

  Future<User> call(String id) async {
    try {
      return await _staffRepository.getUser(id);
    } catch (e) {
      throw Exception("Error Fetching User $e");
    }
  }
}
