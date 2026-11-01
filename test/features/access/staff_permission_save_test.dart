import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/company_services.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_user_details.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_permissions_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_company_services_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_state.dart';
import 'package:cleaning_service_driver/features/screens/staff/staff_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../core/access/company_permission_policy_test.dart'
    show permission, servicesContext;

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets(
      'actual staff save retains all hidden IDs after visible uncheck and context change',
      (tester) async {
    final actor =
        User(id: 'actor', role: 'business_owner', businessId: 'company');
    final held = [
      permission('staff:read'),
      permission('business:create'),
      permission('housekeeping_pricing:read'),
      permission('unknown:old')
    ];
    final target = User(
        id: 'target',
        username: 'staff',
        role: 'worker',
        permissions: held,
        canSeePrices: false);
    await SecureStorageService().saveSession('synthetic', actor);
    sl.registerSingleton<GetUserDetails>(
        _GetUser((id) => id == 'actor' ? actor : target));
    sl.registerSingleton<GetAllPermissionsUseCase>(
        _GetCatalog([...held, permission('auto_bid:read')]));
    final business = _GetCompany(servicesContext('company', ['deepCleaning']));
    sl.registerSingleton<GetCompanyServicesUseCase>(business);
    final bloc = _Actions();
    addTearDown(() async {
      await sl.unregister<GetUserDetails>();
      await sl.unregister<GetAllPermissionsUseCase>();
      await sl.unregister<GetCompanyServicesUseCase>();
      await bloc.close();
    });
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<StaffActionBloc>.value(
            value: bloc,
            child: StaffDetailsScreen(
                user: target.copyWith(canSeePrices: true)))));
    await tester.pumpAndSettle();
    final price = find.byKey(const ValueKey('staff-can-see-prices'));
    await tester.scrollUntilVisible(price, 250,
        scrollable: find.byType(Scrollable).first);
    expect(tester.widget<CheckboxListTile>(price).value, isFalse,
        reason: 'Fresh target detail wins over the list snapshot.');
    final visible = find.byKey(const ValueKey('permission-staff:read'));
    await tester.scrollUntilVisible(visible, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(visible);
    await tester.pumpAndSettle();
    expect(find.text('Add companies'), findsNothing);
    // A held off-service ID becomes eligible on the server after this editor
    // loaded. The client still submits it, rather than intersecting with options.
    business.value = servicesContext('company', ['houseCleaning']);
    final save = find.byIcon(Icons.shield);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final event = bloc.events.whereType<AssignPermissionsEvent>().single;
    expect(event.model.userId, 'target');
    expect(event.model.permissionIds?.toSet(),
        {'business:create', 'housekeeping_pricing:read', 'unknown:old'});
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

class _Actions extends Cubit<StaffActionState> implements StaffActionBloc {
  _Actions() : super(StaffActionInitial());
  final events = <StaffActionEvent>[];
  @override
  void add(StaffActionEvent event) {
    events.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GetUser implements GetUserDetails {
  _GetUser(this.lookup);
  final User Function(String) lookup;
  @override
  Future<User> call(String id) async => lookup(id);
}

class _GetCatalog implements GetAllPermissionsUseCase {
  _GetCatalog(this.value);
  final List<PermissionModel> value;
  @override
  Future<List<PermissionModel>> call() async => value;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GetCompany implements GetCompanyServicesUseCase {
  _GetCompany(this.value);
  CompanyServices value;
  @override
  Future<CompanyServices> call() async => value;
}
