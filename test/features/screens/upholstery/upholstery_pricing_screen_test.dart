import 'dart:async';

import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/get_upholstery_pricing_config_usecase.dart';
import 'package:cleaning_service_driver/domain/usecases/upholstery/update_upholstery_pricing_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_event.dart';
import 'package:cleaning_service_driver/features/screens/upholstery/upholstery_pricing_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _PricingConfig = ({
  List<UpholsteryType> types,
  List<UpholsteryPricingGroup> pricing,
});

const _config = (
  types: <UpholsteryType>[
    UpholsteryType(
      id: 'sofa-id',
      titleEn: 'Sofa',
      titleAr: 'Sofa Arabic',
      sizes: [
        UpholsterySize(
          id: 'single-id',
          titleEn: 'Single seat',
          titleAr: 'Single seat Arabic',
        ),
      ],
    ),
  ],
  pricing: <UpholsteryPricingGroup>[
    UpholsteryPricingGroup(
      upholsteryTypeId: 'sofa-id',
      packages: [
        UpholsteryPricingPackage(
          packageId: 'package-id',
          titleEn: 'Single seat',
          titleAr: 'Single seat Arabic',
          price: 10,
        ),
      ],
    ),
  ],
);

void main() {
  testWidgets('uses only the global loader while pricing is loading',
      (tester) async {
    final completer = Completer<_PricingConfig>();
    final loader = _FakeLoadingController();
    final bloc = _createBloc(
      loader: loader,
      getConfig: _FakeGetConfig(() => completer.future),
    );
    addTearDown(bloc.close);

    await _pumpScreen(tester, bloc);
    await tester.pump();

    expect(loader.showCount, 1);
    expect(loader.hideCount, 0);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    completer.complete(_config);
    await tester.pumpAndSettle();
    expect(loader.hideCount, 1);
  });

  testWidgets('expansion is independent from furniture activation',
      (tester) async {
    final bloc = _createBloc(
      loader: _FakeLoadingController(),
      getConfig: _FakeGetConfig(() async => _config),
    );
    addTearDown(bloc.close);

    await _pumpScreen(tester, bloc);
    await tester.pumpAndSettle();

    const expandKey = ValueKey('upholstery-expand-sofa-id');
    const activeKey = ValueKey('upholstery-active-sofa-id');

    expect(bloc.state.pricing.single.isEnabled, isTrue);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byKey(expandKey));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(bloc.state.pricing.single.isEnabled, isTrue);

    await tester.tap(find.byKey(activeKey));
    await tester.pumpAndSettle();
    expect(bloc.state.pricing.single.isEnabled, isFalse);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.byKey(expandKey));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(bloc.state.pricing.single.isEnabled, isFalse);

    bloc.add(const AddUpholsteryPackage(upholsteryTypeId: 'sofa-id'));
    await tester.pumpAndSettle();
    expect(bloc.state.pricing.single.isEnabled, isFalse);
  });
}

UpholsteryPricingBloc _createBloc({
  required LoadingController loader,
  required GetUpholsteryPricingConfigUseCase getConfig,
}) {
  return UpholsteryPricingBloc(
    loader: loader,
    getConfigUseCase: getConfig,
    updatePricingUseCase: _FakeUpdatePricing(),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  UpholsteryPricingBloc bloc,
) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: bloc,
        child: const UpholsteryPricingScreen(),
      ),
    ),
  );
}

class _FakeGetConfig implements GetUpholsteryPricingConfigUseCase {
  final Future<_PricingConfig> Function() callback;

  _FakeGetConfig(this.callback);

  @override
  Future<_PricingConfig> call() => callback();
}

class _FakeUpdatePricing implements UpdateUpholsteryPricingUseCase {
  @override
  Future<List<UpholsteryPricingGroup>> call(
    UpholsteryPricingRequest request,
  ) async {
    return request.pricing;
  }
}

class _FakeLoadingController implements LoadingController {
  int showCount = 0;
  int hideCount = 0;

  @override
  void show([String tag = 'global']) => showCount++;

  @override
  void hide([String tag = 'global']) => hideCount++;
}
