import 'dart:io';

import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/update_business_profile_model.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_event.dart';
import 'package:cleaning_service_driver/features/bloc/profile/business/business_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

enum _UploadTarget { logo, images }

enum _MediaPickOption { images, video }

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  BusinessProfileModel? _profile;
  List<AreaResponse> _areas = [];
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
    }
  }

  Future<void> _pickAndUploadMedia() async {
    final picker = ImagePicker();
    final option = await showModalBottomSheet<_MediaPickOption>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.gallery),
                onTap: () => Navigator.of(ctx).pop(_MediaPickOption.images),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () => Navigator.of(ctx).pop(_MediaPickOption.video),
              ),
            ],
          ),
        );
      },
    );
    if (option == null) return;

    List<XFile> files = [];
    if (option == _MediaPickOption.images) {
      files = await picker.pickMultiImage(imageQuality: 80);
    } else {
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) files = [file];
    }
    if (files.isEmpty) return;

    setState(() {
      _uploadTarget = _UploadTarget.images;
      _uploading = true;
    });
    context.read<BusinessProfileBloc>().add(
          UploadMediaEvent(files.map((x) => File(x.path)).toList()),
        );
  }

  bool _isVideoUrl(String url) {
    final s = url.toLowerCase();
    return s.endsWith('.mp4') ||
        s.endsWith('.mov') ||
        s.endsWith('.mkv') ||
        s.endsWith('.webm') ||
        s.endsWith('.avi');
  }

  Widget _mediaThumb(String url) {
    final isVideo = _isVideoUrl(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: isVideo
            ? const ColoredBox(
                color: Color(0x11000000),
                child: Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white),
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0x11000000)),
              ),
      ),
    );
  }

  List<String> _extractAreaIds(List<AreaModel>? areas) {
    final ids = <String>{};
    for (final area in areas ?? const <AreaModel>[]) {
      final id = area.id;
      if (id != null) ids.add(id);
    }
    return ids.toList();
  }

  String _selectedAreaSummary(BuildContext context) {
    final selected = _selectedAreaIds.toSet();
    if (selected.isEmpty) return '0 selected';
    final names = <String>[];
    for (final group in _areas) {
      for (final area in group.areas ?? const <AreaModel>[]) {
        final id = area.id;
        if (id != null && selected.contains(id)) {
          if (names.length < 3) names.add(_areaTitle(context, area));
        }
      }
    }
    if (names.isEmpty) return '${selected.length} selected';
    final remaining = selected.length - names.length;
    return remaining > 0 ? '${names.join(', ')} +$remaining' : names.join(', ');
  }

  String _governorateTitle(BuildContext context, Governorate? title) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? (title?.ar ?? title?.en ?? '-')
        : (title?.en ?? title?.ar ?? '-');
  }

  String _areaTitle(BuildContext context, AreaModel area) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? (area.ar ?? area.en ?? area.name ?? '-')
        : (area.en ?? area.ar ?? area.name ?? '-');
  }

  Future<void> _showAreasSheet() async {
    final selected = Set<String>.from(_selectedAreaIds);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.85,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.business_service_area,
                              style: Theme.of(ctx).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${selected.length} selected',
                            style: Theme.of(ctx).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(selected),
                            child: Text(context.l10n.general_save),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children:
                            _buildAreaGroups(ctx, selected, setSheetState),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() => _selectedAreaIds = result.toList());
    }
  }

  List<Widget> _buildAreaGroups(BuildContext context, Set<String> selected,
      void Function(void Function()) setSheetState) {
    final groups = <Widget>[];
    for (final group in _areas) {
      final areas = group.areas ?? const <AreaModel>[];
      if (areas.isEmpty) continue;

      final allSelected =
          areas.every((a) => a.id != null && selected.contains(a.id));
      final anySelected =
          areas.any((a) => a.id != null && selected.contains(a.id));

      groups.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_governorateTitle(context, group.title)),
              value: allSelected ? true : (anySelected ? null : false),
              tristate: true,
              onChanged: (_) {
                setSheetState(() {
                  if (allSelected) {
                    for (final area in areas) {
                      final id = area.id;
                      if (id != null) selected.remove(id);
                    }
                  } else {
                    for (final area in areas) {
                      final id = area.id;
                      if (id != null && !selected.contains(id)) {
                        selected.add(id);
                      }
                    }
                  }
                });
              },
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: areas.map((area) {
                final id = area.id;
                final isSelected = id != null && selected.contains(id);
                return FilterChip(
                  label: Text(_areaTitle(context, area)),
                  selected: isSelected,
                  onSelected: (yes) {
                    if (id == null) return;
                    setSheetState(() {
                      if (yes) {
                        selected.add(id);
                      } else {
                        selected.remove(id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }
    return groups;
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
            _selectedAreaIds = _extractAreaIds(model.areas);
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
          context.showErrorToast();
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
                      InkWell(
                        onTap: _areas.isEmpty ? null : _showAreasSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedAreaSummary(context),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
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
                                child: _mediaThumb(url),
                              ),
                            SizedBox(
                              width: 8,
                            ),
                            InkWell(
                              onTap: _pickAndUploadMedia,
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
