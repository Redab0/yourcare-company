import 'dart:convert';
import 'dart:io';
import 'package:cleaning_service_driver/data/models/laundry/laundry_notification.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/statistics/statistics_models.dart';
import 'package:cleaning_service_driver/data/viewmodels/stats_vm.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/features/screens/laundry/laundry_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> laundryFixture(
        {String mode = 'pickup_invoice_later',
        String status = 'picked_up',
        String payment = 'unpaid'}) =>
    {
      'id': 'LD12',
      'type': 'laundry',
      'requestStatus': 'confirmed',
      'totalPrice': 8,
      'createdAt': '2026-10-05T10:00:00Z',
      'updatedAt': '2026-10-05T10:00:00Z',
      'customer': {'id': 'customer1', 'username': 'Customer'},
      'address': {
        'id': 'address1',
        'area': 'Kuwait',
        'latitude': 29.3,
        'longitude': 47.9
      },
      'Laundry': {
        'pricingMode': mode,
        'status': status,
        'paymentStatus': payment,
        'addressId': 'address1',
        'areaId': 'area1',
        'scheduledTime': '2026-10-06T10:00:00Z',
        'numberOfBags': 2,
        'specialNotes': 'Please ring',
        'items': [],
        'invoice': {
          'status': payment == 'paid' ? 'paid' : 'draft',
          'subtotal': 7,
          'pickupFee': 1,
          'total': 8,
          'items': [
            {
              'itemId': 'blanket',
              'itemName': 'Blanket',
              'itemNameAr': 'بطانية',
              'sizeId': 'large',
              'size': 'Large',
              'sizeAr': 'كبير',
              'unit': 'item',
              'quantity': 2,
              'unitPrice': 2.5,
              'total': 5
            },
            {
              'itemId': 'shirt',
              'itemName': 'Shirt',
              'unit': 'item',
              'quantity': 4,
              'unitPrice': .5,
              'total': 2
            },
          ]
        }
      },
    };

void main() {
  test(
      'real backend managed catalog fixture resolves admin and company pricing',
      () {
    final payload = jsonDecode(
        File('test/fixtures/laundry/managed_catalog.json')
            .readAsStringSync()) as List;
    final item =
        LaundryCatalogItem.fromJson(Map<String, dynamic>.from(payload.single));
    expect(item.isManaged, isTrue);
    expect(item.productId, isNot(item.id));
    expect(item.enabledForCompany, isTrue);
    expect(item.productActive, isTrue);
    expect(item.configured, isTrue);
    expect(item.sizes.first.defaultPrice, .5);
    expect(item.sizes.first.usesDefaultPrice, isTrue);
    expect(item.sizes.last.defaultPrice, 1.5);
    expect(item.sizes.last.price, 1.25);
    expect(item.sizes.last.usesDefaultPrice, isFalse);
    expect(LaundryProductConfig.fromItem(item, active: false).toJson(),
        {'active': false});
  });

  test(
      'Laundry notification routes require a request and preserve chat routing',
      () {
    expect(
        laundryRequestIdFromNotification(
            {'requestType': 'laundry', 'requestId': 'LD12'}),
        'LD12');
    expect(
        laundryRequestIdFromNotification({
          'notificationType': 'laundry_status_changed',
          'requestId': ' LD12 '
        }),
        'LD12');
    expect(
        laundryRequestIdFromNotification({
          'requestType': 'laundry',
          'requestId': 'LD12',
          'conversationId': 'chat'
        }),
        isNull);
    expect(
        laundryRequestIdFromNotification({'requestType': 'laundry'}), isNull);
    expect(
        laundryRequestIdFromNotification(
            {'requestType': 'carWash', 'requestId': 'CW12'}),
        isNull);
  });

  test('profile service update keeps previously enabled services', () {
    final body = UpdateBusinessProfileModel(
        null, null, null, null, null, null, null, null, ['area1'],
        services: ['deepCleaning', 'laundry']);
    expect(body.toJson()['services'], ['deepCleaning', 'laundry']);
    expect(body.toJson()['areas'], ['area1']);
  });

  test('company reports expose Laundry count and revenue', () {
    final vm = StatsVM.fromResponse(StatisticsResponse.fromJson({
      'overview': {'laundryRequests': 7, 'laundryRevenue': 12.5},
      'periodStats': [
        {'period': '2026-10', 'laundryCount': 4, 'laundryRevenue': 6.5}
      ],
    }));
    expect(vm.laundry, 7);
    expect(vm.laundryRevenue, 12.5);
    expect(vm.periods.single.laundryCount, 4);
    expect(vm.periods.single.laundryRevenue, 6.5);
  });

  test(
      'shared request parsing preserves laundry snapshots, pickup and readable id',
      () {
    final request =
        CleaningRequest.fromJson(laundryFixture()) as LaundryHistory;
    expect(request.id, 'LD12');
    expect(request.requestStatus, RequestStatus.confirmed);
    expect(request.pickupAddress?.area, 'Kuwait');
    expect(request.scheduledTime, DateTime.utc(2026, 10, 6, 10));
    expect(request.detail.numberOfBags, 2);
    expect(request.detail.displayedItems.first.name(true), 'بطانية');
    expect(request.detail.displayedItems.first.sizeName(true), 'كبير');
    expect(request.detail.invoice?.total, 8);
    expect(request.detail.canEditInvoice, isTrue);
    expect(request.detail.canSendInvoice, isTrue);
  });

  test(
      'bag requests can be priced immediately and legacy pickups stay editable',
      () {
    for (final status in ['pending_pickup', 'pickup_accepted', 'picked_up']) {
      final detail =
          LaundryHistory.fromJson(laundryFixture(status: status)).detail;
      expect(detail.canEditInvoice, isTrue, reason: status);
      expect(detail.canSendInvoice, isTrue, reason: status);
      expect(detail.displayStatus, 'pending_pickup');
      expect(
          detail.nextStatuses, status == 'picked_up' ? isEmpty : ['cancelled']);
    }
    for (final status in ['invoice_sent', 'confirmed', 'paid', 'completed']) {
      final detail =
          LaundryHistory.fromJson(laundryFixture(status: status)).detail;
      expect(detail.canEditInvoice, isFalse, reason: status);
      expect(detail.canSendInvoice, isFalse, reason: status);
    }
  });

  test('paid current and legacy orders go directly from Confirmed to Completed',
      () {
    for (final mode in ['pickup_invoice_later', 'cart_pay_upfront']) {
      for (final status in [
        'pending_pickup',
        'pickup_accepted',
        'picked_up',
        'invoice_sent',
        'confirmed',
        'paid',
        'in_progress',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered'
      ]) {
        final order = LaundryHistory.fromJson(
            laundryFixture(mode: mode, status: status, payment: 'paid'));
        expect(order.detail.displayStatus, 'confirmed',
            reason: '$mode/$status');
        expect(order.detail.displayRequestStatus, RequestStatus.confirmed);
        expect(order.detail.nextStatuses, ['completed', 'cancelled']);
        expect(order.detail.jobTab, 0);
        expect(order.detail.canEditInvoice, isFalse);
        expect((order.toJson()['Laundry'] as Map)['status'], status,
            reason: 'Presentation must preserve the raw lifecycle history');
      }
    }
  });

  test('unpaid orders never complete or expose obsolete processing actions',
      () {
    for (final mode in ['pickup_invoice_later', 'cart_pay_upfront']) {
      for (final status in [
        'pending_pickup',
        'pickup_accepted',
        'picked_up',
        'invoice_sent',
        'confirmed',
        'paid',
        'in_progress',
        'ready_for_delivery',
        'out_for_delivery',
        'delivered'
      ]) {
        final detail =
            LaundryHistory.fromJson(laundryFixture(mode: mode, status: status))
                .detail;
        expect(
            detail.nextStatuses,
            ['pending_pickup', 'pickup_accepted'].contains(status)
                ? ['cancelled']
                : isEmpty);
        expect(detail.jobTab, 0);
        if (mode == 'cart_pay_upfront') {
          expect(detail.displayStatus, 'invoice_sent');
          expect(detail.canEditInvoice, isFalse);
        }
      }
    }
  });

  test('completion requires both paid invoice and payment, with a known status',
      () {
    for (final invoiceStatus in [null, 'draft', 'sent', 'paid']) {
      for (final payment in [
        'unpaid',
        'pending',
        'paid',
        'refunded',
        'failed'
      ]) {
        final fixture = laundryFixture(status: 'confirmed', payment: payment);
        final detail = fixture['Laundry'] as Map;
        if (invoiceStatus == null) {
          detail.remove('invoice');
        } else {
          (detail['invoice'] as Map)['status'] = invoiceStatus;
        }
        final parsed = LaundryHistory.fromJson(fixture).detail;
        if (payment == 'paid' && invoiceStatus == null) {
          expect(parsed.displayStatus, 'confirmed');
          expect(parsed.nextStatuses, isEmpty);
        }
        expect(parsed.nextStatuses.contains('completed'),
            payment == 'paid' && invoiceStatus == 'paid',
            reason: '$payment/$invoiceStatus');
      }
    }
    final unknown = LaundryHistory.fromJson(
            laundryFixture(status: 'future_status', payment: 'paid'))
        .detail;
    expect(unknown.displayStatus, 'future_status');
    expect(unknown.nextStatuses, isEmpty);
    final unpaidUnknown = LaundryHistory.fromJson(
            laundryFixture(mode: 'cart_pay_upfront', status: 'future_status'))
        .detail;
    expect(unpaidUnknown.displayStatus, 'future_status');
    expect(unpaidUnknown.nextStatuses, isEmpty);
    expect(unpaidUnknown.isAwaitingPayment, isFalse);
  });

  test('terminal and refunded bag orders cannot price or complete', () {
    for (final status in [
      'pending_pickup',
      'pickup_accepted',
      'picked_up',
      'invoice_sent',
      'confirmed',
      'completed',
      'pickup_rejected',
      'cancelled'
    ]) {
      final detail = LaundryHistory.fromJson(
              laundryFixture(status: status, payment: 'refunded'))
          .detail;
      expect(detail.canEditInvoice, isFalse, reason: status);
      expect(detail.canSendInvoice, isFalse, reason: status);
      expect(detail.nextStatuses, isNot(contains('completed')));
    }
    for (final status in ['completed', 'pickup_rejected', 'cancelled']) {
      final detail = LaundryHistory.fromJson(
              laundryFixture(status: status, payment: 'paid'))
          .detail;
      expect(detail.displayStatus, status);
      expect(detail.jobTab, status == 'completed' ? 2 : 3);
      expect(detail.nextStatuses, isEmpty);
      expect(detail.canEditInvoice, isFalse);
    }
  });

  test(
      'shared terminal request status wins without changing raw laundry history',
      () {
    for (final shared in ['completed', 'cancelled', 'canceled']) {
      for (final status in ['pending_pickup', 'in_progress', 'confirmed']) {
        for (final payment in ['unpaid', 'paid']) {
          final fixture = laundryFixture(status: status, payment: payment);
          fixture['requestStatus'] = shared;
          final order = LaundryHistory.fromJson(fixture);
          final terminal = shared == 'completed' ? 'completed' : 'cancelled';
          expect(order.displayDetail.displayStatus, terminal);
          expect(order.displayDetail.jobTab, shared == 'completed' ? 2 : 3);
          expect(order.displayDetail.nextStatuses, isEmpty);
          expect(order.displayDetail.canEditInvoice, isFalse);
          expect(order.displayDetail.canSendInvoice, isFalse);
          expect(order.detail.status, status);
          expect((order.toJson()['Laundry'] as Map)['status'], status);
          expect(order.displayDetail.numberOfBags, order.detail.numberOfBags);
          expect(order.displayDetail.invoice, same(order.detail.invoice));
        }
      }
    }
  });

  test('terminal and refunded orders never ask the company to await payment',
      () {
    for (final status in ['completed', 'pickup_rejected', 'cancelled']) {
      for (final payment in ['unpaid', 'paid', 'refunded']) {
        final detail = LaundryHistory.fromJson(laundryFixture(
                mode: 'cart_pay_upfront', status: status, payment: payment))
            .detail;
        expect(detail.isAwaitingPayment, isFalse);
      }
    }
    expect(
        LaundryHistory.fromJson(laundryFixture(
                mode: 'cart_pay_upfront', status: 'pending_pickup'))
            .detail
            .isAwaitingPayment,
        isTrue);
  });

  test('catalog mutations preserve size identity and omit inapplicable fields',
      () {
    const body = LaundryCatalogMutation(
        nameEn: 'Blanket',
        nameAr: 'بطانية',
        unit: 'item',
        active: false,
        sizes: [
          LaundrySize(id: 'size1', nameEn: 'Large', nameAr: 'كبير', price: 0)
        ]);
    expect(body.toJson(), {
      'nameEn': 'Blanket',
      'nameAr': 'بطانية',
      'unit': 'item',
      'active': false,
      'sizes': [
        {'_id': 'size1', 'nameEn': 'Large', 'nameAr': 'كبير', 'price': 0.0}
      ]
    });
    const invoice = LaundryInvoiceRequest(
        items: [LaundryInvoiceSelection(itemId: 'curtain', quantity: 1.5)],
        send: false);
    expect(invoice.toJson()['items'], [
      {'itemId': 'curtain', 'quantity': 1.5}
    ]);
    expect(invoice.toJson().containsKey('unitPrice'), isFalse);
  });

  test('numeric inputs enforce finite precision and backend bounds', () {
    for (final value in ['NaN', 'Infinity', '-1', '1.2345', '10000.001']) {
      expect(laundryNumber(value), isNull);
    }
    expect(laundryNumber('0'), 0);
    expect(laundryNumber('0', positive: true), isNull);
    expect(laundryNumber('1.125', positive: true), 1.125);
    expect(laundryNumber('10000'), 10000);
    expect(laundryNumber('٢٫٥', positive: true), 2.5);
    expect(laundryNumber('۱۲٫۱۲۵', positive: true), 12.125);
    expect(laundryNumber('٠', positive: true), isNull);
    expect(laundryNumber('٢٫٥٥٥٥'), isNull);
    expect(laundryNumber('١٬٢'), isNull);
  });
}
