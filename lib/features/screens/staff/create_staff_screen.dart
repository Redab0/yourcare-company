import '../../../components/price_access_checkbox.dart';
import '../../../components/company_permission_panel.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/access/price_widgets.dart';
import 'dart:io';
import '../../../core/validators/validators.dart';

import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/staff/assign_permission_model.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
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
  late final int _accountGeneration;
  Set<String> _selectedIds = {};
  bool _canSeePrices = false;

  final _picker = ImagePicker();

  bool get _isCleanerRole {
    final raw = _role?.trim().toLowerCase();
    return raw == UserRole.worker.value || raw == 'cleaner';
  }

  @override
  void initState() {
    super.initState();
    _accountGeneration = SecureStorageService().authGeneration;
  }

  Future<void> _pickPhoto() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null ||
        !mounted ||
        _accountGeneration != SecureStorageService().authGeneration) {
      return;
    }
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
          if (_accountGeneration != SecureStorageService().authGeneration) {
            return;
          }
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
                        .where((r) => r != UserRole.businessOwner)
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
                    validator: (v) => Validators.validStaffUsername(v ?? '')
                        ? null
                        : context.l10n.signup_name,
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
                      final value = v ?? '';
                      if (_isCleanerRole && value.isEmpty) return null;
                      if (!Validators.validStaffPassword(value,
                          creating: true)) {
                        return context.l10n.signup_password;
                      }
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
                      return Validators.validateEmail(value) == null
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
                      return Validators.validatePhone(value) == null
                          ? null
                          : context.l10n.signup_phone;
                    },
                  ),
                  const SizedBox(height: 24),

                  PriceAccessCheckbox(
                      value: _canSeePrices,
                      onChanged: (value) =>
                          setState(() => _canSeePrices = value)),
                  ...[
                    Text(context.l10n.permissions,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    CompanyPermissionPanel(
                        selectedIds: _selectedIds,
                        onChanged: (next) =>
                            setState(() => _selectedIds = next)),
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
                            if (_accountGeneration !=
                                SecureStorageService().authGeneration) {
                              context.showErrorToast(
                                  context.l10n.permissionOptionsUnavailable);
                              return;
                            }
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
                                canSeePrices: context.canManagePriceAccess
                                    ? _canSeePrices
                                    : null,
                                username: _usernameCtl.text.trim(),
                                password: isCleaner && _passwordCtl.text.isEmpty
                                    ? null
                                    : _passwordCtl.text,
                                email:
                                    isCleaner && _emailCtl.text.trim().isEmpty
                                        ? null
                                        : _emailCtl.text.trim(),
                                phone: isCleaner &&
                                        _phoneCtl.text.trim().isEmpty
                                    ? null
                                    : Validators.normalizePhone(_phoneCtl.text),
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

  List<String> get _selectedPermissionIds => _selectedIds.toList();
}
