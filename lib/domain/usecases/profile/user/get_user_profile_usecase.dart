import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/profile/user/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository _userProfileRepository;

  const GetUserProfileUseCase(this._userProfileRepository);

  Future<User> call() async {
    try {
      return await _userProfileRepository.getUserProfile();
    } catch (e) {
      throw (Exception('Getting User Failed ${e.toString()}'));
    }
  }
}
