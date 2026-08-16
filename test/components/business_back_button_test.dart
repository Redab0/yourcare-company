import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('pops to the previous screen when route history exists',
      (tester) async {
    final router = _router(initialLocation: '/parent');
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open child'));
    await tester.pumpAndSettle();

    expect(find.text('Child screen'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Parent screen'), findsOneWidget);
  });

  testWidgets('navigates to its fallback when opened without route history',
      (tester) async {
    final router = _router(initialLocation: '/child');
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Parent screen'), findsOneWidget);
  });
}

GoRouter _router({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/parent',
        name: 'parent',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Parent screen'),
                FilledButton(
                  onPressed: () => context.pushNamed('child'),
                  child: const Text('Open child'),
                ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/child',
        name: 'child',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            leading: const BusinessBackButton(fallbackRouteName: 'parent'),
          ),
          body: const Center(child: Text('Child screen')),
        ),
      ),
    ],
  );
}
