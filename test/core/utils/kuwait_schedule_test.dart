import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/calendar/employee_calendar_response.dart';
import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Map<String, dynamic> appointment(String type, String status) => {
      'id': 'ORDER1',
      'type': type,
      'requestStatus': status,
      'totalPrice': 10,
      'createdAt': '2026-10-08T08:00:00Z',
      'updatedAt': '2026-10-08T08:00:00Z',
      'scheduledTime': '2026-10-10T13:00:00+03:00',
      'customer': <String, dynamic>{},
      'HouseCleaning': {'scheduledTime': '2026-10-10T13:00:00'},
      'DeepCleaning': <String, dynamic>{},
      'CarWash': <String, dynamic>{},
      'UpholsteryCleaning': <String, dynamic>{},
      'Laundry': {
        'pricingMode': 'pickup_invoice_later',
        'status': 'pending_pickup',
        'paymentStatus': 'unpaid'
      },
      'frequencyDates': [
        {'id': 'visit', 'date': '2026-10-10T10:00:00Z', 'status': status}
      ],
    };

void main() {
  test('schedule offsets and legacy Kuwait time resolve to one instant', () {
    for (final value in [
      '2026-10-10T10:00:00Z',
      '2026-10-10T13:00:00+03:00',
      '2026-10-10T06:00:00-04:00',
      '2026-10-10T13:00:00'
    ]) {
      expect(parseKuwaitSchedule(value), DateTime.utc(2026, 10, 10, 10));
      expect(kuwaitWallTime(parseKuwaitSchedule(value)).hour, 13);
    }
    expect(kuwaitWallTime(parseKuwaitSchedule('2026-10-09T22:00:00Z')),
        DateTime.utc(2026, 10, 10, 1));
    expect(kuwaitWallTime(parseKuwaitSchedule('2026-03-08T02:00:00')),
        DateTime.utc(2026, 3, 8, 2));
  });

  test('parent, nested appointment and recurring visit remain identical', () {
    for (final status in ['confirmed', 'inProgress', 'completed', 'canceled']) {
      final request =
          CleaningRequest.fromJson(appointment('houseCleaning', status))
              as HouseKeepingHistory;
      expect(request.scheduledTime, request.detail.scheduledTime);
      expect(request.scheduledTime, request.subRequests!.single.date);
      expect(kuwaitWallTime(request.scheduledTime).hour, 13);
    }
  });

  test('all order types and calendar work parse offsetless Kuwait time', () {
    for (final type in [
      'houseCleaning',
      'deepCleaning',
      'carWash',
      'upholsteryCleaning',
      'laundry'
    ]) {
      final request = CleaningRequest.fromJson(appointment(type, 'confirmed')
        ..['scheduledTime'] = '2026-10-10T13:00:00');
      expect(request.scheduledTime, DateTime.utc(2026, 10, 10, 10),
          reason: type);
    }
    final work = CalendarWork.fromJson({
      'scheduledTime': '2026-10-10T13:00:00',
      'startTime': '2026-10-10T13:00:00+03:00',
      'endTime': '2026-10-10T12:00:00Z'
    });
    expect(work.scheduledTime, work.startTime);
    expect(kuwaitWallTime(work.startTime!).hour, 13);
    expect(kuwaitWallTime(work.endTime!).hour, 15);
  });

  for (final language in ['en', 'ar']) {
    testWidgets(
        'job cards show Kuwait 1 PM independently of device in $language',
        (tester) async {
      Intl.defaultLocale = language;
      for (final type in [
        'houseCleaning',
        'deepCleaning',
        'carWash',
        'laundry'
      ]) {
        final request =
            CleaningRequest.fromJson(appointment(type, 'confirmed'));
        await tester.pumpWidget(MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: JobTile(request: request)),
        ));
        await tester.pumpAndSettle();
        expect(
            find.text(DateFormat('MMM dd, yyyy, HH:mm')
                .format(DateTime.utc(2026, 10, 10, 13))),
            findsOneWidget);
        expect(RequestFmt.time(request.scheduledTime),
            DateFormat.jm().format(DateTime.utc(2026, 10, 10, 13)));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
