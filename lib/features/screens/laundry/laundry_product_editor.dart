import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:flutter/material.dart';

import 'laundry_presentation.dart';
import 'laundry_service_fields.dart';

class _PriceDraft {
  final String? sizeId;
  final String name;
  final TextEditingController controller;
  _PriceDraft({this.sizeId, required this.name, required double? price})
      : controller = TextEditingController(text: price?.toStringAsFixed(3));
}

/// Master item names, units and options belong to admin; a company controls only
/// its availability and explicit company prices.
class LaundryProductEditor extends StatefulWidget {
  final LaundryCatalogItem item;
  final bool? initialActive;
  const LaundryProductEditor(
      {super.key, required this.item, this.initialActive});
  @override
  State<LaundryProductEditor> createState() => _LaundryProductEditorState();
}

class _LaundryProductEditorState extends State<LaundryProductEditor> {
  final _form = GlobalKey<FormState>();
  late bool _active = widget.initialActive ?? widget.item.enabledForCompany;
  List<_PriceDraft>? _prices;
  late final _services =
      widget.item.services.map(LaundryServiceDraft.new).toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arabic = context.l10n.localeName.startsWith('ar');
    _prices ??= widget.item.sizes.isEmpty
        ? (widget.item.price == null &&
                widget.item.defaultPrice == null &&
                widget.item.services.isNotEmpty
            ? <_PriceDraft>[]
            : [
                _PriceDraft(
                    name: context.l10n.laundry_price,
                    price:
                        widget.item.usesDefaultPrice ? null : widget.item.price)
              ])
        : widget.item.sizes
            .map((size) => _PriceDraft(
                sizeId: size.id,
                name: size.name(arabic),
                price: size.usesDefaultPrice ? null : size.price))
            .toList();
  }

  @override
  void dispose() {
    for (final draft in _prices ?? <_PriceDraft>[]) {
      draft.controller.dispose();
    }
    for (final draft in _services) {
      draft.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final base = _prices!.where((price) => price.sizeId == null).firstOrNull;
    Navigator.pop(
        context,
        LaundryProductConfig(
            active: _active,
            services: _services.isEmpty
                ? null
                : _services.map((draft) => draft.toConfig()).toList(),
            price: base == null
                ? null
                : laundryNumber(base.controller.text, positive: true),
            sizes: _prices!
                .where((price) => price.sizeId != null)
                .map((price) => LaundryProductSizePrice(
                    sizeId: price.sizeId!,
                    price:
                        laundryNumber(price.controller.text, positive: true)!))
                .toList()));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.item.name(context.l10n.localeName.startsWith('ar'))),
        content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
                child: Form(
                    key: _form,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(context.l10n.laundry_admin_product_help),
                          const SizedBox(height: 8),
                          Text(laundryUnitLabel(context, widget.item.unit,
                              widget.item.unitLabel)),
                          if (!widget.item.productActive)
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                    context.l10n.laundry_unavailable_admin)),
                          SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(context.l10n.laundry_active),
                              value: _active,
                              onChanged: widget.item.productActive
                                  ? (value) => setState(() => _active = value)
                                  : null),
                          if (_services.isNotEmpty)
                            LaundryServiceFields(
                                drafts: _services,
                                hasLegacyPricing: widget.item.price != null ||
                                    widget.item.defaultPrice != null ||
                                    widget.item.sizes.isNotEmpty,
                                onChanged: () => setState(() {})),
                          for (final price in _prices!)
                            Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(price.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          TextFormField(
                                              controller: price.controller,
                                              decoration: InputDecoration(
                                                  labelText: context.l10n
                                                      .laundry_company_price),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              validator: (value) => laundryNumber(
                                                          value ?? '',
                                                          positive: true) ==
                                                      null
                                                  ? context.l10n
                                                      .price_must_be_greater_than_zero
                                                  : null),
                                        ]))),
                        ])))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel)),
          FilledButton(onPressed: _save, child: Text(context.l10n.save))
        ],
      );
}
