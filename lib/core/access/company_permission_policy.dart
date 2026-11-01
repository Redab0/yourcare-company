import '../../data/models/auth/login_response.dart';
import '../../data/models/staff/permission_model.dart';

/// New company grants only. Existing IDs and server authorization are untouched.
const companyGeneralPermissionNames = <String>{
  'business:read',
  'business:update',
  'company_profile:read',
  'company_profile:update',
  'staff:create',
  'staff:read',
  'staff:update',
  'teams:create',
  'teams:read',
  'teams:update',
  'requests:read',
  'requests:update',
  'company_requests:read',
  'company_requests:update',
  'chat:create',
  'chat:read',
  'upload:create',
  'upload:delete',
  'categories:read',
  'areas:read',
  'users:read',
  'reports:read',
  'transactions:read',
  'permissions:read',
  'permissions:update',
};

const companyServicePermissionNames = <String, Set<String>>{
  'housekeeping_pricing:create': {'houseCleaning'},
  'housekeeping_pricing:read': {'houseCleaning'},
  'housekeeping_pricing:update': {'houseCleaning'},
  'auto_bid:create': {'deepCleaning'},
  'auto_bid:read': {'deepCleaning'},
  'auto_bid:update': {'deepCleaning'},
  'requests:create': {'deepCleaning', 'upholsteryCleaning'},
  'available_requests:read': {'deepCleaning', 'upholsteryCleaning'},
  'cleaner_availability:create': {
    'houseCleaning',
    'carWash',
    'upholsteryCleaning',
    'deepCleaning'
  },
  'cleaner_availability:read': {
    'houseCleaning',
    'carWash',
    'upholsteryCleaning',
    'deepCleaning'
  },
  'cleaner_availability:update': {
    'houseCleaning',
    'carWash',
    'upholsteryCleaning',
    'deepCleaning'
  },
  'cleaner_availability:delete': {
    'houseCleaning',
    'carWash',
    'upholsteryCleaning',
    'deepCleaning'
  },
};

List<PermissionModel> companyPermissionOptions({
  required Iterable<PermissionModel> catalog,
  required User actor,
  required Iterable<String>? companyServices,
}) {
  if (actor.role == 'admin') return catalog.toList(growable: false);
  if (!['business_owner', 'manager'].contains(actor.role)) return const [];
  final services =
      companyServices?.map((s) => s.trim().toLowerCase()).toSet() ?? <String>{};
  final ownNames = actor.permissions?.map((p) => p.name).toSet() ?? <String?>{};
  return catalog.where((permission) {
    final name = permission.name;
    if (permission.id == null ||
        name == null ||
        name != '${permission.resource}:${permission.action}') {
      return false;
    }
    if (actor.role == 'manager' && !ownNames.contains(name)) return false;
    return companyGeneralPermissionNames.contains(name) ||
        (companyServicePermissionNames[name]
                ?.any((s) => services.contains(s.toLowerCase())) ??
            false);
  }).toList(growable: false);
}
