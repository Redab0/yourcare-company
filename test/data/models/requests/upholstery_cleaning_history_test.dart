import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a package-based direct furniture booking from the customer app',
      () {
    final request = CleaningRequest.fromJson({
      'id': 'FC101',
      'type': 'upholsteryCleaning',
      'requestStatus': 'confirmed',
      'totalPrice': 21.6,
      'createdAt': '2026-08-09T07:00:00.000Z',
      'updatedAt': '2026-08-09T07:00:00.000Z',
      'scheduledTime': '2026-08-09T10:00:00.000Z',
      'businessId': 'business-id',
      'customer': {
        'id': 'customer-id',
        'username': 'Customer',
        'addresses': [
          {
            'id': 'address-id',
            'area': 'Salmiya',
            'street': '1',
            'building': '2',
          },
        ],
      },
      'UpholsteryCleaning': {
        'addressId': 'address-id',
        'scheduledTime': '2026-08-09T10:00:00.000Z',
        'additionalInformation': '',
        'specialNotes': '  Protect the wooden legs  ',
        'items': [
          {
            'upholsteryTypeId': 'sofa-id',
            'typeTitleEn': 'Sofa',
            'typeTitleAr': 'كنب',
            'packageId': 'package-id',
            'packageTitleEn': 'Deep sofa care',
            'packageTitleAr': 'تنظيف عميق للكنب',
            'price': 12,
            'discountPercentage': 10,
            'quantity': 2,
            'calculatedPrice': 21.6,
          },
        ],
      },
    });

    expect(request, isA<UpholsteryCleaningHistory>());
    final furniture = request as UpholsteryCleaningHistory;
    expect(furniture.scheduledTime, DateTime.utc(2026, 8, 9, 10));
    expect(furniture.upholsteryCleaning.address?.area, 'Salmiya');
    expect(furniture.customerSpecialNotes, 'Protect the wooden legs');
    expect(furniture.showsScheduleInBusinessApp, isFalse);
    expect(
      furniture.upholsteryCleaning.toJson(),
      containsPair('specialNotes', '  Protect the wooden legs  '),
    );
    expect(
      furniture.upholsteryCleaning.toJson(),
      isNot(contains('additionalInformation')),
    );

    final item = furniture.upholsteryCleaning.items!.single;
    expect(item.upholsteryTypeId, 'sofa-id');
    expect(item.type?.titleEn, 'Sofa');
    expect(item.packageId, 'package-id');
    expect(item.package?.titleEn, 'Deep sofa care');
    expect(item.package?.discountedPrice, 10.8);
    expect(item.calculatedPrice, 21.6);
    expect(item.isDirectBookingItem, isTrue);
  });

  test('accepts a direct furniture booking without a scheduled time', () {
    final request = CleaningRequest.fromJson({
      'id': 'FC102',
      'type': 'upholsteryCleaning',
      'requestStatus': 'confirmed',
      'totalPrice': 12,
      'createdAt': '2026-08-09T07:00:00.000Z',
      'updatedAt': '2026-08-09T07:00:00.000Z',
      'customer': {
        'id': 'customer-id',
        'username': 'Customer',
        'addresses': <Map<String, dynamic>>[],
      },
      'UpholsteryCleaning': {
        'items': <Map<String, dynamic>>[],
      },
    });

    expect(request, isA<UpholsteryCleaningHistory>());
    final furniture = request as UpholsteryCleaningHistory;
    expect(furniture.scheduledTime, isNull);
    expect(furniture.upholsteryCleaning.scheduledTime, isNull);
  });

  test('reads legacy additionalInformation as direct special notes', () {
    final request = CleaningRequest.fromJson({
      'id': 'FC103',
      'type': 'upholsteryCleaning',
      'requestStatus': 'confirmed',
      'totalPrice': 12,
      'createdAt': '2026-08-09T07:00:00.000Z',
      'updatedAt': '2026-08-09T07:00:00.000Z',
      'customer': <String, dynamic>{},
      'UpholsteryCleaning': {
        'additionalInformation': 'Legacy note',
        'items': <Map<String, dynamic>>[],
      },
    }) as UpholsteryCleaningHistory;

    expect(request.upholsteryCleaning.specialNotes, 'Legacy note');
    expect(request.customerSpecialNotes, 'Legacy note');
  });
}
