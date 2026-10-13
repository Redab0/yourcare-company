import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_presentation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'company category discovery and item metadata use the typed live API envelope',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      expect(request.path, '/business/my-business/laundry-categories');
      expect(request.method, 'GET');
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': [
            {
              '_id': 'tops',
              'nameEn': 'Tops',
              'nameAr': 'علوية',
              'active': true
            },
            {
              '_id': 'old',
              'nameEn': 'Old category',
              'nameAr': 'فئة قديمة',
              'active': false
            },
          ]
        }
      }));
    }));
    final categories =
        await LaundryRepository(LaundryService(dio)).getCategories();
    expect(categories.first.name(true), 'علوية');
    expect(categories.last.active, isFalse);
    final item = LaundryCatalogItem.fromJson({
      '_id': 'shirt',
      'nameEn': 'Shirt',
      'nameAr': 'قميص',
      'categoryId': 'tops',
      'category': categories.first.toJson(),
      'imageUrl': 'https://example.com/shirt.jpg'
    });
    expect(item.category?.id, 'tops');
    expect(item.imageUrl, endsWith('shirt.jpg'));
    final line = LaundryLine.fromJson({
      'itemId': 'shirt',
      'itemName': 'Shirt',
      'quantity': 1,
      'unitPrice': 2,
      'total': 2,
      'categoryId': 'tops',
      'category': categories.first.toJson(),
      'imageUrl': item.imageUrl,
      'serviceId': 'cleaning'
    });
    expect(line.category?.id, 'tops');
    expect(line.serviceId, 'cleaning');
    expect(line.imageUrl, item.imageUrl);
  });

  test('category omission preserves while explicit removal sends null', () {
    const keep = LaundryCatalogMutation(
        nameEn: 'Shirt', nameAr: 'قميص', unit: 'item', active: true);
    const clear = LaundryCatalogMutation(
        nameEn: 'Shirt',
        nameAr: 'قميص',
        unit: 'item',
        active: true,
        removeCategory: true);
    const assign = LaundryCatalogMutation(
        nameEn: 'Shirt',
        nameAr: 'قميص',
        unit: 'item',
        active: true,
        categoryId: 'tops');
    expect(keep.toJson().containsKey('categoryId'), isFalse);
    expect(clear.toJson().containsKey('categoryId'), isTrue);
    expect(clear.toJson()['categoryId'], isNull);
    expect(assign.toJson()['categoryId'], 'tops');
  });

  test(
      'invoice eligibility excludes zero, invalid, unavailable and unpriced selections',
      () {
    for (final price in [0.0, -1.0, double.nan, double.infinity]) {
      expect(
          LaundryCatalogItem(id: 'x', nameEn: 'x', nameAr: 'x', price: price)
              .canInvoice,
          isFalse);
      expect(
          LaundryCatalogItem(id: 'x', nameEn: 'x', nameAr: 'x', sizes: [
            LaundrySize(id: 'size', nameEn: 's', nameAr: 's', price: price)
          ]).canInvoice,
          isFalse);
    }
    expect(laundryMoney(1.333 * 1.125), 1.5);
    expect(
        laundryMoney(laundryMoney(.333 * 1.5) + laundryMoney(.333 * 1.5)), 1);
  });
  test('invoice concurrency keeps an explicit empty or reviewed revision', () {
    const fresh = LaundryInvoiceRequest(items: [], send: false);
    const reviewed = LaundryInvoiceRequest(
        items: [], send: true, expectedRevision: 'revision-one');
    expect(fresh.toJson().containsKey('expectedRevision'), isTrue);
    expect(fresh.toJson()['expectedRevision'], isNull);
    expect(reviewed.toJson()['expectedRevision'], 'revision-one');
    expect(
        const LaundryInvoiceSendRequest(expectedRevision: 'revision-one')
            .toJson(),
        {'expectedRevision': 'revision-one'});
    expect(
        const LaundryInvoiceSendRequest().toJson(), {'expectedRevision': null});
  });
}
