import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/services/profile/user/user_profile_service.dart';

class UserProfileRepository {
  final UserProfileService _userProfileService;

  const UserProfileRepository(this._userProfileService);

  Future<User> getUserProfile() async {
    final response = await _userProfileService.getUserProfile();

    if (response.success && response.data != null) {
      return response.data!.data!;
    } else {
      throw Exception(response.message);
    }
  }
}
