import 'package:cleaning_service_driver/core/utils/upholstery_share.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/l10n/app_localizations_en.dart';
import 'package:cleaning_service_driver/l10n/app_localizations_ar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final items = [
    UpholsteryCleaningItems.fromJson({
      'type': {'titleEn': 'Sofa', 'titleAr': 'كنبة'},
      'size': {'titleEn': '3 seats', 'titleAr': '٣ مقاعد'},
      'quantity': 2,
    }),
    UpholsteryCleaningItems.fromJson({
      'type': {'titleEn': 'Carpet', 'titleAr': 'سجادة'},
      'size': {'title': 'Large'},
      'quantity': 4,
      'package': {'titleEn': 'Steam cleaning', 'titleAr': 'تنظيف بالبخار'},
    }),
  ];
  test('shares every item with its size and quantity', () {
    expect(
        furnitureItemsShareText(items, AppLocalizationsEn()),
        'Item: Sofa\nSize: 3 seats\nQuantity: 2\n\n'
        'Item: Carpet\nSize: Large\nQuantity: 4\nSteam cleaning');
  });
  test('uses Arabic labels and item names', () {
    expect(
        furnitureItemsShareText(items, AppLocalizationsAr()),
        'الصنف: كنبة\nالحجم: ٣ مقاعد\nالكمية: 2\n\n'
        'الصنف: سجادة\nالحجم: Large\nالكمية: 4\nتنظيف بالبخار');
  });
}
