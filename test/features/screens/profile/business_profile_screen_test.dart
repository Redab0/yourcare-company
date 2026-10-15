import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_event.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_state.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:cleaning_service_driver/features/screens/profile/business_profile_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final language in ['en', 'ar']) {
    for (final laundryEnabled in [false, true]) {
      testWidgets(
          'profile edits leave service activation untouched with laundry '
          '$laundryEnabled in $language', (tester) async {
        final profile = BusinessProfileModel.fromJson({
          'id': 'company-id',
          'name': 'Company',
          'services': ['houseCleaning', if (laundryEnabled) 'laundry'],
          'areas': [
            {'id': 'area-id', 'en': 'Area', 'ar': 'المنطقة'}
          ],
        });
        final cache = CompanyProfileCubit(_GetProfile(profile))
          ..setProfile(profile);
        sl.registerSingleton<CompanyProfileCubit>(cache);
        addTearDown(() async {
          await sl.unregister<CompanyProfileCubit>();
          await cache.close();
        });
        final bloc = _ProfileBloc(profile);
        addTearDown(bloc.close);

        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<BusinessProfileBloc>.value(
            value: bloc,
            child: const BusinessProfileScreen(),
          ),
        ));
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
            tester.element(find.byType(BusinessProfileScreen)))!;

        expect(find.text(l10n.laundry_enable_service), findsNothing);
        expect(find.byType(SwitchListTile), findsNothing);
        await tester.enterText(find.byType(TextFormField).first, 'New company');
        final save = find.widgetWithText(ElevatedButton, l10n.general_save);
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();

        final payload = bloc.updates.single.toJson();
        expect(payload['name'], 'New company');
        expect(payload['areas'], ['area-id']);
        expect(payload.containsKey('services'), isFalse,
            reason: 'Profile saves must preserve current server activation, '
                'including changes made after this profile was loaded.');
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _GetProfile implements GetBusinessProfileUseCase {
  final BusinessProfileModel profile;

  _GetProfile(this.profile);

  @override
  Future<BusinessProfileModel> call() async => profile;
}

class _ProfileBloc extends Cubit<BusinessProfileState>
    implements BusinessProfileBloc {
  final BusinessProfileModel profile;
  final updates = <UpdateBusinessProfileModel>[];

  _ProfileBloc(this.profile) : super(ProfileInitial());

  @override
  void add(BusinessProfileEvent event) {
    scheduleMicrotask(() {
      if (isClosed) return;
      if (event is GetAreasEvent) {
        emit(AreasLoaded([
          AreaResponse(areas: profile.areas),
        ]));
      } else if (event is LoadProfileEvent) {
        emit(ProfileLoaded(event.cachedProfile ?? profile));
      } else if (event is LoadCoveredServiceItemsEvent) {
        emit(CoveredServiceItemsLoaded(const []));
      } else if (event is UpdateProfileEvent) {
        updates.add(event.model);
      }
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
