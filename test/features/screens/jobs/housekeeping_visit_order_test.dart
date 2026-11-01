import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/screens/jobs/housekeeping_visit_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FrequentRequestModel visit(String id, DateTime? date,
          [RequestStatus? status = RequestStatus.confirmed]) =>
      FrequentRequestModel(id: id, date: date, status: status);

  test('empty and single visit lists remain supported', () {
    expect(HousekeepingVisitOrder.indices([]), isEmpty);
    expect(HousekeepingVisitOrder.indices([visit('only', null)]), [0]);
  });

  test('sorts scrambled dates and same-day appointment times ascending', () {
    final visits = [
      visit('tomorrow', DateTime.utc(2030, 10, 21, 9)),
      visit('late', DateTime.utc(2030, 10, 20, 11)),
      visit('early', DateTime.utc(2030, 10, 20, 9)),
    ];
    expect(HousekeepingVisitOrder.indices(visits), [2, 1, 0]);
  });

  test('completed visits are last and each group is chronological', () {
    final visits = [
      visit('done-later', DateTime.utc(2030, 10, 19), RequestStatus.completed),
      visit('later', DateTime.utc(2030, 10, 22)),
      visit(
          'done-earlier', DateTime.utc(2030, 10, 18), RequestStatus.completed),
      visit('earlier', DateTime.utc(2030, 10, 21)),
    ];
    expect(HousekeepingVisitOrder.indices(visits), [3, 1, 2, 0]);
  });

  test('other statuses retain ordinary date ordering', () {
    final visits = [
      visit('active', DateTime.utc(2030, 10, 25), RequestStatus.inProgress),
      visit('unknown', DateTime.utc(2030, 10, 24), RequestStatus.unknown),
      visit('canceled', DateTime.utc(2030, 10, 23), RequestStatus.canceled),
      visit('cancelled', DateTime.utc(2030, 10, 22), RequestStatus.cancelled),
      visit('pending', DateTime.utc(2030, 10, 21), RequestStatus.pending),
      visit('missing-status', DateTime.utc(2030, 10, 20), null),
    ];
    expect(HousekeepingVisitOrder.indices(visits), [5, 4, 3, 2, 1, 0]);
  });

  test('missing dates follow dated visits within their own status group', () {
    final visits = [
      visit('undated-done', null, RequestStatus.completed),
      visit('undated', null),
      visit('dated-done', DateTime.utc(2030, 10, 20), RequestStatus.completed),
      visit('dated', DateTime.utc(2030, 10, 21)),
    ];
    expect(HousekeepingVisitOrder.indices(visits), [3, 1, 2, 0]);
  });

  test('equal instants and undated ties retain their original indices', () {
    final same = DateTime.utc(2030, 10, 20, 9);
    final visits = [
      visit('missing-first', null),
      visit('dated-first', same),
      visit('dated-second', same),
      visit('missing-second', null),
      visit('done-first', same, RequestStatus.completed),
      visit('done-second', same, RequestStatus.completed),
    ];
    expect(HousekeepingVisitOrder.indices(visits), [1, 2, 0, 3, 4, 5]);
  });

  test('uses Kuwait instants for legacy clocks and explicit offsets', () {
    final visits = [
      visit('legacy-noon', DateTime(2030, 10, 20, 12)),
      visit('utc-noon', DateTime.utc(2030, 10, 20, 9)),
      visit('offset-noon', parseKuwaitSchedule('2030-10-20T12:00:00+03:00')),
      visit('earlier', parseKuwaitSchedule('2030-10-20T10:00:00+02:00')),
    ];
    expect(HousekeepingVisitOrder.indices(visits), [3, 0, 1, 2]);
  });

  test('does not mutate the model list, fields or visit identities', () {
    final visits = List<FrequentRequestModel>.unmodifiable([
      visit('later', DateTime.utc(2030, 10, 21)),
      visit('earlier', DateTime.utc(2030, 10, 20)),
    ]);
    final original = visits.toList();
    final snapshots = visits.map((visit) => visit.toJson()).toList();
    expect(HousekeepingVisitOrder.indices(visits), [1, 0]);
    expect(visits.map((visit) => visit.toJson()).toList(), snapshots);
    for (var index = 0; index < visits.length; index++) {
      expect(identical(visits[index], original[index]), isTrue);
    }
  });
}
