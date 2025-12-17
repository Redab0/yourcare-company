import 'dart:io';

import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/profile/area_model.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_event.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

enum _UploadTarget { logo, images }

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  BusinessProfileModel? _profile;
  List<AreaModel> _areas = [];
  String? _logoUrl;
  List<String> _imageUrls = [];
  List<String> _selectedAreaIds = [];

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  _UploadTarget? _uploadTarget;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BusinessProfileBloc>();
    bloc.add(LoadProfileEvent());
    bloc.add(GetAreasEvent());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(_UploadTarget target) async {
    final picker = ImagePicker();
    if (target == _UploadTarget.logo) {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      setState(() {
        _uploadTarget = target;
        _uploading = true;
      });
      context
          .read<BusinessProfileBloc>()
          .add(UploadMediaEvent([File(file.path)]));
    } else {
      final List<XFile> files = await picker.pickMultiImage(imageQuality: 80);
      if (files.isEmpty) return;
      setState(() {
        _uploadTarget = target;
        _uploading = true;
      });
      context.read<BusinessProfileBloc>().add(
            UploadMediaEvent(files.map((x) => File(x.path)).toList()),
          );
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final upd = UpdateBusinessProfileModel(
      _nameCtrl.text,
      _descCtrl.text,
      _addressCtrl.text,
      _logoUrl,
      _imageUrls,
      _phoneCtrl.text,
      _emailCtrl.text,
      _websiteCtrl.text,
      _selectedAreaIds,
    );
    context.read<BusinessProfileBloc>().add(UpdateProfileEvent(upd));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusinessProfileBloc, BusinessProfileState>(
      listener: (ctx, state) {
        if (state is ProfileLoaded || state is ProfileUpdated) {
          final model = (state as dynamic).model as BusinessProfileModel;
          setState(() {
            _profile = model;
            _logoUrl = model.logo;
            _imageUrls = List.from(model.images ?? []);
            _selectedAreaIds = List.from(model.areas?.map((a) => a.id!) ?? []);
            _nameCtrl.text = model.name ?? '';
            _descCtrl.text = model.description ?? '';
            _addressCtrl.text = model.address ?? '';
            _phoneCtrl.text = model.phone ?? '';
            _emailCtrl.text = model.email ?? '';
            _websiteCtrl.text = model.website ?? '';
          });
        }
        if (state is AreasLoaded) {
          setState(() => _areas = state.areas);
        }
        if (state is MediaUploaded && _uploadTarget != null) {
          final urls = state.media.map((r) => r.url).toList();
          setState(() {
            if (_uploadTarget == _UploadTarget.logo) {
              _logoUrl = urls.first;
            } else {
              _imageUrls.addAll(urls);
            }
            _uploading = false;
            _uploadTarget = null;
          });
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                  SnackBar(content: Text(context.genericErrorMessage)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(context.l10n.profile_title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: (_profile == null || _areas.isEmpty)
            ? SizedBox.shrink()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: _logoUrl != null
                                  ? NetworkImage(_logoUrl!)
                                  : null,
                              child: _logoUrl == null
                                  ? const Icon(Icons.business, size: 48)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _pickAndUpload(_UploadTarget.logo),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: _uploading &&
                                          _uploadTarget == _UploadTarget.logo
                                      ? SizedBox.shrink()
                                      : const Icon(Icons.camera_alt,
                                          size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text fields
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                            labelText: context.l10n.business_name),
                        validator: (v) =>
                            v!.isEmpty ? context.l10n.business_name : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: InputDecoration(
                            labelText: context.l10n.business_description),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(
                            labelText: context.l10n.business_address),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                            labelText: context.l10n.business_phone),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                            labelText: context.l10n.business_email),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _websiteCtrl,
                        decoration: InputDecoration(
                            labelText: context.l10n.business_website),
                      ),
                      const SizedBox(height: 24),

                      // Areas multi‐select
                      Text(context.l10n.business_service_area),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _areas.map((a) {
                          final sel = _selectedAreaIds.contains(a.id);
                          return FilterChip(
                            label: Text(a.areaEn ?? a.areaAr ?? ''),
                            selected: sel,
                            onSelected: (yes) {
                              setState(() {
                                if (yes) {
                                  _selectedAreaIds.add(a.id!);
                                } else {
                                  _selectedAreaIds.remove(a.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Additional images
                      Text(context.l10n.business_gallery),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final url in _imageUrls)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(url,
                                      width: 80, height: 80, fit: BoxFit.cover),
                                ),
                              ),
                            InkWell(
                              onTap: () => _pickAndUpload(_UploadTarget.images),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: _uploading &&
                                        _uploadTarget == _UploadTarget.images
                                    ? SizedBox.shrink()
                                    : const Icon(Icons.add_a_photo,
                                        color: Colors.white, size: 28),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _onSave,
                        child: Text(context.l10n.general_save),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
