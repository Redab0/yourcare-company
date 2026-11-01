import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';

/// Focus follows server status and appointment instants, not list position.
abstract final class HousekeepingVisitFocus {
  static int? index(HouseKeepingHistory request, {DateTime? now}) {
    if (request.requestStatus == RequestStatus.completed ||
        request.requestStatus == RequestStatus.cancelled ||
        request.requestStatus == RequestStatus.canceled) {
      return null;
    }

    final visits = request.subRequests ?? const <FrequentRequestModel>[];
    final current = visits.indexWhere(
      (visit) => visit.status == RequestStatus.inProgress,
    );
    if (current != -1) return current;

    final instant = (now ?? DateTime.now()).toUtc();
    int? next;
    DateTime? nextTime;
    for (var i = 0; i < visits.length; i++) {
      final visit = visits[i];
      if (visit.date == null ||
          (visit.status != RequestStatus.pending &&
              visit.status != RequestStatus.confirmed)) {
        continue;
      }
      final scheduled = kuwaitInstant(visit.date!);
      if (scheduled.isBefore(instant)) continue;
      if (nextTime == null || scheduled.isBefore(nextTime)) {
        next = i;
        nextTime = scheduled;
      }
    }
    return next;
  }
}
