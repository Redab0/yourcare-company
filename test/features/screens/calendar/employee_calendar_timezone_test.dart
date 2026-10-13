import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/data/models/calendar/employee_calendar_response.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_event.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_state.dart';
import 'package:cleaning_service_driver/features/screens/calendar/employee_calendar_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

class _CalendarBloc extends Cubit<EmployeeCalendarState>
    implements EmployeeCalendarBloc {
  _CalendarBloc(super.initialState);
  @override
  void add(EmployeeCalendarEvent event) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final language in ['en', 'ar']) {
    testWidgets(
        'UTC 10 AM visit occupies Kuwait 1 PM calendar slot in $language',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = kuwaitNow();
      final day = DateTime.utc(now.year, now.month, now.day);
      final start = day.add(const Duration(hours: 10));
      final bloc = _CalendarBloc(EmployeeCalendarState(
          data: EmployeeCalendarResponse(
        calendar: [
          CalendarDay(date: day, works: [
            CalendarWork.fromJson({
              'requestId': 'VISIT-TIME',
              'requestType': 'houseCleaning',
              'requestStatus': 'confirmed',
              'startTime': start.toIso8601String(),
              'scheduledTime': start.toIso8601String(),
              'endTime': start.add(const Duration(hours: 1)).toIso8601String(),
            })
          ])
        ],
      )));
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<EmployeeCalendarBloc>.value(
        value: bloc,
        child: MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const EmployeeCalendarScreen()),
      ));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
          tester.element(find.byType(EmployeeCalendarScreen)))!;
      await tester.tap(find.text(l10n.hourly));
      await tester.pumpAndSettle();
      final visit = find.text('# VISIT-TIME');
      await tester.scrollUntilVisible(visit, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(visit, findsOneWidget);
      final row = find.ancestor(of: visit, matching: find.byType(Row)).first;
      expect(
          find.descendant(
              of: row,
              matching: find.text(DateFormat.jm(language)
                  .format(day.add(const Duration(hours: 13))))),
          findsOneWidget);
      final expectedRange =
          '${DateFormat('hh:mm a', language).format(day.add(const Duration(hours: 13)))} - ${DateFormat('hh:mm a', language).format(day.add(const Duration(hours: 14)))}';
      expect(find.text(expectedRange), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
