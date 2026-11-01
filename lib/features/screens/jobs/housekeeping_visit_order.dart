import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';

/// Keeps visit identity in the response while ordering only its display indices.
abstract final class HousekeepingVisitOrder {
  static List<int> indices(List<FrequentRequestModel> visits) {
    final order = List<int>.generate(visits.length, (index) => index);
    order.sort((a, b) {
      final left = visits[a];
      final right = visits[b];
      final leftCompleted = left.status == RequestStatus.completed;
      final rightCompleted = right.status == RequestStatus.completed;
      if (leftCompleted != rightCompleted) return leftCompleted ? 1 : -1;

      final leftDate = left.date;
      final rightDate = right.date;
      if (leftDate == null && rightDate != null) return 1;
      if (leftDate != null && rightDate == null) return -1;
      if (leftDate != null && rightDate != null) {
        final byDate =
            kuwaitInstant(leftDate).compareTo(kuwaitInstant(rightDate));
        if (byDate != 0) return byDate;
      }
      return a.compareTo(b);
    });
    return order;
  }
}
