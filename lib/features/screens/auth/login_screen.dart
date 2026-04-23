import 'package:cleaning_service_driver/components/app_button.dart';
import 'package:cleaning_service_driver/core/utils/app_remote_config.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/validators/validators.dart';
import 'package:cleaning_service_driver/data/models/auth/login_credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _showRegister = true;

  @override
  void initState() {
    super.initState();
    _loadRegisterFlag();
  }

  Future<void> _loadRegisterFlag() async {
    await AppRemoteConfig.instance.initialize();
    if (!mounted) return;
    setState(() {
      _showRegister = AppRemoteConfig.instance.showRegister;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final loginCredentials = LoginCredentials(
        phone: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final authBloc = context.read<AuthBloc>();
      authBloc.add(
        LoginEvent(loginCredentials: loginCredentials),
      );
    }
  }

  Future<void> _openJoinUsPage() async {
    const uri = 'https://www.yourcarehere.com/#/contact';
    final launched = await launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.inAppBrowserView,
    );
    if (!launched && mounted) {
      context.showErrorToast();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go('/home');
            } else if (state is AuthError) {
              context.showErrorToast();
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // Logo placeholder
                        Image.asset(
                          'assets/images/ic_yourcare.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.welcome,
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.login_login_to_continue,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Email field
                        TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: context.l10n.signup_phone,
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: context.l10n.login_password,
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 24),
                        // Login button
                        AppButton(
                          text: context.l10n.login_login_label,
                          onPressed: _login,
                          isLoading: state is AuthLoading,
                        ),
                        if (_showRegister) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.login_no_account,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            text: context.l10n.login_apply_to_become_provider,
                            onPressed: _openJoinUsPage,
                            isOutlined: true,
                            isDisabled: state is AuthLoading,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
}
