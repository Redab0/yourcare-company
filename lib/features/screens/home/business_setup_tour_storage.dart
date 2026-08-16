import 'package:shared_preferences/shared_preferences.dart';

class BusinessSetupTourStorage {
  static const currentVersion = 1;
  static const _keyPrefix = 'business_setup_tour';
  static const dashboardJourney = 'dashboard';

  final SharedPreferences preferences;

  const BusinessSetupTourStorage(this.preferences);

  bool isCompleted(
    String companyId, {
    String journeyId = dashboardJourney,
  }) {
    return preferences.getBool(_key(companyId, journeyId)) ?? false;
  }

  Future<void> markCompleted(
    String companyId, {
    String journeyId = dashboardJourney,
  }) {
    return preferences.setBool(_key(companyId, journeyId), true);
  }

  static String _key(String companyId, String journeyId) {
    final base = '${_keyPrefix}_v$currentVersion:$companyId';
    return journeyId == dashboardJourney ? base : '$base:$journeyId';
  }
}
