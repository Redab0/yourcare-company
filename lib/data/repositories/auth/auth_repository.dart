import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/services/auth/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<User> login({required LoginCredentials loginCredentials}) async {
    final response = await _authService.login(loginCredentials);

    if (response.success && response.data != null) {
      await SecureStorageService().saveAccessToken(response.data.token);
      await SecureStorageService().saveUser(response.data.user);
      return response.data.user;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> logout() async {
    await SecureStorageService().clearAuthData();
  }

  Future<String?> getToken() async {
    return await SecureStorageService().getAccessToken();
  }
}
