import 'dart:io';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test/features/access/company_permission_panel_test.dart' as panel;
import '../test/features/access/company_menu_widgets_test.dart' as menus;
import '../test/features/access/staff_permission_save_test.dart' as staff;
import '../test/features/access/home_permission_context_test.dart' as home;
import '../test/data/services/company_services_test.dart' as context_transport;
import '../test/helpers/release_expansion_journey.dart';

/// Isolated synthetic fixture only: no main(), Firebase, app DI initialization,
/// live accounts, sockets, or production transport. Secure storage is mocked in
/// each actual-screen journey. Unexpected native HTTP fails before connection.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = NoNetwork());
  tearDownAll(() => HttpOverrides.global = null);
  Future<void> screenshot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  group('filtered company editor', () {
    panel.companyPermissionPanelJourneys(screenshot: screenshot);
  });
  group('actual owner and manager menus', menus.main);
  group('actual staff save boundary', staff.main);
  group('dashboard context recovery', home.main);
  group('dedicated context transport', context_transport.main);
  group('price and campaign boundaries', () {
    providerReleaseJourneys(screenshot: screenshot);
  });
  testWidgets('unmatched native HTTP is blocked', (tester) async {
    expect(() => HttpClient(), throwsStateError);
  });
}
