import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/business/get_business_profile_usecase.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_catalog_screen.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_product_editor.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

LaundryCatalogItem _item({bool unavailable = false, bool configured = true}) =>
    LaundryCatalogItem(
      id: configured ? 'config-1' : 'product-1',
      productId: 'product-1',
      source: 'admin',
      nameEn: 'Blanket',
      nameAr: 'بطانية',
      configured: configured,
      productActive: !unavailable,
      companyActive: configured,
      active: configured && !unavailable,
      sizes: const [
        LaundrySize(
            id: 'small',
            nameEn: 'Small',
            nameAr: 'صغير',
            price: 2.5,
            defaultPrice: 2,
            usesDefaultPrice: false),
        LaundrySize(
            id: 'large',
            nameEn: 'Large',
            nameAr: 'كبير',
            price: 4,
            defaultPrice: 4)
      ],
    );

class _Repository extends LaundryRepository {
  List<LaundryCatalogItem> catalog;
  final configs = <LaundryProductConfig>[];
  _Repository(this.catalog) : super(LaundryService(Dio()));
  @override
  Future<List<LaundryCatalogItem>> getCatalog() async => catalog;
  @override
  Future<LaundryCatalogItem> configureProduct(
      String productId, LaundryProductConfig body) async {
    expect(productId, 'product-1');
    configs.add(body);
    final current = catalog.single;
    final result = LaundryCatalogItem(
        id: 'config-1',
        productId: productId,
        source: 'admin',
        nameEn: current.nameEn,
        nameAr: current.nameAr,
        companyActive: body.active,
        active: body.active,
        productActive: current.productActive,
        sizes: current.sizes);
    catalog = [result];
    return result;
  }
}

class _NoProfileFetch implements GetBusinessProfileUseCase {
  int reads = 0;
  @override
  Future<BusinessProfileModel> call() async {
    reads++;
    throw StateError('Catalog should use the loaded company profile');
  }
}

Widget _app(Widget child, {String language = 'en'}) => MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({
        'auth_user': jsonEncode({
          'role': 'manager',
          'permissions': [
            {'name': 'company_profile:update'}
          ]
        })
      }));
  tearDown(() => FlutterSecureStorage.setMockInitialValues({}));
  testWidgets(
      'setup banner explains enablement and tracks cached profile without refetching',
      (tester) async {
    final repo = _Repository([_item(configured: false)]);
    final getter = _NoProfileFetch();
    final profileCubit = CompanyProfileCubit(getter)
      ..setProfile(BusinessProfileModel.fromJson({
        'services': ['carWash']
      }));
    sl.registerSingleton<LaundryRepository>(repo);
    sl.registerSingleton<CompanyProfileCubit>(profileCubit);
    addTearDown(() async {
      await sl.unregister<LaundryRepository>();
      await sl.unregister<CompanyProfileCubit>();
      await profileCubit.close();
    });
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Laundry is not enabled for customers'), findsOneWidget);
    expect(find.text('Blanket'), findsOneWidget);
    profileCubit.setProfile(BusinessProfileModel.fromJson({
      'services': ['carWash', 'laundry']
    }));
    await tester.pumpAndSettle();
    expect(find.text('Laundry is not enabled for customers'), findsNothing);
    expect(getter.reads, 0);
  });

  for (final lang in ['en', 'ar']) {
    testWidgets(
        'managed price editor requires positive company prices in $lang',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      LaundryProductConfig? saved;
      await tester.pumpWidget(_app(
          Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () async {
                        saved = await showDialog<LaundryProductConfig>(
                            context: context,
                            builder: (_) =>
                                LaundryProductEditor(item: _item()));
                      },
                      child: const Text('open')))),
          language: lang));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(AlertDialog)))!;
      expect(find.text(l10n.laundry_admin_product_help), findsOneWidget);
      expect(find.widgetWithText(TextFormField, l10n.laundry_name_en),
          findsNothing);
      expect(find.text(l10n.laundry_use_default_price), findsNothing);
      expect(find.text(l10n.laundry_reset_prices), findsNothing);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).first)
              .controller!
              .text,
          '2.500');
      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).last)
              .controller!
              .text,
          isEmpty);
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text(l10n.price_must_be_greater_than_zero), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.enterText(find.byType(TextFormField).last, '4.250');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text(l10n.price_must_be_greater_than_zero), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '2.750');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();
      expect(saved?.toJson(), {
        'active': true,
        'sizes': [
          {'sizeId': 'small', 'price': 2.75},
          {'sizeId': 'large', 'price': 4.25},
        ]
      });
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('quick enabling a managed item validates prices before saving',
      (tester) async {
    final repo = _Repository([_item(configured: false)]);
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    expect(repo.configs, isEmpty);
    expect(find.byType(LaundryProductEditor), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(AlertDialog)))!;
    await tester.enterText(find.byType(TextFormField).last, '0');
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();
    expect(repo.configs, isEmpty);
    expect(find.text(l10n.price_must_be_greater_than_zero), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, '4.5');
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();
    expect(repo.configs.single.active, isTrue);
    expect(repo.configs.single.sizes.map((size) => size.price), [2.5, 4.5]);
    expect(find.text('Blanket'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('disabling an item preserves prices without opening an editor',
      (tester) async {
    final repo = _Repository([_item()]);
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(repo.configs.single.toJson(), {'active': false});
  });

  testWidgets('admin-disabled item cannot be enabled by company',
      (tester) async {
    final repo = _Repository([_item(unavailable: true)]);
    sl.registerSingleton<LaundryRepository>(repo);
    addTearDown(() => sl.unregister<LaundryRepository>());
    await tester.pumpWidget(_app(const LaundryCatalogScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Unavailable — disabled by admin'), findsOneWidget);
    final toggle =
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).first);
    expect(toggle.onChanged, isNull);
    expect(repo.configs, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
