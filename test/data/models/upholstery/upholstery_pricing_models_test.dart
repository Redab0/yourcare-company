import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses localized active-category upholstery types', () {
    final category = UpholsteryBusinessCategory.fromJson({
      'type': 'UPHOLSTERY_CLEANING',
      'upholsteryTypes': [
        {
          'id': 'sofa-id',
          'title': 'Sofa',
          'description': 'Sofa cleaning',
          'sizes': const [
            {
              'id': 'single-id',
              'title': 'Single seat',
              'description': 'One seat',
              'price': 5,
            },
          ],
          'materials': const [],
          'conditions': const [],
        },
      ],
    });

    expect(category.isUpholsteryCleaning, isTrue);
    expect(category.upholsteryTypes.single.id, 'sofa-id');
    expect(
      category.upholsteryTypes.single.localizedTitle(isArabic: false),
      'Sofa',
    );
    expect(category.upholsteryTypes.single.sizes.single.id, 'single-id');
    expect(category.upholsteryTypes.single.sizes.single.price, 5);
  });

  test('merges English and Arabic size metadata by backend ID', () {
    const english = [
      UpholsteryType(
        id: 'sofa-id',
        title: 'Sofa',
        sizes: [
          UpholsterySize(
            id: 'single-id',
            title: 'Single seat',
            description: 'One seat',
            price: 5,
          ),
        ],
      ),
    ];
    const arabic = [
      UpholsteryType(
        id: 'sofa-id',
        title: 'كنب',
        sizes: [
          UpholsterySize(
            id: 'single-id',
            title: 'مقعد واحد',
            description: 'مقعد واحد',
            price: 5,
          ),
        ],
      ),
    ];

    final type = mergeLocalizedUpholsteryTypes(english, arabic).single;
    final size = type.sizes.single;
    expect(type.titleEn, 'Sofa');
    expect(type.titleAr, 'كنب');
    expect(size.titleEn, 'Single seat');
    expect(size.titleAr, 'مقعد واحد');
  });

  test('parses package groups with legacy type key fallbacks', () {
    final group = UpholsteryPricingGroup.fromJson({
      'categoryTypeId': 'sofa-id',
      'packages': [
        {
          '_id': 'package-id',
          'titleEn': 'Deep care',
          'titleAr': 'Deep care Arabic',
          'price': 12,
          'discountPercentage': 10,
        },
      ],
    });

    expect(group.upholsteryTypeId, 'sofa-id');
    expect(group.packages.single.packageId, 'package-id');
    expect(group.packages.single.discountPercentage, 10);
    expect(group.isEnabled, isTrue);
  });

  test('disabled pricing parses and serializes independently from its prices',
      () {
    final group = UpholsteryPricingGroup.fromJson({
      'upholsteryTypeId': 'sofa-id',
      'enabled': false,
      'packages': [
        {'_id': 'saved-id', 'price': 1.125, 'discountPercentage': 12.5},
      ],
    });
    expect(group.isEnabled, isFalse);
    expect(group.toJson()['enabled'], isFalse);
    expect(group.packages.single.price, 1.125);
    expect(group.packages.single.packageId, 'saved-id');
    final request = UpholsteryPricingRequest(pricing: [group]).toJson();
    expect((request['pricing'] as List).single['enabled'], isFalse);
    expect(
        (request['pricing'] as List).single['packages'].single['price'], 1.125);
  });

  test('availability requires a real authoritative boolean', () {
    expect(UpholsteryAvailability.fromJson({'available': false}).available,
        isFalse);
    for (final invalid in [null, 'true', 1]) {
      expect(() => UpholsteryAvailability.fromJson({'available': invalid}),
          throwsA(anything));
    }
    expect(const UpdateUpholsteryAvailabilityRequest(available: false).toJson(),
        {'available': false});
  });

  test('pricing request never sends backend or local package IDs', () {
    final request = UpholsteryPricingRequest(
      pricing: [
        UpholsteryPricingGroup(
          upholsteryTypeId: 'sofa-id',
          packages: [
            UpholsteryPricingPackage(
              packageId: 'server-id',
              localId: 'local-id',
              sizeId: 'single-id',
              titleEn: 'Deep care',
              titleAr: 'Deep care Arabic',
              descriptionEn: '',
              price: 12,
              discountPercentage: 10,
            ),
          ],
        ),
      ],
    );

    final json = request.toJson();
    final group = (json['pricing'] as List).single as Map<String, dynamic>;
    final package = (group['packages'] as List).single as Map<String, dynamic>;
    expect(group['upholsteryTypeId'], 'sofa-id');
    expect(package, isNot(contains('packageId')));
    expect(package, isNot(contains('localId')));
    expect(package, isNot(contains('sizeId')));
    expect(group, isNot(contains('isEnabled')));
    expect(group['enabled'], isTrue);
    expect(package, isNot(contains('descriptionEn')));
  });
}
