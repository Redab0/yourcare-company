import 'package:cleaning_service_driver/data/repositories/auth/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  Future<void> call() async {
    try {
      return await authRepository.logout();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
