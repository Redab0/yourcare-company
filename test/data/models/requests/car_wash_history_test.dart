import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarWashHistory', () {
    test('is selected by the cleaning request discriminator', () {
      final request = CleaningRequest.fromJson(_requestJson());

      expect(request, isA<CarWashHistory>());
      expect(request.id, 'CW12');
      expect(request.requestStatus, RequestStatus.confirmed);
    });

    test('infers car wash type from the detail object', () {
      final json = _requestJson()..remove('type');

      expect(CleaningRequest.fromJson(json), isA<CarWashHistory>());
    });

    test('parses extra payment fields and populated vehicle data', () {
      final request = CarWashHistory.fromJson(_requestJson());
      final vehicle = request.detail!.vehicles.single;

      expect(request.extraFees, 2.5);
      expect(request.extraFeesDescription, 'One additional car');
      expect(request.awaitingExtraPayment, isTrue);
      expect(request.extraPaymentUrl, 'https://example.com/pay');
      expect(request.detail!.addressId, 'address-id');
      expect(request.customerSpecialNotes, 'Call before arrival');
      expect(request.showsScheduleInBusinessApp, isTrue);
      expect(vehicle.vehicleTypeId, 'sedan-id');
      expect(vehicle.vehicleTitleEn, 'Sedan');
      expect(vehicle.packageId, 'package-id');
      expect(vehicle.packageTitleEn, 'External wash');
      expect(vehicle.price, 6);
    });

    test('accepts raw string vehicle and package IDs', () {
      final json = _requestJson();
      json['CarWash'] = {
        'vehicles': [
          {
            'vehicleTypeId': 'sedan-id',
            'packageId': 'package-id',
            'price': 6,
          },
        ],
      };

      final vehicle = CarWashHistory.fromJson(json).detail!.vehicles.single;

      expect(vehicle.vehicleTypeId, 'sedan-id');
      expect(vehicle.packageId, 'package-id');
    });

    test('parses flattened company request vehicle and package titles', () {
      final json = _requestJson();
      json['CarWash'] = {
        'vehicles': [
          {
            'vehicleTypeId': 'sedan-id',
            'vehicleTypeTitleEn': 'Sedan',
            'vehicleTypeTitleAr': 'سيدان',
            'packageId': 'package-id',
            'packageTitleEn': 'Full wash',
            'packageTitleAr': 'غسيل شامل',
            'packageDescriptionEn': 'Full interior and exterior cleaning',
            'packageDescriptionAr': 'تنظيف داخلي وخارجي شامل',
            'price': 10,
            'duration': 60,
          },
        ],
      };

      final vehicle = CarWashHistory.fromJson(json).detail!.vehicles.single;

      expect(vehicle.vehicleTitleEn, 'Sedan');
      expect(vehicle.vehicleTitleAr, 'سيدان');
      expect(vehicle.packageTitleEn, 'Full wash');
      expect(vehicle.packageTitleAr, 'غسيل شامل');
      expect(
        vehicle.packageDescriptionEn,
        'Full interior and exterior cleaning',
      );
      expect(vehicle.packageDescriptionAr, 'تنظيف داخلي وخارجي شامل');
    });

    test('only permits invoice creation for confirmed or in-progress jobs', () {
      for (final status in RequestStatus.values) {
        final request = CarWashHistory.fromJson(
          _requestJson(requestStatus: status.toJson()),
        );
        final expected = status == RequestStatus.confirmed ||
            status == RequestStatus.inProgress;

        expect(
          request.canCreateExtraInvoice,
          expected,
          reason: 'Unexpected result for ${status.toJson()}',
        );
      }
    });
  });

  test('extra fee request matches the Swagger body exactly', () {
    const request = AddExtraFeesRequest(
      extraFees: 2.5,
      extraFeesDescription: 'Engine bay cleaning added on site',
    );

    expect(request.toJson(), {
      'extraFees': 2.5,
      'extraFeesDescription': 'Engine bay cleaning added on site',
    });
    expect(request.toJson(), isNot(contains('id')));
    expect(request.toJson(), isNot(contains('requestId')));
  });
}

Map<String, dynamic> _requestJson({String requestStatus = 'confirmed'}) {
  return <String, dynamic>{
    'id': 'CW12',
    'type': 'carWash',
    'requestStatus': requestStatus,
    'totalPrice': 10,
    'createdAt': '2026-08-04T10:00:00.000Z',
    'updatedAt': '2026-08-04T10:30:00.000Z',
    'scheduledTime': '2026-08-04T12:00:00.000Z',
    'customer': {
      'id': 'customer-id',
      'username': 'Bader',
      'phone': '50585208',
      'addresses': [
        {
          'id': 'address-id',
          'area': 'Ghirnata',
          'block': '1',
          'street': '113',
        },
      ],
    },
    'CarWash': {
      'vehicles': [
        {
          'vehicleTypeId': {
            'id': 'sedan-id',
            'titleEn': 'Sedan',
            'titleAr': 'سيدان',
          },
          'packageId': {
            'packageId': 'package-id',
            'titleEn': 'External wash',
            'titleAr': 'غسيل خارجي',
            'price': 6,
          },
        },
      ],
      'addressId': {
        'id': 'address-id',
        'area': 'Ghirnata',
      },
      'areaId': 'area-id',
      'scheduledTime': '2026-08-04T12:00:00.000Z',
      'totalPrice': 10,
      'specialNotes': ' Call before arrival ',
    },
    'extraFees': 2.5,
    'extraFeesDescription': 'One additional car',
    'awaitingExtraPayment': true,
    'extraPaymentUrl': 'https://example.com/pay',
  };
}
