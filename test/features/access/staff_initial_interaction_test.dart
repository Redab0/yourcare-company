import 'dart:typed_data';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/company_services.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/repositories/profile/business/business_profile_repository.dart';
import 'package:cleaning_service_driver/data/repositories/staff/staff_repository.dart';
import 'package:cleaning_service_driver/data/services/profile/business/business_profile_service.dart';
import 'package:cleaning_service_driver/data/services/staff/staff_service.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_company_services_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/upload_media_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/assign_permissions_for_user.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/create_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/create_user_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_all_permissions_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/get_user_details.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/update_team_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/staff/update_user_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_state.dart';
import 'package:cleaning_service_driver/features/screens/staff/create_staff_screen.dart';
import 'package:cleaning_service_driver/features/screens/staff/staff_details_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['en', 'ar']) {
    for (final edit in [true, false]) {
      testWidgets(
          '${edit ? "edit" : "add"} staff scrolls and toggles with genuine idle bloc $language',
          (tester) async {
        FlutterSecureStorage.setMockInitialValues({});
        final actor =
            User(id: 'actor', role: 'business_owner', businessId: 'company');
        final target =
            User(id: 'target', username: 'fixture_staff', role: 'worker');
        await SecureStorageService().saveSession('synthetic', actor);
        final network = _NoNetwork();
        final dio = Dio()..httpClientAdapter = network;
        final staff = _Staff(StaffService(dio), actor, target);
        final business = _Business(BusinessProfileService(dio));
        final loader = _Loader();
        sl.registerSingleton<CreateUserUseCase>(CreateUserUseCase(staff));
        sl.registerSingleton<AssignPermissionsForUserUseCase>(
            AssignPermissionsForUserUseCase(staff));
        sl.registerSingleton<GetAllPermissionsUseCase>(
            GetAllPermissionsUseCase(staff));
        sl.registerSingleton<UploadMediaUseCase>(UploadMediaUseCase(business));
        sl.registerSingleton<UpdateUserUseCase>(UpdateUserUseCase(staff));
        sl.registerSingleton<CreateTeamUseCase>(CreateTeamUseCase(staff));
        sl.registerSingleton<UpdateTeamUseCase>(UpdateTeamUseCase(staff));
        sl.registerSingleton<GetUserDetails>(GetUserDetails(staff));
        sl.registerSingleton<GetCompanyServicesUseCase>(
            GetCompanyServicesUseCase(business));
        sl.registerSingleton<LoadingController>(loader);
        final bloc = StaffActionBloc();
        addTearDown(() async {
          await bloc.close();
          await sl.reset();
          dio.close();
        });
        await tester.pumpWidget(MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<StaffActionBloc>.value(
                value: bloc,
                child: edit
                    ? StaffDetailsScreen(user: target)
                    : const CreateStaffScreen())));
        await tester.pumpAndSettle();
        expect(bloc.state, isA<StaffActionInitial>());
        final scrollable = find.byType(Scrollable).first;
        final scroll = tester.state<ScrollableState>(scrollable);
        expect(scroll.position.pixels, 0);
        await tester.drag(find.byType(ListView).first, const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(scroll.position.pixels, greaterThan(0),
            reason:
                'Idle initial state must not absorb real gesture scrolling.');
        final option = find.byKey(const ValueKey('permission-see'));
        await tester.scrollUntilVisible(option, 250, scrollable: scrollable);
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(option).value, isFalse);
        await tester.tap(option);
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(option).value, isTrue);
        expect(bloc.state, isA<StaffActionInitial>(),
            reason:
                'Loading choices does not need an unrelated action-state transition.');
        expect(loader.shows, 0);
        expect(network.attempts, 0,
            reason: 'Only synthetic reads and local drafts are allowed.');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}

class _Staff extends StaffRepository {
  _Staff(super.service, this.actor, this.target);
  final User actor, target;
  @override
  Future<User> getUser(String id) async => id == actor.id ? actor : target;
  @override
  Future<List<PermissionModel>> getPermissions() async =>
      [PermissionModel('see', null, 'staff:read', null, null, 'staff', 'read')];
}

class _Business extends BusinessProfileRepository {
  _Business(super.service);
  @override
  Future<CompanyServices> getCompanyServices() async =>
      const CompanyServices(businessId: 'company', services: ['deepCleaning']);
}

class _Loader implements LoadingController {
  int shows = 0;
  @override
  void show([String tag = 'global']) {
    shows++;
  }

  @override
  void hide([String tag = 'global']) {}
}

class _NoNetwork implements HttpClientAdapter {
  int attempts = 0;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    attempts++;
    throw StateError('Unexpected transport in staff interaction fixture.');
  }

  @override
  void close({bool force = false}) {}
}
