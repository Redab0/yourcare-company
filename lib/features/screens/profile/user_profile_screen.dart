import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/app_remote_config.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/auth_user.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/auth/auth_state.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _showDeactivateAccount = true;
  static const _accountDeletionUrl =
      'https://yourcarehere.com/#/account-deletion';

  @override
  void initState() {
    super.initState();
    _loadDeactivateFlag();
  }

  Future<void> _loadDeactivateFlag() async {
    await AppRemoteConfig.instance.initialize();
    if (!mounted) return;
    setState(() {
      _showDeactivateAccount = AppRemoteConfig.instance.showDeactivateAccount;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openAccountDeletion() async {
    final uri = Uri.parse(_accountDeletionUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (launched) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.failed)),
    );
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
                return SizedBox.shrink();
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
          if (_showDeactivateAccount)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  context.l10n.account_delete_request,
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text(context.l10n.account_delete_request_subtitle),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: _openAccountDeletion,
              ),
            ),
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
