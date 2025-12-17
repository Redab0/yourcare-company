import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/auth_user.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_state.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../components/app_button.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late AuthUser user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.personal_information_title),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          context.read<UserProfileBloc>().add(GetUserEvent());

          return FutureBuilder<User?>(
            future: SecureStorageService().getUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return _buildNotLoggedIn();
              } else {
                final user = snapshot.data!;
                return _isEditing
                    ? _buildEditProfile(user, context)
                    : _buildProfile(user);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildProfile(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // TierStepper(
          //   currentLevel: TierLevel.silver, // the user’s current tier
          // ),
          const SizedBox(height: 24),
          Text(
            user.username!,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            user.email!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.phone!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 32),
          _buildProfileSection(
            title: context.l10n.personal_information_title,
            icon: Icons.person_outline,
            onTap: () {
              setState(() {
                _isEditing = true;
                _nameController.text = user.username!;
                _phoneController.text = user.phone ?? '';
              });
            },
          ),

          // const SizedBox(height: 32),
          // LanguageToggleButtons(),
          // const SizedBox(height: 64),
          // AppButton(
          //   text: context.l10n.logout,
          //   onPressed: () {
          //     context.read<AuthBloc>().add(AuthLogoutEvent());
          //   },
          //   isOutlined: true,
          // ),
        ],
      ),
    );
  }

  Widget _buildEditProfile(User user, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.profile_edit_profile,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Profile avatar (non-editable for now)
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(
                  user.username!.substring(0, 1).toUpperCase(),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.signup_name,
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.signup_name;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: context.l10n.signup_phone,
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.signup_phone;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save button
            AppButton(
              text: context.l10n.save_changes,
              onPressed: _saveProfile,
              icon: Icons.save,
            ),
            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: Text(context.l10n.general_cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'You are not logged in',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Log In',
            onPressed: () => context.go('/login'),
            icon: Icons.login,
            isOutlined: true,
          ),
          const SizedBox(height: 8),
          AppButton(
            text: 'Sign Up',
            onPressed: () => context.go('/signup'),
            icon: Icons.person_add,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // In mock mode, just exit edit mode
      setState(() {
        _isEditing = false;
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }
}
