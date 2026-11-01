import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';

/// Read-only presentation of occurrence overrides and the legacy option.
abstract final class HousekeepingVisitDuration {
  static double? hours(
      HouseKeepingHistory request, FrequentRequestModel visit) {
    final override = visit.durationHours;
    if (override != null) return override;
    final parent = request.detail.durationHours;
    return parent > 0 && parent <= 24 ? parent.toDouble() : null;
  }

  static String format(double hours, AppLocalizations l10n) =>
      l10n.housekeeping_duration_hours(hours);

  static String? summary(HouseKeepingHistory request, AppLocalizations l10n) {
    final visits = request.subRequests;
    if (visits == null || visits.isEmpty) {
      final parent = request.detail.durationHours;
      return parent > 0 && parent <= 24
          ? format(parent.toDouble(), l10n)
          : null;
    }
    final durations = visits.map((visit) => hours(request, visit)).toSet();
    if (durations.every((duration) => duration == null)) return null;
    if (durations.length > 1) return l10n.housekeeping_duration_varies;
    return format(durations.single!, l10n);
  }
}
