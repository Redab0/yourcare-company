import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';
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
  int get cleanersCount =>
      numberOfCleaners?.quantity ??
      int.tryParse(numberOfCleaners?.option?.title ?? '') ??
      0;

  int get durationHours {
    final m =
        RegExp(r'\d+').firstMatch(cleaningDurations?.option?.title ?? '');
    return int.tryParse(m?.group(0) ?? '') ?? 0;
  }

  bool get productsIncluded =>
      cleaningProducts?.option?.title?.toLowerCase().contains('eco') ?? false;

  String get fullAddress {
    final parts = <String>[
      if ((address?.area ?? '').isNotEmpty) address!.area!,
      if ((address?.block ?? '').isNotEmpty) 'B${address!.block}',
      if ((address?.street ?? '').isNotEmpty) address!.street!,
      if ((address?.building ?? '').isNotEmpty) 'H${address!.building}',
    ];
    return parts.isNotEmpty ? parts.join(' ') : '—';
  }
}

extension DeepCleaningDetailX on DeepCleaningDetail {
  int get bedrooms =>
      _countFromItem(departmentSelection?.bedrooms ?? bedroom);
  int get bathrooms =>
      _countFromItem(departmentSelection?.bathrooms ?? bathroom);
  int get kitchens =>
      _countFromItem(departmentSelection?.kitchens ?? kitchen);
  int get livingRooms =>
      _countFromItem(departmentSelection?.livingRooms ?? livingRoom);

  String get propertyTypeTitle =>
      departmentSelection?.departmentType?.title ??
      departmentType?.title ??
      '—';

  CleaningItem? get sizeOption => departmentSelection?.sizeOptions;

  bool get includeKitchen => departmentSelection?.kitchenCheckbox ?? false;
  bool get includeBathroom => departmentSelection?.bathroomCheckbox ?? false;
  bool get includeFurniture => departmentSelection?.furnitureCheckbox ?? false;

  double? get calculatedPrice => departmentSelection?.calculatedPrice;

  String? get notes {
    if (departmentSelection?.additionalInformation?.trim().isNotEmpty ??
        false) {
      return departmentSelection!.additionalInformation!.trim();
    }
    if (additionalInformation?.trim().isNotEmpty ?? false) {
      return additionalInformation!.trim();
    }
    return null;
  }

  String get fullAddress {
    final parts = <String>[
      if ((address?.area ?? '').isNotEmpty) address!.area!,
      if ((address?.block ?? '').isNotEmpty) 'B${address!.block}',
      if ((address?.street ?? '').isNotEmpty) address!.street!,
      if ((address?.building ?? '').isNotEmpty) 'H${address!.building}',
    ];
    return parts.isNotEmpty ? parts.join(' ') : '—';
  }

  bool get isCommercialOrOffice {
    final title = propertyTypeTitle.toLowerCase();
    return title.contains('office') ||
        title.contains('commercial') ||
        title.contains('مكتب') ||
        title.contains('تجاري');
  }

  bool get isOtherType {
    final title = propertyTypeTitle.toLowerCase();
    return title.contains('other') ||
        title.contains('آخر') ||
        title.contains('اخرى') ||
        title.contains('غير ذلك');
  }

  bool get isApartmentOrHouse => !isCommercialOrOffice && !isOtherType;

  int _countFromItem(CleaningItem? item) {
    final raw = item?.title;
    if (raw == null) return 0;
    final normalized = raw.replaceAllMapped(RegExp('[٠-٩]'), (m) {
      const digits = {'٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9'};
      return digits[m.group(0)] ?? '';
    });
    final match = RegExp(r'\d+').firstMatch(normalized);
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }
}
