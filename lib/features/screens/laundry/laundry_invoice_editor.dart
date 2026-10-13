import 'dart:async';

import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:flutter/material.dart';

import 'laundry_item_image.dart';
import 'laundry_presentation.dart';

class LaundryInvoiceEditor extends StatefulWidget {
  final List<LaundryCatalogItem> catalog;
  final LaundryInvoice? invoice;
  final double minimumCharge;
  final LaundryInvoiceRequest? draft;
  final Future<List<LaundryCatalogItem>?> Function()? onManageCatalog;
  const LaundryInvoiceEditor(
      {super.key,
      required this.catalog,
      this.invoice,
      this.minimumCharge = 0,
      this.draft,
      this.onManageCatalog});
  @override
  State<LaundryInvoiceEditor> createState() => _LaundryInvoiceEditorState();
}

class _SelectionDraft {
  String? itemId;
  String? sizeId;
  String categoryId = '';
  final TextEditingController quantity;
  _SelectionDraft([LaundryLine? line])
      : itemId = line?.itemId,
        sizeId = line?.sizeId,
        quantity =
            TextEditingController(text: line?.quantity.toString() ?? '1');
  _SelectionDraft.fromSelection(LaundryInvoiceSelection selection)
      : itemId = selection.itemId,
        sizeId = selection.sizeId,
        quantity = TextEditingController(text: selection.quantity.toString());
}

class _LaundryInvoiceEditorState extends State<LaundryInvoiceEditor> {
  final _form = GlobalKey<FormState>();
  List<LaundryCatalogItem>? _reloadedCatalog;
  bool _loadingCatalog = false;
  late final List<_SelectionDraft> _lines =
      widget.draft?.items.map(_SelectionDraft.fromSelection).toList() ??
          widget.invoice?.items.map(_SelectionDraft.new).toList() ??
          [_SelectionDraft()];
  final List<_SelectionDraft> _removed = [];
  late final _pickupFee = TextEditingController(
      text: (widget.draft?.pickupFee ?? widget.invoice?.pickupFee ?? 0)
          .toStringAsFixed(3));
  late final _deliveryFee = TextEditingController(
      text: (widget.draft?.deliveryFee ?? widget.invoice?.deliveryFee ?? 0)
          .toStringAsFixed(3));
  late final _discount = TextEditingController(
      text: (widget.draft?.discount ?? widget.invoice?.discount ?? 0)
          .toStringAsFixed(3));
  List<LaundryCatalogItem> get _catalog => (_reloadedCatalog ?? widget.catalog)
      .where((item) => item.canInvoice)
      .toList();
  LaundryCatalogItem? _item(_SelectionDraft line) =>
      _catalog.where((item) => item.id == line.itemId).firstOrNull;
  LaundrySize? _size(_SelectionDraft line) => _item(line)
      ?.invoiceChoices
      .where((size) => size.id == line.sizeId)
      .firstOrNull;
  bool _unavailableSelection(_SelectionDraft line) =>
      line.itemId != null &&
      (_item(line) == null || (line.sizeId != null && _size(line) == null));
  double _lineTotal(_SelectionDraft line) =>
      laundryMoney((laundryNumber(line.quantity.text) ?? 0) *
          (_item(line)?.invoiceChoices.isNotEmpty == true
              ? _size(line)?.price ?? 0
              : _item(line)?.price ?? 0));
  double get _itemsSubtotal => laundryMoney(
      _lines.fold<double>(0, (sum, line) => sum + _lineTotal(line)));
  double get _minimumCharge =>
      widget.invoice?.minimumCharge ?? widget.minimumCharge;
  bool get _meetsMinimum =>
      (_itemsSubtotal * 1000).round() >= (_minimumCharge * 1000).round();
  double get _estimatedTotal => laundryMoney(_itemsSubtotal +
      (laundryNumber(_pickupFee.text) ?? 0) +
      (laundryNumber(_deliveryFee.text) ?? 0) -
      (laundryNumber(_discount.text) ?? 0));

  Future<void> _manageCatalog() async {
    if (_loadingCatalog || widget.onManageCatalog == null) return;
    setState(() => _loadingCatalog = true);
    try {
      final catalog = await widget.onManageCatalog!();
      if (mounted && catalog != null) {
        setState(() => _reloadedCatalog = catalog);
      } else if (mounted) {
        context.showErrorToast(context.l10n.laundry_catalog_load_error);
      }
    } catch (error) {
      if (mounted) {
        context.showErrorToast(error is TimeoutException
            ? context.l10n.laundry_catalog_load_timeout
            : context.l10n.laundry_catalog_load_error);
      }
    } finally {
      if (mounted) setState(() => _loadingCatalog = false);
    }
  }

  @override
  void dispose() {
    for (final line in [..._lines, ..._removed]) {
      line.quantity.dispose();
    }
    _pickupFee.dispose();
    _deliveryFee.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _save(bool send) async {
    if (!_form.currentState!.validate()) return;
    if (_lines.isEmpty) {
      context.showErrorToast(context.l10n.laundry_invoice_empty);
      return;
    }
    final keys =
        _lines.map((line) => '${line.itemId}:${line.sizeId ?? ''}').toSet();
    if (keys.length != _lines.length) {
      context.showErrorToast(context.l10n.laundry_duplicate_items);
      return;
    }
    if (_estimatedTotal < 0) {
      context.showErrorToast(context.l10n.laundry_invoice_invalid_discount);
      return;
    }
    if (send && !_meetsMinimum) {
      context.showErrorToast(context.l10n.laundry_minimum_invoice_help);
      return;
    }
    if (send && !await confirmLaundryInvoice(context)) return;
    if (!mounted) return;
    Navigator.pop(
        context,
        LaundryInvoiceRequest(
            expectedRevision: widget.draft != null
                ? widget.draft!.expectedRevision
                : widget.invoice?.revision,
            items: _lines
                .map((line) => LaundryInvoiceSelection(
                    itemId: line.itemId!,
                    sizeId: line.sizeId,
                    quantity:
                        laundryNumber(line.quantity.text, positive: true)!))
                .toList(),
            pickupFee: laundryNumber(_pickupFee.text)!,
            deliveryFee: laundryNumber(_deliveryFee.text)!,
            discount: laundryNumber(_discount.text)!,
            send: send));
  }

  Widget _moneyField(TextEditingController controller, String label) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          validator: (value) => laundryNumber(value ?? '') == null
              ? context.l10n.laundry_valid_number
              : null));

  @override
  Widget build(BuildContext context) {
    final arabic = context.l10n.localeName.startsWith('ar');
    return Scaffold(
      appBar: AppBar(
          leading:
              const BusinessBackButton(fallbackRouteName: 'jobs-main-screen'),
          title: Text(context.l10n.laundry_invoice)),
      body: _loadingCatalog
          ? const Center(
              child: AppIconSpinner(assetPath: 'assets/images/ic_yourcare.png'))
          : Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Form(
                      key: _form,
                      child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(context.l10n.laundry_invoice_help),
                            if (_minimumCharge > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                  '${context.l10n.laundry_minimum_charge}: ${RequestFmt.price(_minimumCharge)}'),
                              Text(context.l10n.laundry_minimum_invoice_help),
                            ],
                            const SizedBox(height: 16),
                            if (_catalog.isEmpty) ...[
                              Text(context.l10n.laundry_catalog_setup_needed),
                              if (widget.onManageCatalog != null)
                                OutlinedButton.icon(
                                    onPressed: _manageCatalog,
                                    icon: const Icon(Icons.settings_outlined),
                                    label: Text(
                                        context.l10n.laundry_manage_catalog)),
                            ],
                            for (final line in _lines)
                              Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                  child: Text(
                                                      context
                                                          .l10n.laundry_items,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium)),
                                              IconButton(
                                                  tooltip: context.l10n.delete,
                                                  onPressed: () => setState(() {
                                                        _lines.remove(line);
                                                        _removed.add(line);
                                                      }),
                                                  icon: const Icon(
                                                      Icons.delete_outline))
                                            ]),
                                            if (_unavailableSelection(line))
                                              Text(context.l10n
                                                  .laundry_invoice_unavailable_item),
                                            if (laundryCategories(_catalog)
                                                .isNotEmpty) ...[
                                              DropdownButtonFormField<String>(
                                                  key: ValueKey(
                                                      'invoice-category-${identityHashCode(line)}-${line.categoryId}'),
                                                  initialValue: line.categoryId,
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                      labelText: context.l10n
                                                          .laundry_category,
                                                      helperText: context.l10n
                                                          .laundry_invoice_category_help,
                                                      helperMaxLines: 3),
                                                  items: [
                                                    DropdownMenuItem(
                                                        value: '',
                                                        child: Text(context.l10n
                                                            .laundry_all_categories)),
                                                    for (final category
                                                        in laundryCategories(
                                                            _catalog))
                                                      DropdownMenuItem(
                                                          value: category.id,
                                                          child: Text(category
                                                              .name(arabic))),
                                                    if (_catalog.any((item) =>
                                                        item.categoryId ==
                                                        null))
                                                      DropdownMenuItem(
                                                          value:
                                                              'uncategorized',
                                                          child: Text(context
                                                              .l10n
                                                              .laundry_uncategorized))
                                                  ],
                                                  onChanged: (value) =>
                                                      setState(() {
                                                        line.categoryId =
                                                            value ?? '';
                                                        final item =
                                                            _item(line);
                                                        if (item != null &&
                                                            line.categoryId
                                                                .isNotEmpty &&
                                                            (line.categoryId ==
                                                                    'uncategorized'
                                                                ? item.categoryId !=
                                                                    null
                                                                : item.categoryId !=
                                                                    line.categoryId)) {
                                                          line.itemId = null;
                                                          line.sizeId = null;
                                                        }
                                                      })),
                                              const SizedBox(height: 12),
                                            ],
                                            DropdownButtonFormField<String>(
                                                key: ValueKey(
                                                    'item-${identityHashCode(line)}-${line.itemId}'),
                                                initialValue: _item(line)?.id,
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                    labelText: context
                                                        .l10n.laundry_items),
                                                items: _catalog
                                                    .where((item) =>
                                                        line.categoryId.isEmpty ||
                                                        (line.categoryId == 'uncategorized'
                                                            ? item.categoryId ==
                                                                null
                                                            : item.categoryId ==
                                                                line
                                                                    .categoryId))
                                                    .map((item) => DropdownMenuItem(
                                                        value: item.id,
                                                        child: Text(
                                                            item.name(arabic))))
                                                    .toList(),
                                                onChanged: (value) =>
                                                    setState(() {
                                                      line.itemId = value;
                                                      line.sizeId = null;
                                                      final choices = _item(
                                                                  line)
                                                              ?.invoiceChoices ??
                                                          const <LaundrySize>[];
                                                      if (choices.length == 1) {
                                                        line.sizeId =
                                                            choices.single.id;
                                                      }
                                                    }),
                                                validator: (_) => _item(line) == null ||
                                                        _unavailableSelection(line)
                                                    ? context.l10n.laundry_required
                                                    : null),
                                            if (_item(line)
                                                    ?.invoiceChoices
                                                    .isNotEmpty ==
                                                true) ...[
                                              const SizedBox(height: 12),
                                              DropdownButtonFormField<String>(
                                                  key: ValueKey(
                                                      'size-${identityHashCode(line)}-${line.itemId}-${line.sizeId}'),
                                                  initialValue: _size(line)?.id,
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                      labelText: _item(line)!
                                                              .services
                                                              .isNotEmpty
                                                          ? context.l10n
                                                              .laundry_item_service
                                                          : context.l10n
                                                              .laundry_size),
                                                  items: _item(line)!
                                                      .invoiceChoices
                                                      .where((size) =>
                                                          size.id != null)
                                                      .map((size) =>
                                                          DropdownMenuItem(
                                                              value: size.id,
                                                              child: Text(
                                                                  '${size.name(arabic)} · ${RequestFmt.price(size.price)}')))
                                                      .toList(),
                                                  onChanged: (value) => setState(
                                                      () => line.sizeId = value),
                                                  validator: (_) => _size(line) == null ? context.l10n.laundry_required : null),
                                            ],
                                            const SizedBox(height: 12),
                                            TextFormField(
                                                controller: line.quantity,
                                                decoration: InputDecoration(
                                                    labelText: context
                                                        .l10n.laundry_quantity),
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                onChanged: (_) =>
                                                    setState(() {}),
                                                validator: (value) {
                                                  final quantity =
                                                      laundryNumber(value ?? '',
                                                          positive: true);
                                                  if (quantity == null) {
                                                    return context.l10n
                                                        .laundry_valid_quantity;
                                                  }
                                                  if (_item(line)?.unit ==
                                                          'item' &&
                                                      quantity !=
                                                          quantity
                                                              .roundToDouble()) {
                                                    return context.l10n
                                                        .laundry_whole_quantity;
                                                  }
                                                  return null;
                                                }),
                                            if (_item(line) != null) ...[
                                              const SizedBox(height: 8),
                                              Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                  child: LaundryItemImage(
                                                      imageUrl: _item(line)!
                                                          .imageUrl)),
                                              const SizedBox(height: 8),
                                              Text(laundryUnitLabel(
                                                  context,
                                                  _item(line)!.unit,
                                                  _item(line)!.unitLabel)),
                                              Text(RequestFmt.price(
                                                  _lineTotal(line))),
                                            ],
                                          ]))),
                            TextButton.icon(
                                onPressed: _catalog.isEmpty ||
                                        _lines.length >= 100
                                    ? null
                                    : () => setState(
                                        () => _lines.add(_SelectionDraft())),
                                icon: const Icon(Icons.add),
                                label: Text(context.l10n.laundry_add_item)),
                            const SizedBox(height: 16),
                            Text(
                                '${context.l10n.laundry_items_subtotal}: ${RequestFmt.price(_itemsSubtotal)}'),
                            if (!_meetsMinimum)
                              Text(context.l10n.laundry_minimum_invoice_help,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            const SizedBox(height: 20),
                            Wrap(spacing: 12, runSpacing: 12, children: [
                              OutlinedButton(
                                  onPressed: _catalog.isEmpty
                                      ? null
                                      : () => _save(false),
                                  child: Text(context.l10n.laundry_save_draft)),
                              FilledButton(
                                  onPressed: _catalog.isEmpty || !_meetsMinimum
                                      ? null
                                      : () => _save(true),
                                  child:
                                      Text(context.l10n.laundry_send_invoice)),
                            ]),
                          ])))),
    );
  }
}
