import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_settings_cubit.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_cubit.dart';
import 'package:cleaning_service_driver/features/screens/home/company_profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'laundry_presentation.dart';
import 'laundry_catalog_load_notice.dart';
import 'laundry_item_image.dart';
import 'laundry_product_editor.dart';
import 'laundry_bulk_prices_screen.dart';
import 'laundry_service_fields.dart';
import 'laundry_same_day_settings_card.dart';
import 'laundry_minimum_charge_card.dart';

class LaundryCatalogScreen extends StatefulWidget {
  const LaundryCatalogScreen({super.key});
  @override
  State<LaundryCatalogScreen> createState() => _LaundryCatalogScreenState();
}

class _LaundryCatalogScreenState extends State<LaundryCatalogScreen> {
  late final _cubit = LaundryCubit(sl<LaundryRepository>())..loadCatalog();
  late final _settingsCubit = LaundrySettingsCubit(sl<LaundryRepository>());
  bool _loadingServices = false;
  String _categoryId = '';
  String _search = '';
  final _searchController = TextEditingController();
  List<LaundryCategory>? _categories;
  bool _canReadSettings = false;
  bool _canEditSettings = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsAccess();
  }

  Future<void> _loadSettingsAccess() async {
    try {
      final user = await SecureStorageService().getUser();
      if (!mounted) return;
      setState(() {
        _canReadSettings = canAccessLaundrySettings(user);
        _canEditSettings = canAccessLaundrySettings(user, edit: true);
      });
      if (_canReadSettings) await _settingsCubit.load();
    } catch (_) {
      // Leave protected controls hidden when the local session is unavailable.
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _settingsCubit.close();
    _cubit.close();
    super.dispose();
  }

  Future<void> _edit({LaundryCatalogItem? item, bool? initialActive}) async {
    if (!_canEditSettings) return;
    if (item?.isManaged == true) {
      final body = await showDialog<LaundryProductConfig>(
          context: context,
          builder: (_) =>
              LaundryProductEditor(item: item!, initialActive: initialActive));
      if (body != null && mounted) {
        await _cubit.configureProduct(item!.productId!, body);
      }
    } else {
      List<LaundryItemService> services = item?.services ?? const [];
      setState(() => _loadingServices = true);
      try {
        _categories ??= await sl<LaundryRepository>().getCategories();
        if (item == null) {
          final definitions = await sl<LaundryRepository>().getServices();
          services = definitions
              .map((definition) => LaundryItemService(
                  serviceId: definition.id,
                  nameEn: definition.nameEn,
                  nameAr: definition.nameAr,
                  serviceActive: definition.active))
              .toList();
        }
      } catch (error) {
        if (mounted) context.showErrorToast(context.genericErrorMessage);
        return;
      } finally {
        if (mounted) setState(() => _loadingServices = false);
      }
      if (!mounted) return;
      final body = await showDialog<LaundryCatalogMutation>(
          context: context,
          builder: (_) => _CatalogEditor(
              item: item,
              services: services,
              categories: _categories ?? const [],
              initialActive: initialActive));
      if (body != null && mounted) await _cubit.saveItem(body, id: item?.id);
    }
  }

  Future<void> _editPrices(List<LaundryCatalogItem> catalog) async {
    if (!_canEditSettings) return;
    final items = await Navigator.of(context).push<List<LaundryCatalogItem>>(
        MaterialPageRoute(
            builder: (_) => LaundryBulkPricesScreen(
                catalog: catalog, save: sl<LaundryRepository>().updatePrices)));
    if (items != null && mounted) _cubit.applyUpdatedPrices(items);
  }

  Future<void> _toggle(LaundryCatalogItem item, bool active) async {
    if (!_canEditSettings) return;
    if (item.isManaged) {
      await _cubit.configureProduct(
          item.productId!, LaundryProductConfig.fromItem(item, active: active));
    } else if (active) {
      await _edit(item: item, initialActive: true);
    } else {
      await _cubit.deactivateItem(item.id);
    }
  }

  Widget _setupNotice() {
    if (!sl.isRegistered<CompanyProfileCubit>()) return const SizedBox.shrink();
    return BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
        bloc: sl<CompanyProfileCubit>(),
        builder: (context, state) {
          if (state.profile == null ||
              (state.profile!.services ?? const []).contains('laundry')) {
            return const SizedBox.shrink();
          }
          return Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(context.l10n.laundry_service_disabled_title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(context.l10n.laundry_service_disabled_help),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                            onPressed: () =>
                                context.pushNamed('business-profile-screen'),
                            icon: const Icon(Icons.settings_outlined),
                            label: Text(context.l10n.laundry_enable_service)),
                      ])));
        });
  }

  Widget _itemCard(LaundryCatalogItem item, List<LaundryCatalogItem> catalog) {
    final arabic = context.l10n.localeName.startsWith('ar');
    final unavailable = item.isManaged && !item.productActive;
    return Card(
        key: ValueKey('laundry-item-${item.productId ?? item.id}'),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: LaundryItemImage(imageUrl: item.imageUrl),
                      title: Text(item.name(arabic),
                          style: Theme.of(context).textTheme.titleLarge),
                      subtitle: Text(unavailable
                          ? context.l10n.laundry_unavailable_admin
                          : item.enabledForCompany
                              ? context.l10n.laundry_active
                              : context.l10n.laundry_inactive),
                      value: item.enabledForCompany,
                      onChanged: unavailable || !_canEditSettings
                          ? null
                          : (value) => _toggle(item, value)),
                  Text(laundryUnitLabel(context, item.unit, item.unitLabel),
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  if (item.sizes.isEmpty && item.price != null)
                    Text(RequestFmt.price(item.price))
                  else
                    ...item.sizes.map((size) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          Expanded(child: Text(size.name(arabic))),
                          const SizedBox(width: 8),
                          Text(RequestFmt.price(size.price))
                        ]))),
                  if (item.services.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(context.l10n.laundry_shared_services,
                        style: Theme.of(context).textTheme.titleSmall),
                    for (final service in item.services)
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(children: [
                            Expanded(child: Text(service.name(arabic))),
                            const SizedBox(width: 8),
                            Flexible(
                                child: Text(
                                    !service.serviceActive
                                        ? context.l10n.laundry_unavailable_admin
                                        : service.companyActive
                                            ? service.price != null &&
                                                    service.price! > 0 &&
                                                    !service.usesDefaultPrice
                                                ? RequestFmt.price(
                                                    service.price)
                                                : context.l10n
                                                    .laundry_company_price_required
                                            : context.l10n.laundry_inactive,
                                    textAlign: TextAlign.end)),
                          ])),
                  ],
                  if (!item.canInvoice && item.enabledForCompany)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(context.l10n.laundry_item_needs_service)),
                  const SizedBox(height: 12),
                  Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: OutlinedButton.icon(
                          onPressed: !_canEditSettings
                              ? null
                              : item.isManaged
                                  ? () => _editPrices(catalog)
                                  : () => _edit(item: item),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(item.isManaged
                              ? context.l10n.laundry_edit_prices
                              : context.l10n.laundry_edit_item))),
                ])));
  }

  String _selectedCategory(List<LaundryCatalogItem> catalog) =>
      (_categoryId == 'uncategorized' &&
                  catalog.any((item) => item.categoryId == null)) ||
              laundryCategories(catalog)
                  .any((category) => category.id == _categoryId)
          ? _categoryId
          : '';

  List<LaundryCatalogItem> _filtered(List<LaundryCatalogItem> catalog) {
    final categoryId = _selectedCategory(catalog);
    return catalog.where((item) {
      final categoryMatches = categoryId.isEmpty ||
          (categoryId == 'uncategorized'
              ? item.categoryId == null
              : item.categoryId == categoryId);
      final query = _search.trim().toLowerCase();
      return categoryMatches &&
          (query.isEmpty ||
              item.nameEn.toLowerCase().contains(query) ||
              item.nameAr.contains(query));
    }).toList();
  }

  List<Widget> _categoryGroups(
      List<LaundryCatalogItem> items, List<LaundryCatalogItem> catalog) {
    final groups = <String, List<LaundryCatalogItem>>{};
    for (final item in items) {
      final key = item.categoryId ?? item.category?.id ?? 'uncategorized';
      groups.putIfAbsent(key, () => []).add(item);
    }
    final arabic = context.l10n.localeName.startsWith('ar');
    return [
      for (final entry in groups.entries) ...[
        Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
                entry.value.first.category?.name(arabic) ??
                    context.l10n.laundry_uncategorized,
                style: Theme.of(context).textTheme.titleSmall)),
        ...entry.value.map((item) => _itemCard(item, catalog)),
      ],
    ];
  }

  Widget _filters(List<LaundryCatalogItem> catalog) {
    final categories = laundryCategories(catalog);
    final selected = _selectedCategory(catalog);
    return Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(children: [
                  TextField(
                      key: const ValueKey('laundry-catalog-search'),
                      controller: _searchController,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                          labelText: context.l10n.laundry_search_items,
                          prefixIcon: const Icon(Icons.search)),
                      onChanged: (value) => setState(() => _search = value)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                      key: ValueKey('laundry-category-filter-$selected'),
                      initialValue: selected,
                      isExpanded: true,
                      decoration: InputDecoration(
                          labelText: context.l10n.laundry_category),
                      items: [
                        DropdownMenuItem(
                            value: '',
                            child: Text(context.l10n.laundry_all_categories)),
                        for (final category in categories)
                          DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name(
                                  context.l10n.localeName.startsWith('ar')))),
                        if (catalog.any((item) => item.categoryId == null))
                          DropdownMenuItem(
                              value: 'uncategorized',
                              child: Text(context.l10n.laundry_uncategorized))
                      ],
                      onChanged: (value) =>
                          setState(() => _categoryId = value ?? '')),
                ]))));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<LaundryCubit,
          LaundryState>(
      bloc: _cubit,
      listener: (context, state) {
        if (!state.loading &&
            _categoryId.isNotEmpty &&
            _selectedCategory(state.catalog).isEmpty) {
          _categoryId = '';
        }
        if (state.error != null && state.catalogFailure == null) {
          context.showErrorToast(state.error);
        }
      },
      builder: (context, state) => Scaffold(
            appBar: AppBar(
                leading: const BusinessBackButton(
                    fallbackRouteName: 'laundry-main-screen'),
                title: Text(context.l10n.laundry_pricing),
                actions: [
                  IconButton(
                      tooltip: context.l10n.retry,
                      onPressed: state.loading || _loadingServices
                          ? null
                          : () async {
                              _categories = null;
                              await _cubit.loadCatalog();
                            },
                      icon: const Icon(Icons.refresh))
                ]),
            floatingActionButton:
                !_canEditSettings || state.loading || _loadingServices
                    ? null
                    : FloatingActionButton.extended(
                        onPressed: () => _edit(),
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.laundry_add_item)),
            body: state.loading && state.catalog.isEmpty
                ? const Center(
                    child: AppIconSpinner(
                        assetPath: 'assets/images/ic_yourcare.png'))
                : Stack(children: [
                    Column(children: [
                      _filters(state.catalog),
                      Expanded(
                          child: RefreshIndicator(
                              onRefresh: () async {
                                _categories = null;
                                await _cubit.loadCatalog();
                              },
                              child: ListView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 16, 16, 100),
                                  children: [
                                    Center(
                                        child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 850),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                      context.l10n
                                                          .laundry_setup_help,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge),
                                                  const SizedBox(height: 12),
                                                  if (_canEditSettings &&
                                                      state.catalog
                                                          .isNotEmpty) ...[
                                                    OutlinedButton.icon(
                                                        key: const ValueKey(
                                                            'laundry-bulk-prices'),
                                                        onPressed: () =>
                                                            _editPrices(
                                                                state.catalog),
                                                        icon: const Icon(
                                                            Icons.edit_note),
                                                        label: Text(context.l10n
                                                            .laundry_bulk_prices)),
                                                    const SizedBox(height: 12),
                                                  ],
                                                  _setupNotice(),
                                                  LaundryCatalogLoadNotice(
                                                    failure:
                                                        state.catalogFailure,
                                                    onRetry: _cubit.loadCatalog,
                                                  ),
                                                  if (_canReadSettings)
                                                    LaundryMinimumChargeCard(
                                                        cubit: _settingsCubit,
                                                        canEdit:
                                                            _canEditSettings),
                                                  if (state.catalog.isEmpty &&
                                                      state.catalogFailure ==
                                                          null)
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 40),
                                                        child: Text(state
                                                                    .error !=
                                                                null
                                                            ? context
                                                                .genericErrorMessage
                                                            : context.l10n
                                                                .laundry_empty_catalog)),
                                                  if (state
                                                          .catalog.isNotEmpty &&
                                                      _filtered(state.catalog)
                                                          .isEmpty)
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 24),
                                                        child: Text(context.l10n
                                                            .laundry_no_matching_items)),
                                                  for (final managed in [
                                                    true,
                                                    false
                                                  ]) ...[
                                                    if (_filtered(state.catalog)
                                                        .any((item) =>
                                                            item.isManaged ==
                                                            managed))
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 16,
                                                                  bottom: 8),
                                                          child: Text(
                                                              managed
                                                                  ? context.l10n
                                                                      .laundry_admin_products
                                                                  : context.l10n
                                                                      .laundry_custom_items,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium)),
                                                    ..._categoryGroups(
                                                        _filtered(state.catalog)
                                                            .where((item) =>
                                                                item.isManaged ==
                                                                managed)
                                                            .toList(),
                                                        state.catalog),
                                                  ],
                                                ]))),
                                  ]))),
                    ]),
                    if (state.loading || _loadingServices)
                      Positioned.fill(
                          child: Stack(children: [
                        ModalBarrier(
                            dismissible: false,
                            color: Theme.of(context)
                                .colorScheme
                                .scrim
                                .withValues(alpha: 0.24)),
                        const Center(
                            child: AppIconSpinner(
                                assetPath: 'assets/images/ic_yourcare.png')),
                      ])),
                  ]),
          ));
}

class _SizeDraft {
  final String? id;
  final TextEditingController en;
  final TextEditingController ar;
  final TextEditingController price;
  _SizeDraft([LaundrySize? size])
      : id = size?.id,
        en = TextEditingController(text: size?.nameEn),
        ar = TextEditingController(text: size?.nameAr),
        price = TextEditingController(text: size?.price.toStringAsFixed(3));
  void dispose() {
    en.dispose();
    ar.dispose();
    price.dispose();
  }
}

class _CatalogEditor extends StatefulWidget {
  final LaundryCatalogItem? item;
  final List<LaundryItemService> services;
  final List<LaundryCategory> categories;
  final bool? initialActive;
  const _CatalogEditor(
      {this.item,
      this.services = const [],
      this.categories = const [],
      this.initialActive});
  @override
  State<_CatalogEditor> createState() => _CatalogEditorState();
}

class _CatalogEditorState extends State<_CatalogEditor> {
  final _form = GlobalKey<FormState>();
  late final _en = TextEditingController(text: widget.item?.nameEn);
  late final _ar = TextEditingController(text: widget.item?.nameAr);
  late final _unitLabel = TextEditingController(text: widget.item?.unitLabel);
  late String _unit = widget.item?.unit ?? 'item';
  late String? _categoryId = widget.item?.categoryId;
  late bool _active =
      widget.initialActive ?? widget.item?.enabledForCompany ?? true;
  late final List<_SizeDraft> _sizes =
      widget.item?.sizes.map(_SizeDraft.new).toList() ?? [];
  final List<_SizeDraft> _removedSizes = [];
  late final _services = widget.services.map(LaundryServiceDraft.new).toList();
  bool get _showLegacyBase => widget.item?.price != null && _sizes.isEmpty;
  @override
  void dispose() {
    for (final c in [_en, _ar, _unitLabel]) {
      c.dispose();
    }
    for (final size in [..._sizes, ..._removedSizes]) {
      size.dispose();
    }
    for (final service in _services) {
      service.dispose();
    }
    super.dispose();
  }

  Widget _field(TextEditingController controller, String label,
          {bool price = false}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: controller,
              maxLength: price ? null : (controller == _unitLabel ? 60 : 120),
              keyboardType: price
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(labelText: label),
              validator: (value) => price
                  ? (laundryNumber(value ?? '', positive: true) == null
                      ? context.l10n.price_must_be_greater_than_zero
                      : null)
                  : (value?.trim().isNotEmpty == true
                      ? null
                      : context.l10n.laundry_required)));

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
        context,
        LaundryCatalogMutation(
            categoryId: _categoryId,
            removeCategory:
                _categoryId == null && widget.item?.categoryId != null,
            nameEn: _en.text.trim(),
            nameAr: _ar.text.trim(),
            unit: _unit,
            unitLabel: _unit == 'custom' ? _unitLabel.text.trim() : null,
            price: widget.item?.price,
            services: _services.isEmpty && widget.item != null
                ? null
                : _services.map((draft) => draft.toConfig()).toList(),
            active: _active,
            sizes: _sizes
                .map((size) => LaundrySize(
                    id: size.id,
                    nameEn: size.en.text.trim(),
                    nameAr: size.ar.text.trim(),
                    price: laundryNumber(size.price.text, positive: true)!))
                .toList()));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.item == null
            ? context.l10n.laundry_add_item
            : context.l10n.laundry_edit_item),
        content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
                child: Form(
                    key: _form,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _field(_en, context.l10n.laundry_name_en),
                          _field(_ar, context.l10n.laundry_name_ar),
                          DropdownButtonFormField<String>(
                              key: const ValueKey('laundry-item-category'),
                              initialValue: _categoryId ?? '',
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: context.l10n.laundry_category),
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child: Text(
                                        context.l10n.laundry_uncategorized)),
                                for (final category in widget.categories.where(
                                    (category) =>
                                        category.active ||
                                        category.id == _categoryId))
                                  DropdownMenuItem(
                                      value: category.id,
                                      child: Text(category.name(context
                                          .l10n.localeName
                                          .startsWith('ar')))),
                                if (_categoryId != null &&
                                    !widget.categories.any((category) =>
                                        category.id == _categoryId))
                                  DropdownMenuItem(
                                      value: _categoryId,
                                      child: Text(widget.item?.category?.name(
                                              context.l10n.localeName
                                                  .startsWith('ar')) ??
                                          context.l10n.laundry_uncategorized))
                              ],
                              onChanged: (value) => setState(() => _categoryId =
                                  value?.isEmpty == true ? null : value)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                              initialValue: _unit,
                              decoration: InputDecoration(
                                  labelText: context.l10n.laundry_unit),
                              items: ['item', 'meter', 'custom']
                                  .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(laundryUnitLabel(
                                          context, unit, null))))
                                  .toList(),
                              onChanged: (unit) =>
                                  setState(() => _unit = unit!)),
                          const SizedBox(height: 12),
                          if (_unit == 'custom')
                            _field(_unitLabel, context.l10n.laundry_unit_label),
                          LaundryServiceFields(
                              drafts: _services,
                              hasLegacyPricing:
                                  _showLegacyBase || _sizes.isNotEmpty,
                              showPrices: widget.item == null,
                              onChanged: () => setState(() {})),
                          if (_sizes.isNotEmpty)
                            Text(context.l10n.laundry_sizes,
                                style: Theme.of(context).textTheme.titleMedium),
                          for (final size in _sizes)
                            Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(children: [
                                      Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: IconButton(
                                              tooltip: context.l10n.delete,
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              onPressed: () => setState(() {
                                                    _sizes.remove(size);
                                                    _removedSizes.add(size);
                                                  }))),
                                      _field(size.en,
                                          context.l10n.laundry_size_en),
                                      _field(size.ar,
                                          context.l10n.laundry_size_ar),
                                      if (widget.item == null)
                                        _field(size.price,
                                            context.l10n.laundry_price,
                                            price: true),
                                    ]))),
                          SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(context.l10n.laundry_active),
                              value: _active,
                              onChanged: (value) =>
                                  setState(() => _active = value)),
                        ])))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel)),
          FilledButton(onPressed: _save, child: Text(context.l10n.save))
        ],
      );
}
