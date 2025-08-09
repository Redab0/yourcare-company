import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';

class PermissionsRepository {
  PermissionsRepository();
  List<PermissionModel> _permissions = [];

  List<PermissionModel> getPermissions() => List.unmodifiable(_permissions);

  bool hasPermission(String name) {
    return _permissions.any((p) => p.name == name);
  }

  Future<void> refresh() async {
    final user = await SecureStorageService().getUser();
    _permissions = user?.permissions ?? [];
  }
}
