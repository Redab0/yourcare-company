import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'own catalog lists disabled services while invoices expose only eligible choices',
      () {
    final item = LaundryCatalogItem.fromJson({
      '_id': 'shirt',
      'nameEn': 'Shirt',
      'nameAr': 'قميص',
      'active': true,
      'sizes': [
        {'_id': 'legacy', 'nameEn': 'Large', 'nameAr': 'كبير', 'price': 3}
      ],
      'services': [
        {
          'serviceId': 'clean',
          'nameEn': 'Cleaning',
          'nameAr': 'تنظيف',
          'serviceActive': true,
          'companyActive': true,
          'active': true,
          'defaultPrice': 2,
          'price': 0,
          'usesDefaultPrice': false
        },
        {
          'serviceId': 'iron',
          'nameEn': 'Ironing',
          'nameAr': 'كي',
          'serviceActive': true,
          'companyActive': false,
          'active': false
        },
        {
          'serviceId': 'dry',
          'nameEn': 'Dry cleaning',
          'nameAr': 'تنظيف جاف',
          'serviceActive': false,
          'companyActive': true,
          'active': false,
          'price': 5
        },
      ],
    });
    expect(item.services.length, 3);
    expect(item.invoiceChoices.map((choice) => choice.id), ['legacy']);
    expect(item.invoiceChoices.last.price, 3);
    expect(item.canInvoice, isTrue);
    expect(LaundryServiceConfig.fromService(item.services.first).toJson(),
        {'serviceId': 'clean', 'active': true, 'price': 0.0});
    // Toggling the item must omit this list so server choices remain untouched.
    expect(
        LaundryProductConfig.fromItem(item, active: false)
            .toJson()
            .containsKey('services'),
        isFalse);
  });

  test('an item without an available priced choice is excluded from invoices',
      () {
    const item = LaundryCatalogItem(
        id: 'shirt',
        nameEn: 'Shirt',
        nameAr: 'قميص',
        services: [
          LaundryItemService(
              serviceId: 'clean', nameEn: 'Clean', nameAr: 'تنظيف')
        ]);
    expect(item.canInvoice, isFalse);
    expect(item.invoiceChoices, isEmpty);
  });

  test(
      'typed service discovery and per-item configurations use their endpoints',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    var reads = 0;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      Object payload;
      if (request.method == 'GET') {
        expect(request.path, '/business/my-business/laundry-services');
        reads++;
        payload = [
          {
            '_id': 'clean',
            'nameEn': 'Cleaning',
            'nameAr': 'تنظيف',
            'active': true
          }
        ];
      } else {
        expect(request.path, '/business/my-business/laundry-products/shirt');
        expect(request.method, 'PATCH');
        expect(request.data, {
          'active': true,
          'sizes': [],
          'services': [
            {'serviceId': 'clean', 'active': true, 'price': 0.0},
          ]
        });
        payload = {'_id': 'shirt', 'nameEn': 'Shirt', 'nameAr': 'قميص'};
      }
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {'locale': 'en', 'data': payload}
      }));
    }));
    final repo = LaundryRepository(LaundryService(dio));
    final services = await repo.getServices();
    expect(services.single.id, 'clean');
    await repo.configureProduct(
        'shirt',
        const LaundryProductConfig(active: true, services: [
          LaundryServiceConfig(serviceId: 'clean', active: true, price: 0)
        ]));
    expect(reads, 1);
  });

  test(
      'empty explicit services clears choices and new items can omit a base price',
      () {
    const body = LaundryCatalogMutation(
        nameEn: 'Shirt',
        nameAr: 'قميص',
        unit: 'item',
        active: false,
        services: []);
    expect(body.toJson(), {
      'nameEn': 'Shirt',
      'nameAr': 'قميص',
      'unit': 'item',
      'active': false,
      'sizes': [],
      'services': []
    });
  });
}
