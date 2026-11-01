import '../../data/models/auth/login_response.dart';
import '../../data/models/profile/company_services.dart';
import '../../data/models/staff/permission_model.dart';
import '../../domain/usecases/profile/business/get_company_services_usecase.dart';
import '../../domain/usecases/staff/get_all_permissions_usecase.dart';
import '../../domain/usecases/staff/get_user_details.dart';
import '../di/dependency_injection.dart';
import '../storage/secure_storage_service.dart';
import 'company_permission_policy.dart';

class CompanyPermissionContext {
  const CompanyPermissionContext(
      {required this.actor,
      required this.catalog,
      required this.generation,
      required this.services});
  final User actor;
  final List<PermissionModel> catalog;
  final int generation;
  final List<String>? services;
  bool get servicesUnavailable => services == null;
  List<PermissionModel> get options => companyPermissionOptions(
      catalog: catalog, actor: actor, companyServices: services);
}

/// Fresh self, company and catalog reads; a failed company read exposes only
/// generic choices. A previous account's context is never published or reused.
class CompanyPermissionContextLoader {
  CompanyPermissionContextLoader(
      {required this.generation,
      required this.readUser,
      required this.fetchUser,
      required this.fetchCompany,
      required this.fetchCatalog,
      this.timeout = const Duration(seconds: 15)});
  factory CompanyPermissionContextLoader.application() {
    final storage = SecureStorageService();
    return CompanyPermissionContextLoader(
        generation: () => storage.authGeneration,
        readUser: storage.getUser,
        fetchUser: (id) => sl<GetUserDetails>().call(id),
        fetchCompany: () => sl<GetCompanyServicesUseCase>().call(),
        fetchCatalog: () => sl<GetAllPermissionsUseCase>().call());
  }
  final int Function() generation;
  final Future<User?> Function() readUser;
  final Future<User> Function(String) fetchUser;
  final Future<CompanyServices> Function() fetchCompany;
  final Future<List<PermissionModel>> Function() fetchCatalog;
  final Duration timeout;
  bool current(CompanyPermissionContext context) =>
      generation() == context.generation;

  Future<CompanyPermissionContext> load() async {
    final account = generation();
    void check() {
      if (generation() != account) throw StateError('Account changed.');
    }

    final stored = await readUser().timeout(timeout);
    check();
    if (stored?.id == null) throw StateError('No current account.');
    final actor = await fetchUser(stored!.id!).timeout(timeout);
    check();
    if (actor.id != stored.id) throw StateError('Account does not match.');
    final catalogFuture = fetchCatalog().timeout(timeout);
    final companyFuture = fetchCompany()
        .timeout(timeout)
        .then<CompanyServices?>((value) => value, onError: (_) => null);
    final catalog = await catalogFuture;
    final company = await companyFuture;
    check();
    final matches =
        company?.businessId != null && company!.businessId == actor.businessId;
    return CompanyPermissionContext(
        actor: actor,
        catalog: catalog,
        generation: account,
        services: matches ? company.services : null);
  }
}
