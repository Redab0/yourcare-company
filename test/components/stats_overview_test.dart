import 'package:cleaning_service_driver/components/stats_overview.dart';
import 'package:cleaning_service_driver/data/viewmodels/stats_vm.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows car-wash and pending request counts', (tester) async {
    final viewModel = StatsVM(
      total: 10,
      pending: 2,
      confirmed: 1,
      inProgress: 1,
      completed: 5,
      canceled: 1,
      deepCleaning: 1,
      houseCleaning: 8,
      upholsteryCleaning: 3,
      carWash: 4,
      totalRevenue: 100,
      totalIncome: 90,
      totalFees: 10,
      totalIncomeAfterFee: 80,
      avgRequestValue: 10,
      carWashRevenue: 40,
      periods: const [],
      monthly: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: StatsOverview(vm: viewModel)),
      ),
    );

    expect(find.text('Car Wash'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
