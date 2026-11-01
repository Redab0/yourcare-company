import 'package:cleaning_service_driver/core/utils/housekeeping_visit_duration.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/customer/customer.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/update_request_frequency_request.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

HouseKeepingHistory requestWithVisits(List<FrequentRequestModel> visits,
    {bool knownParent = true}) {
  final date = DateTime.utc(2026, 10, 25, 9);
  return HouseKeepingHistory(
    id: 'preview-order',
    type: 'houseCleaning',
    requestStatus: RequestStatus.confirmed,
    totalPrice: 0,
    createdAt: date,
    updatedAt: date,
    detail: HouseKeepingDetail(
      cleaningDurations: knownParent
          ? HouseKeepingOption(
              option: CleaningItem(titleEn: '3 hours', titleAr: '3 ساعات'))
          : null,
    ),
    scheduledTime: date,
    customer: Customer(username: 'Development customer'),
    subRequests: visits,
  );
}

void main() {
  test(
      'duration is additive, accepts integers/fractions and omits unknown values',
      () {
    for (final hours in [2, 2.5, 24]) {
      final visit = FrequentRequestModel.fromJson({'durationHours': hours});
      expect(visit.durationHours, hours.toDouble());
      expect(visit.toJson()['durationHours'], hours.toDouble());
    }
    for (final value in [
      null,
      '2',
      0,
      -1,
      24.1,
      double.nan,
      double.infinity,
      false,
      {}
    ]) {
      final visit = FrequentRequestModel.fromJson({'durationHours': value});
      expect(visit.durationHours, isNull, reason: '$value');
      expect(visit.toJson(), isNot(contains('durationHours')));
    }
    expect(FrequentRequestModel.fromJson({}).durationHours, isNull);
    expect(FrequentRequestModel(durationHours: 0).durationHours, isNull);
  });

  test('status/date copies preserve duration and write DTO stays unchanged',
      () {
    final visit = FrequentRequestModel.fromJson({
      '_id': 'visit-1',
      'date': '2026-10-26T12:00:00+03:00',
      'status': 'confirmed',
      'durationHours': 2.5,
    });
    final updated = visit.copyWith(status: RequestStatus.inProgress);
    final rescheduled = updated.copyWith(date: DateTime.utc(2026, 10, 27, 9));
    expect(updated.durationHours, 2.5);
    expect(rescheduled.durationHours, 2.5);
    expect(rescheduled.id, 'visit-1');
    expect(rescheduled.date, DateTime.utc(2026, 10, 27, 9));
    expect(
        requestWithVisits([rescheduled])
            .copyWith(extraFees: 1)
            .subRequests!
            .single
            .durationHours,
        2.5);
    expect(
        UpdateRequestFrequencyRequest(
          frequencyDateId: visit.id,
          status: RequestStatus.inProgress,
        ).toJson(),
        {'frequencyDateId': 'visit-1', 'status': 'inProgress'});
  });

  test(
      'occurrence override wins, legacy/invalid uses parent and unknown stays hidden',
      () {
    final request = requestWithVisits([]);
    expect(
        HousekeepingVisitDuration.hours(
            request, FrequentRequestModel(durationHours: 2)),
        2);
    expect(HousekeepingVisitDuration.hours(request, FrequentRequestModel()), 3);
    expect(
        HousekeepingVisitDuration.hours(
            request, FrequentRequestModel.fromJson({'durationHours': -3})),
        3);
    expect(
        HousekeepingVisitDuration.hours(
            requestWithVisits([], knownParent: false), FrequentRequestModel()),
        isNull);
  });

  for (final language in ['en', 'ar']) {
    test('mixed and legacy summaries are localized in $language', () async {
      final l10n = await AppLocalizations.delegate.load(Locale(language));
      final mixed = requestWithVisits([
        FrequentRequestModel(durationHours: 3),
        FrequentRequestModel(durationHours: 2),
      ]);
      expect(HousekeepingVisitDuration.summary(mixed, l10n),
          l10n.housekeeping_duration_varies);
      expect(
          HousekeepingVisitDuration.summary(
              requestWithVisits([FrequentRequestModel()]), l10n),
          l10n.housekeeping_duration_hours(3));
      expect(
          HousekeepingVisitDuration.summary(
              requestWithVisits([
                FrequentRequestModel(durationHours: 2),
                FrequentRequestModel(durationHours: 2)
              ]),
              l10n),
          l10n.housekeeping_duration_hours(2));
      expect(
          HousekeepingVisitDuration.summary(
              requestWithVisits([FrequentRequestModel()], knownParent: false),
              l10n),
          isNull);
      expect(HousekeepingVisitDuration.format(2.5, l10n),
          l10n.housekeeping_duration_hours(2.5));
    });
  }
}
