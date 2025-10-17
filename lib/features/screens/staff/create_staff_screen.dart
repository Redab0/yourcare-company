import 'dart:io';

import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/staff/create_user_model.dart';
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

  String _role = 'manager';
  File? _pickedPhoto;
  String? _uploadedPhotoUrl;
  bool _uploading = false;

  final _picker = ImagePicker();

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.of(context).pop(),
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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            setState(() => _uploading = false);
          }
          if (state is UserCreatedState) {
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
                    value: _role,
                    decoration: InputDecoration(labelText: context.l10n.role),
                    items: ['manager', 'admin', 'cleaner', 'driver']
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r[0].toUpperCase() + r.substring(1)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _role = v);
                    },
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
                    validator: (v) =>
                        v!.length < 6 ? 'At least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailCtl,
                    decoration:
                        InputDecoration(labelText: context.l10n.signup_email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.contains('@') ? null : context.l10n.signup_email,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    maxLength: 8,
                    controller: _phoneCtl,
                    decoration:
                        InputDecoration(labelText: context.l10n.signup_phone),
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v!.isEmpty ? context.l10n.signup_phone : null,
                  ),
                  const SizedBox(height: 24),

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
                    onPressed: _uploading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final model = CreateUserModel(
                                role: _role,
                                username: _usernameCtl.text.trim(),
                                password: _passwordCtl.text,
                                email: _emailCtl.text.trim(),
                                phone: _phoneCtl.text.trim(),
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
}
