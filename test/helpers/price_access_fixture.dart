import 'package:cleaning_service_driver/core/access/price_access.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';

/// Positive financial journeys explicitly opt into a synthetic owner grant.
void grantPriceAccess() {
  PriceAccess.instance.reset();
  PriceAccess.instance.publish(
      User(id: '0123456789abcdef01234567', role: 'business_owner'),
      generation: SecureStorageService().authGeneration);
}
