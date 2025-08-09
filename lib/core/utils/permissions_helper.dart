// lib/core/auth/permission.dart

import "package:cleaning_service_driver/data/models/staff/permission_model.dart";

/// All possible permission keys from the backend.
enum Permission {
  usersCreate("users:create"),
  usersRead("users:read"),
  usersUpdate("users:update"),
  usersDelete("users:delete"),

  businessCreate("business:create"),
  businessRead("business:read"),
  businessUpdate("business:update"),
  businessDelete("business:delete"),

  categoriesCreate("categories:create"),
  categoriesRead("categories:read"),
  categoriesUpdate("categories:update"),
  categoriesDelete("categories:delete"),

  requestsCreate("requests:create"),
  requestsRead("requests:read"),
  requestsUpdate("requests:update"),
  requestsDelete("requests:delete"),

  transactionsCreate("transactions:create"),
  transactionsRead("transactions:read"),
  transactionsUpdate("transactions:update"),
  transactionsDelete("transactions:delete"),

  areasCreate("areas:create"),
  areasRead("areas:read"),
  areasUpdate("areas:update"),
  areasDelete("areas:delete"),

  emailCreate("email:create"),
  emailRead("email:read"),
  emailUpdate("email:update"),
  emailDelete("email:delete"),

  chatCreate("chat:create"),
  chatRead("chat:read"),
  chatUpdate("chat:update"),
  chatDelete("chat:delete"),

  teamsUpdate("teams:update"),
  teamsCreate("teams:create"),
  teamsRead("teams:read"),
  browsAvailableRequests("available_requests_brows"),
  ;

  /// The raw string key as returned by the API.
  final String value;
  const Permission(this.value);

  /// Try to parse a backend key into a Permission enum.
  /// Returns null if there"s no match.
  static Permission? fromString(String key) {
    for (var p in Permission.values) {
      if (p.value == key) return p;
    }
    return null;
  }
}

/// Extensions for working with your existing PermissionModel list.
extension PermissionModelListX on List<PermissionModel> {
  /// True if this user has the given permission.
  bool hasPermission(Permission p) => any((m) => m.name == p.value);

  /// True if this user has *all* of the given permissions.
  bool hasAllPermissions(Iterable<Permission> perms) =>
      perms.every(hasPermission);

  /// True if this user has *any* of the given permissions.
  bool hasAnyPermission(Iterable<Permission> perms) => perms.any(hasPermission);
}
