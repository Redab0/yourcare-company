import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:flutter/material.dart';

import 'laundry_presentation.dart';

class _PriceDraft {
  final String id;
  final double? original;
  final double? defaultPrice;
  final TextEditingController controller;
  _PriceDraft(this.id, this.original, {this.defaultPrice})
      : controller = TextEditingController(text: original?.toStringAsFixed(3));
  double? get value => laundryNumber(controller.text, positive: true);
  bool get changed => controller.text.trim().isEmpty
      ? original != null
      : value == null || value != original;
  void dispose() => controller.dispose();
}

class _ItemDraft {
  final LaundryCatalogItem item;
  final _PriceDraft? base;
  final Map<String, _PriceDraft> sizes;
  final Map<String, _PriceDraft> services;
  late bool active = item.enabledForCompany;
  _ItemDraft(this.item)
      : base = item.sizes.isEmpty &&
                (item.price != null ||
                    item.defaultPrice != null ||
                    item.services.isEmpty)
            ? _PriceDraft('base',
                item.isManaged && item.usesDefaultPrice ? null : item.price,
                defaultPrice: item.defaultPrice)
            : null,
        sizes = {
          for (final size in item.sizes)
            if (size.id != null)
              size.id!: _PriceDraft(size.id!,
                  item.isManaged && size.usesDefaultPrice ? null : size.price,
                  defaultPrice: size.defaultPrice),
        },
        services = {
          for (final service in item.services)
            service.serviceId: _PriceDraft(service.serviceId,
                service.usesDefaultPrice ? null : service.price,
                defaultPrice: service.defaultPrice),
        };
  Iterable<_PriceDraft> get prices => [
        if (base != null) base!,
        ...sizes.values,
        ...services.values,
      ];
  bool get availabilityChanged => active != item.enabledForCompany;
  bool get changed =>
      availabilityChanged || prices.any((price) => price.changed);

  LaundryItemPriceUpdate toUpdate() => LaundryItemPriceUpdate(
      productId: item.isManaged ? item.productId : null,
      itemId: item.isManaged ? null : item.id,
      active: availabilityChanged ? active : null,
      price: base?.changed == true ? base!.value : null,
      sizes: sizes.values.any((price) => price.changed)
          ? [
              for (final price in sizes.values)
                if (price.value != null)
                  LaundryProductSizePrice(
                      sizeId: price.id, price: price.value!),
            ]
          : null,
      services: services.values.any((price) => price.changed)
          ? [
              for (final service in item.services)
                LaundryServiceConfig(
                    serviceId: service.serviceId,
                    active: service.companyActive,
                    price: services[service.serviceId]!.value),
            ]
          : null);
  void dispose() {
    for (final price in prices) {
      price.dispose();
    }
  }
}

/// Local price and availability drafts saved in one atomic request.
class LaundryBulkPricesScreen extends StatefulWidget {
  final List<LaundryCatalogItem> catalog;
  final Future<List<LaundryCatalogItem>> Function(LaundryBulkPricesRequest)
      save;
  const LaundryBulkPricesScreen(
      {super.key, required this.catalog, required this.save});
  @override
  State<LaundryBulkPricesScreen> createState() =>
      _LaundryBulkPricesScreenState();
}

class _LaundryBulkPricesScreenState extends State<LaundryBulkPricesScreen> {
  final _form = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  late final _drafts = widget.catalog.map(_ItemDraft.new).toList();
  bool _saving = false;
  bool _allowLeave = false;
  String? _error;
  bool get _changed => _drafts.any((draft) => draft.changed);
  List<_ItemDraft> get _visibleDrafts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _drafts;
    return _drafts.where((draft) {
      final item = draft.item;
      return item.nameEn.toLowerCase().contains(query) ||
          item.nameAr.toLowerCase().contains(query) ||
          (item.category?.nameEn.toLowerCase().contains(query) ?? false) ||
          (item.category?.nameAr.toLowerCase().contains(query) ?? false) ||
          (item.unitLabel?.toLowerCase().contains(query) ?? false) ||
          laundryUnitLabel(context, item.unit, item.unitLabel)
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  List<Widget> _categoryGroups() {
    final groups = <String, List<_ItemDraft>>{};
    for (final draft in _visibleDrafts) {
      final item = draft.item;
      final key = item.categoryId ?? item.category?.id ?? 'uncategorized';
      groups.putIfAbsent(key, () => []).add(draft);
    }
    final arabic = context.l10n.localeName.startsWith('ar');
    return [
      for (final entry in groups.entries) ...[
        Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
                entry.value.first.item.category?.name(arabic) ??
                    context.l10n.laundry_uncategorized,
                style: Theme.of(context).textTheme.titleSmall)),
        ...entry.value.map(_itemCard),
      ],
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _leave() async {
    if (_saving) return;
    if (_changed) {
      final discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                  title: Text(context.l10n.availability_discard_title),
                  content: Text(context.l10n.laundry_bulk_prices_unsaved),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(context.l10n.cancel)),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(context.l10n.availability_discard)),
                  ]));
      if (discard != true || !mounted) return;
    }
    setState(() => _allowLeave = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_saving || !_changed) return;
    final fieldsValid = _form.currentState!.validate();
    final draftsValid = !_drafts.any((draft) =>
        draft.prices.any((price) => price.changed && price.value == null));
    if (!fieldsValid || !draftsValid) {
      setState(() => _error = context.l10n.laundry_bulk_prices_invalid);
      return;
    }
    final updates = _drafts.where((draft) => draft.changed).toList();
    if (updates.length > 200) {
      setState(() => _error = context.l10n.laundry_bulk_prices_limit);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final items = await widget.save(LaundryBulkPricesRequest(
          items: updates.map((draft) => draft.toUpdate()).toList()));
      if (!mounted) return;
      setState(() => _allowLeave = true);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop(items);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = context.l10n.laundry_bulk_prices_error;
        });
      }
    }
  }

  Widget _priceField(_ItemDraft draft, _PriceDraft price, String name,
          {bool available = true, bool active = true}) =>
      Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12, top: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name),
                          if (!available)
                            Text(context.l10n.laundry_unavailable_admin,
                                style: Theme.of(context).textTheme.bodySmall)
                          else if (!active)
                            Text(context.l10n.laundry_inactive,
                                style: Theme.of(context).textTheme.bodySmall),
                        ]))),
            SizedBox(
                width: 150,
                child: TextFormField(
                    key: ValueKey(
                        'bulk-price-${draft.item.productId ?? draft.item.id}-${price.id}'),
                    controller: price.controller,
                    enabled: !_saving && available,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: context.l10n.laundry_company_price,
                        hintText: price.defaultPrice == null
                            ? null
                            : RequestFmt.price(price.defaultPrice)),
                    validator: (_) => price.changed && price.value == null
                        ? context.l10n.laundry_bulk_prices_invalid
                        : null,
                    onChanged: (_) => setState(() {}))),
          ]));

  Widget _itemCard(_ItemDraft draft) {
    final item = draft.item;
    final arabic = context.l10n.localeName.startsWith('ar');
    return Card(
        key: ValueKey('bulk-item-${item.productId ?? item.id}'),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(item.name(arabic),
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(laundryUnitLabel(context, item.unit, item.unitLabel),
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.laundry_active),
                      subtitle: !item.productActive
                          ? Text(context.l10n.laundry_unavailable_admin)
                          : null,
                      value: draft.active,
                      onChanged: _saving || !item.productActive
                          ? null
                          : (active) => setState(() => draft.active = active)),
                  if (draft.base != null)
                    _priceField(draft, draft.base!, context.l10n.laundry_price,
                        available: item.productActive),
                  for (final size in item.sizes)
                    if (draft.sizes[size.id] != null)
                      _priceField(
                          draft, draft.sizes[size.id]!, size.name(arabic),
                          available: item.productActive),
                  for (final service in item.services)
                    _priceField(draft, draft.services[service.serviceId]!,
                        service.name(arabic),
                        available: item.productActive && service.serviceActive,
                        active: service.companyActive),
                ])));
  }

  @override
  Widget build(BuildContext context) => PopScope<List<LaundryCatalogItem>>(
      canPop: _allowLeave || (!_changed && !_saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
          appBar: AppBar(
              leading: BackButton(onPressed: _saving ? null : _leave),
              title: Text(context.l10n.laundry_bulk_prices)),
          bottomNavigationBar: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                      key: const ValueKey('laundry-bulk-save'),
                      onPressed: _saving || !_changed ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: AppIconSpinner(
                                  assetPath: 'assets/images/ic_yourcare.png'))
                          : const Icon(Icons.save_outlined),
                      label: Text(context.l10n.laundry_bulk_prices_save)))),
          body: Stack(children: [
            Form(
                key: _form,
                child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 850),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(context.l10n.laundry_bulk_prices_help),
                                  const SizedBox(height: 12),
                                  TextField(
                                      key:
                                          const ValueKey('laundry-bulk-search'),
                                      controller: _searchController,
                                      enabled: !_saving,
                                      onTapOutside: (_) => FocusManager
                                          .instance.primaryFocus
                                          ?.unfocus(),
                                      decoration: InputDecoration(
                                          labelText:
                                              context.l10n.laundry_search_items,
                                          prefixIcon: const Icon(Icons.search)),
                                      onChanged: (_) => setState(() {})),
                                  if (_error != null)
                                    Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(_error!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error))),
                                  const SizedBox(height: 12),
                                  if (_visibleDrafts.isEmpty)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24),
                                        child: Text(context
                                            .l10n.laundry_no_matching_items)),
                                  ..._categoryGroups(),
                                ]))))),
            if (_saving)
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
          ])));
}
