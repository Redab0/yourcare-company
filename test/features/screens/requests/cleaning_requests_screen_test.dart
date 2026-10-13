import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/features/screens/requests/cleaning_requests_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('available requests render a car-wash card without a type cast',
      (tester) async {
    final request = CarWashHistory(
      id: 'CW3',
      requestStatus: RequestStatus.pending,
      totalPrice: 8,
      createdAt: DateTime.utc(2026, 8, 21),
      updatedAt: DateTime.utc(2026, 8, 21),
      customer: Customer(),
      detail: const CarWashHistoryDetail(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AvailableRequestCard(
            request: request,
            hidePriceForWorker: false,
          ),
        ),
      ),
    );

    expect(find.byType(JobTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
