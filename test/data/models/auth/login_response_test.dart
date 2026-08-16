import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps company services from the login user payload', () {
    final user = User.fromJson({
      'id': 'user-1',
      'businessId': 'business-1',
      'services': ['houseCleaning', 'carWash'],
    });

    expect(user.services, ['houseCleaning', 'carWash']);
    expect(user.toJson()['services'], ['houseCleaning', 'carWash']);
  });
}
