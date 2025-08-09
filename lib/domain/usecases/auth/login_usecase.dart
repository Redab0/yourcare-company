import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/auth/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<User> call(LoginCredentials loginCredentials) async {
    try {
      return await authRepository.login(loginCredentials: loginCredentials);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
