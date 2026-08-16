import 'dart:io';

import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/update_user_model.dart';
import 'package:cleaning_service_driver/data/models/staff/user_role.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class StaffDetailsScreen extends StatefulWidget {
  final User user;
  const StaffDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtl;
  late TextEditingController _passwordCtl;
  late TextEditingController _emailCtl;
  late TextEditingController _phoneCtl;
  String? _role;

  File? _pickedPhoto;
  String? _uploadedPhotoUrl;
  bool _uploading = false;
  final _picker = ImagePicker();

  List<PermissionModel> _allPerms = [];
  late Set<String> _selectedPermissionIds;

  @override
  void initState() {
    super.initState();
    // init controllers with existing values
    _usernameCtl = TextEditingController(text: widget.user.username);
    _passwordCtl = TextEditingController(); // leave empty for no-change
    _emailCtl = TextEditingController(text: widget.user.email);
    _phoneCtl = TextEditingController(text: widget.user.phone);
    _role = UserRoleX.fromValue(widget.user.role)?.value;

    // init permissions selection
    _selectedPermissionIds = widget.user.permissions!
        .where((p) => p.id != null)
        .map((p) => p.id!)
        .toSet();

    // initial photo
    _uploadedPhotoUrl = widget.user.image;

    // fetch all permissions
    context.read<StaffActionBloc>().add(FetchPermissionsEvent());
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _pickedPhoto = File(file.path);
      _uploading = true;
    });
    // upload photo
    context.read<StaffActionBloc>().add(UploadMediaEvent([File(file.path)]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Profile & Permissions'),
        leading: const BusinessBackButton(
          fallbackRouteName: 'staffList',
        ),
      ),
      body: BlocConsumer<StaffActionBloc, StaffActionState>(
        listener: (context, state) {
          if (state is MediaUploaded) {
            setState(() {
              _uploadedPhotoUrl = state.media.first.url;
              _uploading = false;
            });
          }
          if (state is UserCreatedState || state is UserUpdatedState) {
            // handle update success (assuming UserUpdatedState exists)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state is UserUpdatedState
                      ? 'User updated successfully'
                      : 'User created successfully')),
            );
            Navigator.of(context).pop();
          }
          if (state is UserPermissionUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permissions saved!')));
          }
          if (state is StaffActionFailure) {
            context.showErrorToast();
            setState(() => _uploading = false);
          }
        },
        builder: (context, state) {
          final loading = state is StaffActionInitial;
          if (state is PermissionsFetched) {
            _allPerms = state.permission;
          }
          return AbsorbPointer(
            absorbing: loading,
            child: Stack(
              children: [
                _buildForm(context),
                if (loading) SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Profile Card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey.shade200,
                          child: _uploadedPhotoUrl != null
                              ? Image.network(_uploadedPhotoUrl!,
                                  errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ))
                              : Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                        Positioned(
                          right: 0,
                          child: InkWell(
                            onTap: _pickPhoto,
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Role
                        DropdownButtonFormField<String>(
                          initialValue: _role,
                          decoration: InputDecoration(
                              labelText: context.l10n.role,
                              suffixIcon: Icon(Icons.edit)),
                          items: UserRole.values
                              .map((r) => DropdownMenuItem(
                                    value: r.value,
                                    child: Text(
                                      r.value
                                          .split('_')
                                          .map((p) =>
                                              p[0].toUpperCase() +
                                              p.substring(1))
                                          .join(' '),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _role = v),
                          validator: (v) =>
                              v == null ? context.l10n.role : null,
                        ),
                        const SizedBox(height: 12),
                        // Username
                        TextFormField(
                          controller: _usernameCtl,
                          decoration: InputDecoration(
                              labelText: context.l10n.username,
                              suffixIcon: Icon(Icons.edit)),
                          validator: (v) =>
                              v!.isEmpty ? context.l10n.username : null,
                        ),
                        const SizedBox(height: 12),
                        // Password
                        TextFormField(
                          controller: _passwordCtl,
                          decoration: InputDecoration(
                              labelText: context.l10n.signup_password,
                              suffixIcon: Icon(Icons.edit)),
                          obscureText: true,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 6) {
                              return context.l10n.signup_password;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Email
                        TextFormField(
                          controller: _emailCtl,
                          decoration: InputDecoration(
                              labelText: context.l10n.signup_email,
                              suffixIcon: Icon(Icons.edit)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.contains('@')
                              ? null
                              : context.l10n.signup_email,
                        ),
                        const SizedBox(height: 12),
                        // Phone
                        TextFormField(
                          controller: _phoneCtl,
                          decoration: InputDecoration(
                              labelText: context.l10n.signup_phone,
                              suffixIcon: Icon(Icons.edit)),
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v!.isEmpty ? context.l10n.signup_phone : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _uploading ? null : _onUpdateProfile,
                          icon: const Icon(Icons.save),
                          label: Text(context.l10n.save_changes),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Permissions Section
          if (_allPerms.isNotEmpty) ...[
            Text(
              context.l10n.permissions,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildPermissionGroups(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onSavePermissions,
              icon: const Icon(Icons.shield),
              label: Text(context.l10n.save_changes),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPermissionGroups() {
    final grouped = <String, List<PermissionModel>>{};
    for (var p in _allPerms) {
      grouped.putIfAbsent(p.resource ?? 'other', () => []).add(p);
    }
    return grouped.entries.map((entry) {
      final resource = entry.key;
      final perms = entry.value;
      final permIds = perms.map((p) => p.id).whereType<String>().toSet();
      final allSelected =
          permIds.isNotEmpty && permIds.every(_selectedPermissionIds.contains);
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: CheckboxListTile(
          secondary: Icon(_iconForResource(resource)),
          title: Text(
            _resourceLabel(resource),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${permIds.length} permissions'),
          value: allSelected,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                _selectedPermissionIds.addAll(permIds);
              } else {
                _selectedPermissionIds.removeAll(permIds);
              }
            });
          },
        ),
      );
    }).toList();
  }

  String _resourceLabel(String resource) {
    if (resource.trim().isEmpty) return 'Other';
    return resource
        .split('_')
        .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  IconData _iconForResource(String resource) {
    switch (resource) {
      case 'users':
        return Icons.person_outline;
      case 'business':
        return Icons.business;
      case 'categories':
        return Icons.category;
      case 'requests':
        return Icons.request_page;
      case 'transactions':
        return Icons.receipt_long;
      case 'areas':
        return Icons.map_outlined;
      case 'email':
        return Icons.email;
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.lock_outline;
    }
  }

  void _onUpdateProfile() {
    if (!_formKey.currentState!.validate()) return;
    final selectedRole = UserRoleX.fromValue(_role);
    if (selectedRole == null) return;
    final model = UpdateUserModel(
      username:
          _usernameCtl.text.trim().isEmpty ? null : _usernameCtl.text.trim(),
      password: _passwordCtl.text.isEmpty ? null : _passwordCtl.text,
      email: _emailCtl.text.trim().isEmpty ? null : _emailCtl.text.trim(),
      phone: _phoneCtl.text.trim().isEmpty ? null : _phoneCtl.text.trim(),
      image: _uploadedPhotoUrl,
      role: selectedRole.value,
    );
    context
        .read<StaffActionBloc>()
        .add(UpdateUserEvent(model, widget.user.id ?? ""));
  }

  void _onSavePermissions() {
    final permModel = AssignPermissionModel(
      widget.user.id,
      _selectedPermissionIds.toList(),
    );
    context.read<StaffActionBloc>().add(AssignPermissionsEvent(permModel));
  }
}
