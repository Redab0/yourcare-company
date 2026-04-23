import 'dart:io';

import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/data/models/profile/business_profile_model.dart';
import 'package:cleaning_service_driver/data/models/profile/covered_service_item_model.dart';
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
  List<CoveredServiceGroup> _coveredServiceGroups = [];
  Set<String> _enabledServiceTypes = <String>{};
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
    bloc.add(LoadCoveredServiceItemsEvent());
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
    final bloc = context.read<BusinessProfileBloc>();
    bloc.add(UpdateProfileEvent(upd));
  }

  String _serviceTypeTitle(String serviceType) {
    switch (serviceType) {
      case 'deepCleaning':
        return '${context.l10n.deepCleaning} / التنظيف العميق';
      case 'houseCleaning':
        return '${context.l10n.houseKeeping} / تنظيف المنازل';
      case 'upholsteryCleaning':
        return '${context.l10n.upholstery_cleaning} / تنظيف المفروشات';
      default:
        return serviceType;
    }
  }

  String _serviceItemSummary(CoveredServiceGroup group) {
    final selectedCount = group.services.where((item) => item.selected).length;
    return '$selectedCount/${group.services.length} selected';
  }

  List<MapEntry<int, CoveredServiceGroup>> _visibleCoveredServiceEntries() {
    if (_enabledServiceTypes.isEmpty) return const [];
    return _coveredServiceGroups.asMap().entries.where((entry) {
      return _enabledServiceTypes.contains(entry.value.serviceType);
    }).toList();
  }

  Future<void> _openCoveredServiceItemsPage(int groupIndex) async {
    final group = _coveredServiceGroups[groupIndex];
    final updatedGroup = await Navigator.of(context).push<CoveredServiceGroup>(
      MaterialPageRoute(
        builder: (_) => _CoveredServiceItemsPage(
          group: group,
          allGroups: _coveredServiceGroups,
          title: _serviceTypeTitle(group.serviceType),
        ),
      ),
    );
    if (updatedGroup == null) return;
    setState(() {
      _coveredServiceGroups[groupIndex] = updatedGroup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusinessProfileBloc, BusinessProfileState>(
      listener: (ctx, state) {
        if (state is ProfileLoaded || state is ProfileUpdated) {
          final model = (state as dynamic).model as BusinessProfileModel;
          final rawServices = model.services ?? const <String>[];
          final enabledServiceTypes = rawServices
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toSet();
          setState(() {
            _profile = model;
            _logoUrl = model.logo;
            _imageUrls = List.from(model.images ?? []);
            _selectedAreaIds = _extractAreaIds(model.areas);
            _enabledServiceTypes = enabledServiceTypes;
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
        if (state is CoveredServiceItemsLoaded) {
          setState(() => _coveredServiceGroups = state.groups);
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
                      if (_enabledServiceTypes.isNotEmpty) ...[
                        Text(
                          context.l10n.covered_services_section_title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_visibleCoveredServiceEntries().isEmpty)
                          Text(
                            '-',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          ..._visibleCoveredServiceEntries().map((groupEntry) {
                            final groupIndex = groupEntry.key;
                            final group = groupEntry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title:
                                    Text(_serviceTypeTitle(group.serviceType)),
                                subtitle: Text(_serviceItemSummary(group)),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () =>
                                    _openCoveredServiceItemsPage(groupIndex),
                              ),
                            );
                          }),
                        const SizedBox(height: 24),
                      ],

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

class _CoveredServiceItemsPage extends StatefulWidget {
  final CoveredServiceGroup group;
  final List<CoveredServiceGroup> allGroups;
  final String title;

  const _CoveredServiceItemsPage({
    required this.group,
    required this.allGroups,
    required this.title,
  });

  @override
  State<_CoveredServiceItemsPage> createState() =>
      _CoveredServiceItemsPageState();
}

class _CoveredServiceItemsPageState extends State<_CoveredServiceItemsPage> {
  late List<CoveredServiceItem> _items;
  bool _saving = false;
  bool _popOnSuccess = false;
  final Set<String> _deletedItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    _items = [...widget.group.services];
  }

  String _serviceItemTitle(CoveredServiceItem item) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? (item.titleAr ?? item.titleEn ?? '-')
        : (item.titleEn ?? item.titleAr ?? '-');
  }

  void _toggleItem(int index, bool selected) {
    setState(() {
      _items[index] = _items[index].copyWith(selected: selected);
    });
  }

  CoveredServiceGroup _currentGroupSelection() {
    return CoveredServiceGroup(
      serviceType: widget.group.serviceType,
      services: _items,
    );
  }

  void _onSave() {
    final updatedGroup = _currentGroupSelection();
    final updatedGroups = widget.allGroups.map((g) {
      if (g.serviceType == widget.group.serviceType) {
        return updatedGroup;
      }
      return g;
    }).toList();

    setState(() {
      _saving = true;
      _popOnSuccess = true;
    });
    context
        .read<BusinessProfileBloc>()
        .add(UpdateCoveredServiceItemsEvent(updatedGroups));
  }

  Future<Map<String, String>?> _showCustomServiceDialog({
    String? initialTitleEn,
    String? initialTitleAr,
    required String dialogTitle,
  }) async {
    var titleEn = initialTitleEn ?? '';
    var titleAr = initialTitleAr ?? '';
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: titleEn,
                  decoration: InputDecoration(
                    labelText: context.l10n.covered_services_title_en,
                  ),
                  onChanged: (value) => titleEn = value,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.form_required
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: titleAr,
                  decoration: InputDecoration(
                    labelText: context.l10n.covered_services_title_ar,
                  ),
                  onChanged: (value) => titleAr = value,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.form_required
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.general_cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(ctx).pop({
                  'titleEn': titleEn.trim(),
                  'titleAr': titleAr.trim(),
                });
              },
              child: Text(context.l10n.general_save),
            )
          ],
        );
      },
    );
    return result;
  }

  Future<void> _onAddCustom() async {
    final values = await _showCustomServiceDialog(
      dialogTitle: context.l10n.covered_services_add_custom,
    );
    if (values == null) return;
    setState(() {
      _saving = true;
      _popOnSuccess = false;
    });
    context.read<BusinessProfileBloc>().add(
          CreateCustomServiceItemEvent(
            serviceType: widget.group.serviceType,
            titleEn: values['titleEn']!,
            titleAr: values['titleAr']!,
          ),
        );
  }

  Future<void> _onEditItem(CoveredServiceItem item) async {
    final values = await _showCustomServiceDialog(
      dialogTitle: context.l10n.covered_services_edit_custom,
      initialTitleEn: item.titleEn,
      initialTitleAr: item.titleAr,
    );
    if (values == null) return;
    setState(() {
      _saving = true;
      _popOnSuccess = false;
    });
    context.read<BusinessProfileBloc>().add(
          UpdateCustomServiceItemEvent(
            serviceItemId: item.id,
            titleEn: values['titleEn']!,
            titleAr: values['titleAr']!,
          ),
        );
  }

  Future<void> _onDeleteItem(CoveredServiceItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.general_delete),
        content: Text(context.l10n.covered_services_delete_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.general_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.general_delete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _items = _items.where((e) => e.id != item.id).toList();
      _deletedItemIds.add(item.id);
      _saving = true;
      _popOnSuccess = false;
    });
    context
        .read<BusinessProfileBloc>()
        .add(DeleteCustomServiceItemEvent(item.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusinessProfileBloc, BusinessProfileState>(
      listener: (context, state) {
        if (state is CoveredServiceItemsLoaded && _saving) {
          final updated = state.groups.firstWhere(
            (g) => g.serviceType == widget.group.serviceType,
            orElse: () => CoveredServiceGroup(
              serviceType: widget.group.serviceType,
              services: _items,
            ),
          );
          if (!mounted) return;
          final syncedGroup = CoveredServiceGroup(
            serviceType: updated.serviceType,
            services: updated.services
                .where((service) => !_deletedItemIds.contains(service.id))
                .map((service) => service.copyWith(
                      selected: service.canManage ? true : service.selected,
                    ))
                .toList(),
          );

          if (_popOnSuccess) {
            Navigator.of(context).pop(syncedGroup);
            return;
          }

          if (_saving && ModalRoute.of(context)?.isCurrent == true) {
            setState(() {
              _items = syncedGroup.services;
              _saving = false;
              _popOnSuccess = false;
            });
          }
        } else if (state is ProfileError && _saving) {
          setState(() {
            _saving = false;
            _popOnSuccess = false;
          });
          context.showErrorToast();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pop(_currentGroupSelection()),
          ),
          actions: [
            IconButton(
              onPressed: _saving ? null : _onAddCustom,
              icon: const Icon(Icons.add),
              tooltip: context.l10n.covered_services_add_custom,
            ),
            TextButton(
              onPressed: _saving ? null : _onSave,
              child: Text(context.l10n.general_save),
            ),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.of(context).pop(_currentGroupSelection());
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = _items[index];
              if (item.canManage) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_serviceItemTitle(item)),
                  subtitle: Text('true (${context.l10n.yes})'),
                  trailing: PopupMenuButton<String>(
                    enabled: !_saving,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _onEditItem(item);
                      } else if (value == 'delete') {
                        _onDeleteItem(item);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(context.l10n.covered_services_edit_custom),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(context.l10n.general_delete),
                      ),
                    ],
                  ),
                );
              }

              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_serviceItemTitle(item)),
                subtitle: Text(
                  item.selected
                      ? 'true (${context.l10n.yes})'
                      : 'false (${context.l10n.no})',
                ),
                value: item.selected,
                secondary: const Icon(Icons.lock_outline, size: 18),
                onChanged:
                    _saving ? null : (value) => _toggleItem(index, value),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: _items.length,
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _saving ? null : _onSave,
            child: Text(context.l10n.general_save),
          ),
        ),
      ),
    );
  }
}
