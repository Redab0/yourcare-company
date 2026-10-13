import 'dart:convert';

import 'package:cleaning_service_driver/components/registration_gift_badge.dart';
import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

const serviceTypes = [
  'houseCleaning',
  'deepCleaning',
  'upholsteryCleaning',
  'carWash',
];

CleaningRequest order(String type, bool? applied,
        {String status = 'confirmed', Map<String, dynamic>? campaign}) =>
    CleaningRequest.fromJson({
      'id': 'GIFT1',
      'type': type,
      'requestStatus': status,
      'totalPrice': 18,
      'createdAt': '2026-10-06T08:00:00Z',
      'updatedAt': '2026-10-06T08:00:00Z',
      'scheduledTime': '2026-10-10T08:00:00Z',
      'customer': <String, dynamic>{},
      'DeepCleaning': <String, dynamic>{},
      'HouseCleaning': <String, dynamic>{},
      'UpholsteryCleaning': <String, dynamic>{},
      'CarWash': <String, dynamic>{},
      'Laundry': {
        'pricingMode': 'pickup_invoice_later',
        'status': 'pending_pickup',
        'paymentStatus': 'unpaid',
      },
      if (applied != null) 'registrationGiftApplied': applied,
      if (campaign != null) 'campaign': campaign,
    });

Map<String, dynamic> gift(String state, {double amount = 1.25}) => {
      'type': 'registration_gift',
      'state': state,
      'discountKwd': amount,
      'registrationGiftApplied': state == 'reserved' || state == 'applied',
    };

void main() {
  test('Laundry remains outside supported registration gift services', () {
    final request = order('laundry', true, campaign: gift('applied'));
    expect(request.hasActiveRegistrationGift, isFalse);
    expect(request.registrationGiftDiscountKwd, isNull);
  });

  for (final type in serviceTypes) {
    test('$type accepts legacy gift flags without inventing a discount', () {
      for (final applied in [true, false, null]) {
        final request = order(type, applied);
        expect(request.registrationGiftApplied, applied == true);
        expect(request.hasActiveRegistrationGift, applied == true);
        expect(request.registrationGiftDiscountKwd, isNull);
        final updated = request.copyWithExtraInvoice(
            extraFees: 3,
            extraFeesDescription: 'Extra service',
            awaitingExtraPayment: true);
        expect(updated.hasActiveRegistrationGift, applied == true);
      }
    });

    test(
        '$type keeps campaign discount and state through serialization/extra invoice',
        () {
      for (final state in ['reserved', 'applied']) {
        final request = order(type, true, campaign: gift(state));
        final roundTrip =
            CleaningRequest.fromJson(jsonDecode(jsonEncode(request)));
        final updated = roundTrip.copyWithExtraInvoice(
            extraFees: 3,
            extraFeesDescription: 'Extra service',
            awaitingExtraPayment: true);
        expect(updated.hasActiveRegistrationGift, isTrue);
        expect(updated.registrationGiftDiscountKwd, 1.25);
        expect(updated.isRegistrationGiftReserved, state == 'reserved');
        expect(updated.campaignSnapshot?.state, state);
      }
    });

    test(
        '$type does not treat eligibility, stale flags, or other campaigns as gifts',
        () {
      for (final state in [
        'released',
        'reversed',
        'expired',
        'ineligible',
        'unknown'
      ]) {
        final request = order(type, true, campaign: gift(state));
        expect(request.hasActiveRegistrationGift, isFalse, reason: state);
        expect(request.registrationGiftDiscountKwd, isNull);
      }
      for (final status in ['cancelled', 'canceled']) {
        expect(order(type, true, status: status).hasActiveRegistrationGift,
            isTrue);
        expect(
            order(type, true, status: status, campaign: gift('applied'))
                .hasActiveRegistrationGift,
            isTrue,
            reason: 'Canceled without refund retains the consumed gift');
        expect(
            order(type, false, status: status, campaign: gift('reversed'))
                .hasActiveRegistrationGift,
            isFalse);
      }
      for (final applied in [false, null]) {
        expect(
            order(type, applied, campaign: gift('applied'))
                .hasActiveRegistrationGift,
            isFalse,
            reason: 'The server order flag remains authoritative');
      }
      for (final campaignType in ['discount', 'cashback']) {
        expect(
            order(type, true,
                    campaign: {...gift('applied'), 'type': campaignType})
                .hasActiveRegistrationGift,
            isFalse);
      }
      for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
            order(type, true, campaign: gift('applied', amount: amount))
                .hasActiveRegistrationGift,
            isFalse);
      }
      expect(
          order(type, true, campaign: {
            ...gift('applied'),
            'registrationGiftApplied': false
          }).hasActiveRegistrationGift,
          isFalse);
      expect(
          order(type, true, status: 'completed', campaign: gift('applied'))
              .hasActiveRegistrationGift,
          isTrue);
    });
  }

  for (final language in ['en', 'ar']) {
    for (final width in [320.0, 800.0]) {
      for (final type in serviceTypes) {
        testWidgets('$type shows gift states at $width in $language',
            (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          Future<AppLocalizations> pump(CleaningRequest request) async {
            await tester.pumpWidget(MaterialApp(
              locale: Locale(language),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                  body:
                      SingleChildScrollView(child: JobTile(request: request))),
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            return AppLocalizations.of(tester.element(find.byType(JobTile)))!;
          }

          var l10n = await pump(order(type, true));
          expect(find.text(l10n.registrationGiftApplied), findsOneWidget);
          final amount = NumberFormat('0.000', language).format(1.25);
          for (final state in ['reserved', 'applied']) {
            l10n = await pump(order(type, true, campaign: gift(state)));
            final label = state == 'reserved'
                ? l10n.registrationGiftReservedAmount(amount)
                : l10n.registrationGiftAppliedAmount(amount);
            expect(find.text(label), findsOneWidget);
            expect(find.text(l10n.registrationGiftApplied), findsNothing);
          }
          for (final request in [
            order(type, false),
            order(type, false, status: 'cancelled'),
            order(type, true, campaign: gift('released')),
            order(type, true, campaign: gift('reversed')),
          ]) {
            await pump(request);
            expect(
                find.descendant(
                    of: find.byType(RegistrationGiftBadge),
                    matching: find.byType(Text)),
                findsNothing);
          }
          l10n = await pump(order(type, false, campaign: {
            'type': 'discount',
            'state': 'applied',
            'discountKwd': 1.25,
          }));
          expect(find.text(l10n.campaignDiscountAppliedAmount(amount)),
              findsOneWidget);
          l10n = await pump(order(type, false, campaign: {
            'type': 'cashback',
            'state': 'reserved',
            'cashbackKwd': 1.25,
          }));
          expect(find.text(l10n.campaignCashbackReservedAmount(amount)),
              findsOneWidget);
        });
      }
    }
  }
}
