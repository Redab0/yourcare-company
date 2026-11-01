import 'dart:async';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/access/price_access.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/profile/company_services.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_company_services_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_state.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_event.dart';
import 'package:cleaning_service_driver/features/bloc/home/home_state.dart';
import 'package:cleaning_service_driver/features/screens/home/company_services_cubit.dart';
import 'package:cleaning_service_driver/features/screens/home/business_setup_tour_storage.dart';
import 'package:cleaning_service_driver/features/screens/home/home_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/access/company_permission_policy_test.dart'
    show servicesContext;

void main() {
  for (final pendingFirstRead in [false, true]) {
    testWidgets(
        'cleared capability cache reloads current company; first read pending=$pendingFirstRead',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      await BusinessSetupTourStorage(preferences).markCompleted('company');
      sl.registerSingleton<SharedPreferences>(preferences);
      final actor = User(
          id: 'actor',
          businessId: 'company',
          role: 'business_owner',
          services: ['laundry']);
      await SecureStorageService().saveSession('synthetic', actor);
      final getCompany =
          _Company(servicesContext('company', ['houseCleaning']));
      final initial = Completer<CompanyServices>();
      if (pendingFirstRead) getCompany.firstRead = initial.future;
      final cache = CompanyServicesCubit(getCompany);
      sl.registerSingleton<CompanyServicesCubit>(cache);
      final home = _Home(actor);
      final auth = _Auth();
      addTearDown(() async {
        await sl.unregister<SharedPreferences>();
        await sl.unregister<CompanyServicesCubit>();
        await cache.close();
        await home.close();
        await auth.close();
      });
      await tester.pumpWidget(MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>.value(value: home),
            BlocProvider<AuthBloc>.value(value: auth)
          ],
          child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const HomePage())));
      await getCompany.firstRequested.future;
      if (pendingFirstRead) {
        await tester.pump();
        expect(cache.state.isLoading, isTrue);
      } else {
        await tester.pumpAndSettle();
      }
      final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)))!;
      expect(find.text(l10n.house_keeping_configuration),
          pendingFirstRead ? findsNothing : findsOneWidget);
      expect(find.text(l10n.laundry_configuration), findsNothing);
      final before = getCompany.calls;
      getCompany.value = servicesContext('company', ['carWash']);
      PriceAccess.instance.deny();
      cache.clear(); // Real capability/session lifecycle invalidation callback.
      await tester.pumpAndSettle();
      if (pendingFirstRead) {
        initial.complete(servicesContext('company', ['houseCleaning']));
        await tester.pumpAndSettle();
      }
      expect(getCompany.calls, before + 1);
      expect(find.text(l10n.car_wash_configuration), findsOneWidget);
      expect(find.text(l10n.house_keeping_configuration), findsNothing);
      expect(find.text(l10n.upcoming_jobs), findsOneWidget);
      expect(find.text(l10n.reports), findsNothing);
      expect(find.text(l10n.documentsCenter), findsNothing);
      final beforeAccountChange = getCompany.calls;
      await SecureStorageService().saveSession('new-account',
          User(id: 'other', businessId: 'other-company', role: 'manager'));
      cache.clear();
      await tester.pumpAndSettle();
      expect(getCompany.calls, beforeAccountChange,
          reason: 'An old Home must not reload a replacement account.');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _Company implements GetCompanyServicesUseCase {
  _Company(this.value);
  CompanyServices value;
  int calls = 0;
  Future<CompanyServices>? firstRead;
  final firstRequested = Completer<void>();
  @override
  Future<CompanyServices> call() async {
    calls++;
    if (calls == 1) {
      firstRequested.complete();
      if (firstRead != null) return firstRead!;
    }
    return value;
  }
}

class _Home extends Cubit<HomeState> implements HomeBloc {
  _Home(this.user) : super(HomeInitial());
  final User user;
  @override
  void add(HomeEvent event) {
    if (event is FetchUserDetails) emit(UserFetched(user));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth extends Cubit<AuthState> implements AuthBloc {
  _Auth() : super(AuthInitial());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
