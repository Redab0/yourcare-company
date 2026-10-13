import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cleaning_service_driver/core/api/api_client.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/locale_cubit.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/domain/usecases/auth/login_usecase.dart';
import 'package:cleaning_service_driver/features/screens/documents/documents_screen.dart';
import 'package:cleaning_service_driver/l10n/app_localizations.dart';

// Standalone DEV preview: real authentication and APIs, no mobile push bootstrap.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (ApiClient.baseUrl != ApiClient.dev_baseUrl) {
    throw StateError('The documents preview must use DEV');
  }
  await setupServiceLocator();
  runApp(_PreviewApp());
}

class _PreviewApp extends StatelessWidget {
  _PreviewApp();
  final _router = GoRouter(initialLocation: '/documents', routes: [
    GoRoute(path: '/login', builder: (_, __) => const DocumentsPreviewLogin()),
    GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const DocumentsPreviewLogin()),
    GoRoute(
        path: '/documents',
        builder: (_, __) => const DocumentsScreen(),
        redirect: (_, __) async {
          final storage = SecureStorageService();
          final user = await storage.getUser();
          return await storage.getAccessToken() != null &&
                  ['business_owner', 'manager'].contains(user?.role) &&
                  user?.businessId != null
              ? null
              : '/login';
        }),
  ]);
  @override
  Widget build(BuildContext context) => BlocBuilder<LocaleCubit, Locale>(
      bloc: sl<LocaleCubit>(),
      builder: (_, locale) => MaterialApp.router(
          title: 'YourCare Company - DEV',
          theme: AppTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
          debugShowCheckedModeBanner: false));
}

class DocumentsPreviewLogin extends StatefulWidget {
  final Future<User> Function(LoginCredentials)? signIn;
  final String successLocation;
  const DocumentsPreviewLogin(
      {super.key, this.signIn, this.successLocation = '/documents'});
  @override
  State<DocumentsPreviewLogin> createState() => _PreviewLoginState();
}

enum _LoginError {
  required,
  credentials,
  connection,
  company,
  session,
  rateLimit
}

class _PreviewLoginState extends State<DocumentsPreviewLogin> {
  final _phone = TextEditingController(), _password = TextEditingController();
  bool _busy = false;
  _LoginError? _error;

  String _errorText(BuildContext context) => switch (_error!) {
        _LoginError.required => context.l10n.previewLoginRequired,
        _LoginError.credentials => context.l10n.previewLoginInvalid,
        _LoginError.connection => context.l10n.previewLoginUnavailable,
        _LoginError.company => context.l10n.previewLoginCompanyRequired,
        _LoginError.session => context.l10n.previewLoginSessionFailed,
        _LoginError.rateLimit => context.l10n.previewLoginRateLimit,
      };
  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_busy) return;
    if (_phone.text.trim().isEmpty || _password.text.trim().isEmpty) {
      setState(() => _error = _LoginError.required);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await (widget.signIn ?? sl<LoginUseCase>().call)(
          LoginCredentials(
              phone: _phone.text.trim(), password: _password.text.trim()));
      if (!['business_owner', 'manager'].contains(user.role) ||
          user.businessId == null) {
        if (mounted) setState(() => _error = _LoginError.company);
        return;
      }
      if (mounted) context.go(widget.successLocation);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final failure = status == 429
          ? _LoginError.rateLimit
          : [400, 401, 403, 404].contains(status)
              ? _LoginError.credentials
              : status == null &&
                      error.type == DioExceptionType.unknown &&
                      error.error != null
                  ? _LoginError.session
                  : _LoginError.connection;
      if (mounted) setState(() => _error = failure);
    } catch (_) {
      if (mounted) setState(() => _error = _LoginError.session);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('YourCare Company · DEV'), actions: [
        IconButton(
            tooltip: 'English / العربية',
            onPressed: () => sl<LocaleCubit>().changeLocale(Locale(
                sl<LocaleCubit>().state.languageCode == 'en' ? 'ar' : 'en')),
            icon: const Icon(Icons.language)),
      ]),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset('assets/images/ic_yourcare.png',
                        width: 96, height: 96),
                    const SizedBox(height: 24),
                    TextField(
                        controller: _phone,
                        enabled: !_busy,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: context.l10n.signup_phone,
                            prefixIcon: const Icon(Icons.phone_outlined))),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _password,
                        enabled: !_busy,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: context.l10n.login_password,
                            prefixIcon: const Icon(Icons.lock_outline)),
                        onSubmitted: (_) => _login()),
                    if (_error != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(_errorText(context))),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                        onPressed: _busy ? null : _login,
                        icon: const Icon(Icons.login),
                        label: Text(context.l10n.login_login_label)),
                  ])))));
}
