import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/repositories/auth/auth_repository.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/login_usecase.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:cleaning_service_driver/main_documents_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FailingAuth extends Fake implements AuthRepository {
  final Object error;
  _FailingAuth(this.error);
  @override
  Future<User> login({required LoginCredentials loginCredentials}) async =>
      throw error;
}

void main() {
  DioException httpError(int status) {
    final request = RequestOptions(path: '/auth/login');
    return DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: request, statusCode: status));
  }

  test('login use case preserves typed failures without credential logging',
      () async {
    final failure = httpError(401);
    await expectLater(
        LoginUseCase(_FailingAuth(failure))
            .call(LoginCredentials(phone: '50000000', password: 'test-only')),
        throwsA(same(failure)));
  });

  Future<void> open(WidgetTester tester,
      Future<User> Function(LoginCredentials) signIn) async {
    final router = GoRouter(initialLocation: '/login', routes: [
      GoRoute(
          path: '/login',
          builder: (_, __) => DocumentsPreviewLogin(signIn: signIn)),
      GoRoute(
          path: '/documents',
          builder: (_, __) => const Scaffold(body: Text('Documents ready'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales));
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), '50000000');
    await tester.enterText(find.byType(TextField).at(1), 'test-only');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
  }

  testWidgets('empty credentials are validated locally', (tester) async {
    await open(tester, (_) async => throw StateError('Must not call API'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your phone number and password.'), findsOneWidget);
  });

  for (final status in [400, 401, 403, 404, 429, 503]) {
    testWidgets('login HTTP $status shows the correct login error',
        (tester) async {
      await open(tester, (_) async => throw httpError(status));
      await submit(tester);
      final message = status == 429
          ? 'Too many sign-in attempts. Please wait before trying again.'
          : status == 503
              ? 'Cannot reach the DEV server. Please try again.'
              : 'Sign-in failed. Check your DEV phone number and password, and that your account is active.';
      expect(find.text(message), findsOneWidget);
      expect(find.textContaining('Unable to load or download documents'),
          findsNothing);
    });
  }

  testWidgets('non-company login explains the access requirement',
      (tester) async {
    await open(tester, (_) async => User(role: 'customer'));
    await submit(tester);
    expect(find.textContaining('This account cannot open the company preview.'),
        findsOneWidget);
  });

  testWidgets('session failure does not leak exception or credentials',
      (tester) async {
    await open(tester,
        (_) async => throw const FormatException('private-session-data'));
    await submit(tester);
    expect(
        find.text(
            'The login session could not be loaded. Refresh the page and try again.'),
        findsOneWidget);
    expect(find.textContaining('private-session-data'), findsNothing);
  });

  testWidgets('company login opens documents', (tester) async {
    await open(tester, (credentials) async {
      expect(credentials.phone, '50000000');
      return User(role: 'business_owner', businessId: 'company-id');
    });
    await submit(tester);
    expect(find.text('Documents ready'), findsOneWidget);
  });
}
