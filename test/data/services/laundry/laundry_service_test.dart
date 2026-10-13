import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/data/services/laundry/laundry_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../models/laundry/laundry_models_test.dart' show laundryFixture;

void main() {
  test('managed products use company overrides endpoint and can reset defaults',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final bodies = <Object?>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      expect(request.method, 'PATCH');
      expect(request.path, '/business/my-business/laundry-products/product-1');
      bodies.add(request.data);
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': {
            '_id': 'config-1',
            'productId': 'product-1',
            'source': 'admin',
            'nameEn': 'Shirt',
            'nameAr': 'قميص',
            'price': 2,
            'defaultPrice': 1.5,
            'usesDefaultPrice': false,
            'active': true,
            'companyActive': true,
            'productActive': true,
            'configured': true,
            'sizes': []
          }
        }
      }));
    }));
    final repository = LaundryRepository(LaundryService(dio));
    final item = await repository.configureProduct(
        'product-1', const LaundryProductConfig(active: true, price: 2));
    expect(item.isManaged, isTrue);
    expect(item.id, 'config-1');
    expect(item.defaultPrice, 1.5);
    expect(item.usesDefaultPrice, isFalse);
    await repository.configureProduct(
        'product-1', const LaundryProductConfig(active: false));
    expect(bodies, [
      {'active': true, 'price': 2.0, 'sizes': []},
      {'active': false, 'sizes': []},
    ]);
  });

  test('bulk prices sends one typed mixed-item request and parses all rows',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    var calls = 0;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      calls++;
      expect(request.method, 'PATCH');
      expect(request.path, '/business/my-business/laundry-catalog/prices');
      expect(request.data, {
        'items': [
          {'productId': 'product-1', 'price': 2.5},
          {
            'itemId': 'custom-1',
            'services': [
              {'serviceId': 'wash', 'active': true, 'price': 3.0}
            ]
          },
        ]
      });
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': [
            {
              '_id': 'config-1',
              'productId': 'product-1',
              'source': 'admin',
              'nameEn': 'Shirt',
              'nameAr': 'قميص',
              'price': 2.5
            },
            {
              '_id': 'custom-1',
              'source': 'company',
              'nameEn': 'Blanket',
              'nameAr': 'بطانية',
              'active': false
            },
          ]
        }
      }));
    }));
    final items = await LaundryRepository(LaundryService(dio))
        .updatePrices(const LaundryBulkPricesRequest(items: [
      LaundryItemPriceUpdate(productId: 'product-1', price: 2.5),
      LaundryItemPriceUpdate(itemId: 'custom-1', services: [
        LaundryServiceConfig(serviceId: 'wash', active: true, price: 3),
      ]),
    ]));
    expect(calls, 1);
    expect(items.map((item) => item.id), ['config-1', 'custom-1']);
    expect(items.first.price, 2.5);
    expect(items.last.active, isFalse);
  });

  test('bulk availability serializes strict true false and omitted status',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    var calls = 0;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      calls++;
      expect(request.method, 'PATCH');
      expect(request.path, '/business/my-business/laundry-catalog/prices');
      expect(request.data, {
        'items': [
          {'productId': 'product-1', 'active': false},
          {'itemId': 'custom-1', 'active': true, 'price': 2.5},
          {'itemId': 'custom-2', 'price': 3.0},
        ]
      });
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': [
            {
              '_id': 'product-1',
              'productId': 'product-1',
              'source': 'admin',
              'nameEn': 'Shirt',
              'nameAr': 'قميص',
              'companyActive': false,
              'active': false
            },
            {
              '_id': 'custom-1',
              'nameEn': 'Blanket',
              'nameAr': 'بطانية',
              'active': true,
              'price': 2.5
            },
            {
              '_id': 'custom-2',
              'nameEn': 'Curtain',
              'nameAr': 'ستارة',
              'active': false,
              'price': 3.0
            },
          ]
        }
      }));
    }));
    final items = await LaundryRepository(LaundryService(dio))
        .updatePrices(const LaundryBulkPricesRequest(items: [
      LaundryItemPriceUpdate(productId: 'product-1', active: false),
      LaundryItemPriceUpdate(itemId: 'custom-1', active: true, price: 2.5),
      LaundryItemPriceUpdate(itemId: 'custom-2', price: 3),
    ]));
    expect(calls, 1);
    expect(items.map((item) => item.enabledForCompany), [false, true, false]);
  });

  test('availability changes preserve every explicit size price override', () {
    final item = LaundryCatalogItem.fromJson({
      '_id': 'config-1',
      'productId': 'product-1',
      'source': 'admin',
      'nameEn': 'Blanket',
      'nameAr': 'بطانية',
      'active': true,
      'sizes': [
        {
          '_id': 's',
          'nameEn': 'Small',
          'nameAr': 'صغير',
          'price': 2,
          'defaultPrice': 1,
          'usesDefaultPrice': false
        },
        {
          '_id': 'l',
          'nameEn': 'Large',
          'nameAr': 'كبير',
          'price': 3,
          'defaultPrice': 3,
          'usesDefaultPrice': true
        },
      ]
    });
    expect(LaundryProductConfig.fromItem(item, active: false).toJson(),
        {'active': false});
  });

  test('invoice draft sends only catalog selections and server resolves prices',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      expect(request.method, 'POST');
      expect(request.path, '/requests/laundry/LD12/invoice');
      expect(request.data, {
        'expectedRevision': 'reviewed-draft',
        'items': [
          {'itemId': 'blanket', 'sizeId': 'large', 'quantity': 2.0}
        ],
        'pickupFee': 1.0,
        'deliveryFee': 0.0,
        'discount': 0.0,
        'send': false
      });
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {'locale': 'en', 'data': laundryFixture()}
      }));
    }));
    final order = await LaundryRepository(LaundryService(dio)).saveInvoice(
        'LD12',
        const LaundryInvoiceRequest(
            expectedRevision: 'reviewed-draft',
            items: [
              LaundryInvoiceSelection(
                  itemId: 'blanket', sizeId: 'large', quantity: 2)
            ],
            pickupFee: 1,
            send: false));
    expect(order.detail.invoice?.status, 'draft');
  });

  test('status and draft-send use their own company endpoints', () async {
    final dio = Dio();
    addTearDown(dio.close);
    final paths = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      paths.add(request.path);
      if (request.path.endsWith('/status')) {
        expect(request.method, 'PATCH');
        expect(request.data, {'status': 'completed'});
      } else {
        expect(request.method, 'POST');
        expect(request.data, {'expectedRevision': 'reviewed-revision'});
      }
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {'locale': 'en', 'data': laundryFixture()}
      }));
    }));
    final repository = LaundryRepository(LaundryService(dio));
    await repository.updateStatus('LD12', 'completed');
    await repository.sendInvoice('LD12', expectedRevision: 'reviewed-revision');
    expect(paths, [
      '/requests/laundry/LD12/status',
      '/requests/laundry/LD12/invoice/send'
    ]);
  });

  test('catalog item parsing accepts serialized ids and inactive custom units',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      expect(request.path, '/business/my-business/laundry-catalog');
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'success': true,
        'message': 'Success',
        'data': {
          'locale': 'en',
          'data': [
            {
              '_id': 'curtain',
              'nameEn': 'Curtain',
              'nameAr': 'ستارة',
              'unit': 'custom',
              'unitLabel': 'panel',
              'price': 1.25,
              'active': false,
              'sizes': []
            }
          ]
        }
      }));
    }));
    final catalog = await LaundryRepository(LaundryService(dio)).getCatalog();
    expect(catalog.single.id, 'curtain');
    expect(catalog.single.active, isFalse);
    expect(catalog.single.unitLabel, 'panel');
  });
}
