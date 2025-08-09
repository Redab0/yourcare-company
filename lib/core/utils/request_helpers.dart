import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:intl/intl.dart';

/// ----------  value formatters ------------------------------------------------
class RequestFmt {
  static String price(num? p) =>
      p == null ? '—' : '${p.toStringAsFixed(3)} KWD';

  static String yesNo(bool v) => v ? 'Yes' : 'No';

  static String plural(int count, String singular, [String? pluralWord]) =>
      '$count ${count == 1 ? singular : (pluralWord ?? '${singular}s')}';

  static String date(DateTime? d) =>
      d == null ? '—' : DateFormat.yMMMMd().format(d);

  static String time(DateTime? d) =>
      d == null ? '—' : DateFormat.jm().format(d);
}

/// ----------  model‑level convenience  ---------------------------------------
extension HouseKeepingDetailX on HouseKeepingDetail {
  int get cleanersCount => int.tryParse(numberOfCleaners?.title ?? '') ?? 0;

  int get durationHours {
    final m = RegExp(r'\d+').firstMatch(cleaningDuration?.title ?? '');
    return int.tryParse(m?.group(0) ?? '') ?? 0;
  }

  bool get productsIncluded =>
      cleaningProducts?.title!.toLowerCase().contains('eco') ?? false;

  String get fullAddress =>
      '${address?.area} B${address?.block} ${address?.street} H${address?.building} ' ??
      '—';
}

extension DeepCleaningDetailX on DeepCleaningDetail {
  int get bedrooms => int.tryParse(bedroom?.title ?? '') ?? 0;
  int get bathrooms => int.tryParse(bathroom?.title ?? '') ?? 0;
  int get kitchens => int.tryParse(kitchen?.title ?? '') ?? 0;
  int get livingRooms => int.tryParse(livingRoom?.title ?? '') ?? 0;

  String get fullAddress =>
      '${address?.area} B${address?.block} ${address?.street} H${address?.building} ' ??
      '—';
}
