import 'package:cleaning_service_driver/data/repositories/staff/permissions_repository.dart';

class CheckPermissionsUseCase {
  final PermissionsRepository _permissionsRepository;

  CheckPermissionsUseCase(this._permissionsRepository);

  bool call(String permissionsName) =>
      _permissionsRepository.hasPermission(permissionsName);
}
