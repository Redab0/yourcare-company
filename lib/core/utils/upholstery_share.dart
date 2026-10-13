import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';

String furnitureItemsShareText(
  List<UpholsteryCleaningItems> items,
  AppLocalizations l10n,
) {
  final isArabic = l10n.localeName.startsWith('ar');
  return items.map((item) {
    final type = item.type;
    final titles = isArabic
        ? [type?.titleAr, type?.title, type?.titleEn]
        : [type?.titleEn, type?.title, type?.titleAr];
    final title = titles
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .firstOrNull;
    final size = item.size?.localizedTitle(isArabic: isArabic);
    final package = item.package?.localizedTitle(isArabic: isArabic);
    return l10n.request_share_furniture_item(
          title ?? '-',
          size?.isNotEmpty == true ? size! : '-',
          item.quantity?.toString() ?? '-',
        ) +
        (package != null ? '\n$package' : '');
  }).join('\n\n');
}
