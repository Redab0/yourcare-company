import 'dart:io';

import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
import 'package:cleaning_service_driver/data/models/staff/permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/user_role.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({Key? key}) : super(key: key);

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  bool _showPassword = false;

  String? _role;
  File? _pickedPhoto;
  String? _uploadedPhotoUrl;
  bool _uploading = false;
  bool _saving = false;
  bool _pendingPermissionAssign = false;
  List<PermissionModel> _allPermissions = [];
  final Set<String> _selectedResources = {};

  final _picker = ImagePicker();

  bool get _isCleanerRole {
    final raw = _role?.trim().toLowerCase();
    return raw == UserRole.worker.value || raw == 'cleaner';
  }

  @override
  void initState() {
    super.initState();
    context.read<StaffActionBloc>().add(FetchPermissionsEvent());
  }

  Future<void> _pickPhoto() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _pickedPhoto = File(file.path);
      _uploading = true;
    });
    // fire upload
    context.read<StaffActionBloc>().add(
          UploadMediaEvent([File(file.path)]),
        );
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.create_user_title),
        leading: const BusinessBackButton(
          fallbackRouteName: 'staff-main-screen',
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
          if (state is StaffActionFailure) {
            context.showErrorToast();
            setState(() {
              _uploading = false;
              _saving = false;
              _pendingPermissionAssign = false;
            });
          }
          if (state is PermissionsFetched) {
            setState(() {
              _allPermissions = state.permission;
            });
          }
          if (state is UserCreatedState && !_pendingPermissionAssign) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.user_created)));
            Navigator.of(context).pop();
          }
          if (state is UserCreatedState && _pendingPermissionAssign) {
            final userId = state.user.id;
            if (userId == null) {
              setState(() {
                _saving = false;
                _pendingPermissionAssign = false;
              });
              return;
            }
            context.read<StaffActionBloc>().add(
                  AssignPermissionsEvent(
                    AssignPermissionModel(userId, _selectedPermissionIds),
                  ),
                );
          }
          if (state is UserPermissionUpdated) {
            setState(() {
              _saving = false;
              _pendingPermissionAssign = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.user_created)));
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final resourceGroups = _groupedPermissions;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Role dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: InputDecoration(labelText: context.l10n.role),
                    items: UserRole.values
                        .map((r) => DropdownMenuItem(
                              value: r.value,
                              child: Text(
                                r.value
                                    .split('_')
                                    .map((p) =>
                                        p[0].toUpperCase() + p.substring(1))
                                    .join(' '),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _role = v);
                    },
                    validator: (v) => v == null ? context.l10n.role : null,
                  ),
                  const SizedBox(height: 16),

                  // Username
                  TextFormField(
                    controller: _usernameCtl,
                    decoration:
                        InputDecoration(labelText: context.l10n.signup_name),
                    validator: (v) =>
                        v!.isEmpty ? context.l10n.signup_name : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordCtl,
                    decoration: InputDecoration(
                      labelText: context.l10n.signup_password,
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() {
                          _showPassword = !_showPassword;
                        }),
                      ),
                    ),
                    obscureText: !_showPassword,
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (_isCleanerRole && value.isEmpty) return null;
                      if (value.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailCtl,
                    decoration:
                        InputDecoration(labelText: context.l10n.signup_email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (_isCleanerRole && value.isEmpty) return null;
                      return value.contains('@')
                          ? null
                          : context.l10n.signup_email;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    maxLength: 8,
                    controller: _phoneCtl,
                    decoration:
                        InputDecoration(labelText: context.l10n.signup_phone),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (_isCleanerRole && value.isEmpty) return null;
                      return value.isEmpty ? context.l10n.signup_phone : null;
                    },
                  ),
                  const SizedBox(height: 24),

                  if (resourceGroups.isNotEmpty) ...[
                    Text(context.l10n.permissions,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...resourceGroups.entries.map((entry) {
                      final resource = entry.key;
                      final isSelected = _selectedResources.contains(resource);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedResources.add(resource);
                              } else {
                                _selectedResources.remove(resource);
                              }
                            });
                          },
                          title: Text(_resourceLabel(resource)),
                          subtitle: Text('${entry.value.length} permissions'),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Photo picker / preview
                  Text(context.l10n.user_photo,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _uploadedPhotoUrl != null
                          ? NetworkImage(_uploadedPhotoUrl!)
                          : (_pickedPhoto != null
                              ? FileImage(_pickedPhoto!) as ImageProvider
                              : null),
                      child: _uploading
                          ? SizedBox.shrink()
                          : (_uploadedPhotoUrl == null && _pickedPhoto == null
                              ? const Icon(Icons.camera_alt, size: 32)
                              : null),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: _uploading || _saving
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final selectedRole = UserRoleX.fromValue(_role);
                              if (selectedRole == null) return;
                              final isCleaner = selectedRole == UserRole.worker;
                              setState(() {
                                _saving = true;
                                _pendingPermissionAssign =
                                    _selectedPermissionIds.isNotEmpty;
                              });
                              final model = CreateUserModel(
                                role: selectedRole.value,
                                username: _usernameCtl.text.trim(),
                                password: isCleaner &&
                                        _passwordCtl.text.trim().isEmpty
                                    ? null
                                    : _passwordCtl.text,
                                email:
                                    isCleaner && _emailCtl.text.trim().isEmpty
                                        ? null
                                        : _emailCtl.text.trim(),
                                phone:
                                    isCleaner && _phoneCtl.text.trim().isEmpty
                                        ? null
                                        : _phoneCtl.text.trim(),
                                image: _uploadedPhotoUrl ?? "",
                              );
                              context
                                  .read<StaffActionBloc>()
                                  .add(CreateUserEvent(model));
                            }
                          },
                    child: Text(context.l10n.save_user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, List<PermissionModel>> get _groupedPermissions {
    final grouped = <String, List<PermissionModel>>{};
    for (final permission in _allPermissions) {
      final resource = (permission.resource ?? 'other').trim();
      grouped.putIfAbsent(resource, () => []).add(permission);
    }
    return grouped;
  }

  List<String> get _selectedPermissionIds {
    final ids = <String>{};
    for (final resource in _selectedResources) {
      final perms = _groupedPermissions[resource] ?? const <PermissionModel>[];
      for (final permission in perms) {
        final id = permission.id;
        if (id != null) ids.add(id);
      }
    }
    return ids.toList();
  }

  String _resourceLabel(String raw) {
    if (raw.isEmpty) return 'Other';
    return raw
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
