import 'dart:async';
import 'package:cleaning_service_driver/components/company_permission_panel.dart';
import 'package:cleaning_service_driver/core/access/company_permission_context.dart';
import 'package:cleaning_service_driver/core/access/price_access.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../core/access/company_permission_policy_test.dart'
    show permission, servicesContext;

void main() => companyPermissionPanelJourneys();

void companyPermissionPanelJourneys(
    {Future<void> Function(WidgetTester, String)? screenshot}) {
  final owner =
      User(id: 'actor', role: 'business_owner', businessId: 'company');
  final catalog = [
    permission('staff:read'),
    permission('staff:update'),
    permission('business:create'),
    permission('housekeeping_pricing:read'),
    permission('auto_bid:read')
  ];
  CompanyPermissionContextLoader loader(
          {int Function()? generation,
          Future<User> Function(String)? fetchUser,
          Future<dynamic> Function()? companyFetch,
          Future<List<dynamic>> Function()? catalogFetch}) =>
      CompanyPermissionContextLoader(
          generation: generation ?? () => 0,
          readUser: () async => owner,
          fetchUser: fetchUser ?? (_) async => owner,
          fetchCompany: () async => companyFetch == null
              ? servicesContext('company', ['deepCleaning'])
              : await companyFetch(),
          fetchCatalog: () async =>
              catalogFetch == null ? catalog : (await catalogFetch()).cast());
  Widget app(Widget child, String language) => MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)));

  for (final language in ['en', 'ar']) {
    testWidgets('filtered choices and hidden-ID preservation $language',
        (tester) async {
      var selected = <String>{
        'staff:read',
        'business:create',
        'housekeeping_pricing:read',
        'ghost-id'
      };
      await tester.pumpWidget(app(
          StatefulBuilder(
              builder: (_, setState) => CompanyPermissionPanel(
                  loader: loader(),
                  selectedIds: selected,
                  existing: catalog,
                  onChanged: (value) => setState(() => selected = value))),
          language));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('permission-staff:read')), findsOneWidget);
      expect(find.byKey(const ValueKey('permission-auto_bid:read')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('permission-business:create')),
          findsNothing);
      expect(find.byKey(const ValueKey('permission-housekeeping_pricing:read')),
          findsNothing);
      expect(find.text(language == 'en' ? 'Add companies' : 'إضافة الشركات'),
          findsNothing);
      expect(
          find.byKey(const ValueKey('retained-permissions')), findsOneWidget);
      expect(
          find.textContaining(
              language == 'en' ? 'unavailable for new' : 'غير متاحة لمنحها'),
          findsNothing);
      await tester.tap(find.byKey(const ValueKey('permission-staff:read')));
      await tester.pump();
      expect(selected,
          {'business:create', 'housekeeping_pricing:read', 'ghost-id'});
      if (screenshot != null) {
        await screenshot(tester, 'provider-company-access-$language');
      }
    });
  }
  testWidgets('loading and failed catalog provide a real retry',
      (tester) async {
    var calls = 0;
    final requested = Completer<void>();
    final gate = Completer<void>();
    final source = loader(catalogFetch: () async {
      calls++;
      if (!requested.isCompleted) requested.complete();
      if (calls == 1) {
        await gate.future;
        throw StateError('synthetic catalog failure');
      }
      return catalog;
    });
    await tester.pumpWidget(app(
        CompanyPermissionPanel(
            loader: source, selectedIds: const {}, onChanged: (_) {}),
        'en'));
    await tester.pump();
    await requested.future;
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Staff access options could not be loaded. Please try again.'),
        findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(const ValueKey('permission-staff:read')), findsOneWidget);
  });
  testWidgets('failed company context leaves generic choices and retry',
      (tester) async {
    await tester.pumpWidget(app(
        CompanyPermissionPanel(
            loader:
                loader(companyFetch: () async => throw StateError('synthetic')),
            selectedIds: const {},
            onChanged: (_) {}),
        'en'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('permission-staff:read')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('permission-auto_bid:read')), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
  });
  testWidgets('account change invalidates context without editing hidden IDs',
      (tester) async {
    var generation = 0;
    var edits = 0;
    await tester.pumpWidget(app(
        CompanyPermissionPanel(
            loader: loader(generation: () => generation),
            selectedIds: const {'ghost'},
            onChanged: (_) => edits++),
        'en'));
    await tester.pumpAndSettle();
    generation++;
    PriceAccess.instance.reset(generation: generation);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('permission-staff:read')), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('permission-staff:read')), findsNothing);
    expect(edits, 0);
  });
}
