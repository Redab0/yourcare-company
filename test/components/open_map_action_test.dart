import 'package:cleaning_service_driver/components/open_map_action.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google Maps links require valid non-zero coordinates', () {
    expect(OpenMapAction.googleMapsLink(null, 47), isNull);
    expect(OpenMapAction.googleMapsLink(29, null), isNull);
    expect(OpenMapAction.googleMapsLink(0, 0), isNull);
    expect(OpenMapAction.googleMapsLink(double.nan, 47), isNull);
    expect(OpenMapAction.googleMapsLink(91, 47), isNull);
    expect(OpenMapAction.googleMapsLink(29.312, 47.879),
        'https://www.google.com/maps/search/?api=1&query=29.312,47.879');
  });

  testWidgets('shows a visible map link only for valid coordinates',
      (tester) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            OpenMapAction(latitude: 0, longitude: 0),
            OpenMapAction(latitude: 29.312, longitude: 47.879),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open in Google Maps'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
