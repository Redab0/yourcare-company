import 'package:cleaning_service_driver/features/screens/home/business_setup_tour_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores setup tour completion independently for each company', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = BusinessSetupTourStorage(preferences);

    expect(storage.isCompleted('company-a'), isFalse);
    expect(storage.isCompleted('company-b'), isFalse);

    await storage.markCompleted('company-a');

    expect(storage.isCompleted('company-a'), isTrue);
    expect(storage.isCompleted('company-b'), isFalse);
  });

  test('stores each inner journey independently', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = BusinessSetupTourStorage(preferences);

    await storage.markCompleted(
      'company-a',
      journeyId: 'car_wash_pricing',
    );

    expect(
      storage.isCompleted('company-a', journeyId: 'car_wash_pricing'),
      isTrue,
    );
    expect(
      storage.isCompleted('company-a', journeyId: 'car_wash_working_hours'),
      isFalse,
    );
    expect(storage.isCompleted('company-a'), isFalse);
  });
}
