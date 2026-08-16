import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interaction lock remains active until every tour scope finishes', () {
    expect(BusinessShowcaseInteractionLock.isLocked, isFalse);

    BusinessShowcaseInteractionLock.lock('dashboard');
    BusinessShowcaseInteractionLock.lock('inner-journey');
    expect(BusinessShowcaseInteractionLock.isLocked, isTrue);

    BusinessShowcaseInteractionLock.unlock('dashboard');
    expect(BusinessShowcaseInteractionLock.isLocked, isTrue);

    BusinessShowcaseInteractionLock.unlock('inner-journey');
    expect(BusinessShowcaseInteractionLock.isLocked, isFalse);
  });

  testWidgets('active showcase blocks its target and unlocks on dismiss',
      (tester) async {
    const scope = 'interaction-widget-test';
    final targetKey = GlobalKey(debugLabel: 'interaction-widget-target');
    final controller = BusinessShowcaseTourController(scope: scope);
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ValueListenableBuilder<bool>(
          valueListenable: BusinessShowcaseInteractionLock.listenable,
          builder: (context, interactionLocked, _) => Scaffold(
            body: AbsorbPointer(
              absorbing: interactionLocked,
              child: Center(
                child: BusinessShowcaseStep(
                  showcaseKey: targetKey,
                  scope: scope,
                  title: 'Setup',
                  description: 'Configure this item.',
                  index: 0,
                  itemCount: 1,
                  child: FilledButton(
                    key: const ValueKey('showcase-target-button'),
                    onPressed: () => tapCount += 1,
                    child: const Text('Configure'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    controller.start([targetKey]);
    await tester.pump(const Duration(milliseconds: 350));
    expect(BusinessShowcaseInteractionLock.isLocked, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('showcase-target-button')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tapCount, 0);

    controller.dismiss();
    await tester.pumpAndSettle();
    expect(BusinessShowcaseInteractionLock.isLocked, isFalse);
    controller.dispose();
  });
}
