import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:flutter/material.dart';

import 'laundry_presentation.dart';

class LaundryServiceDraft {
  final LaundryItemService service;
  final TextEditingController price;
  bool active;
  LaundryServiceDraft(this.service)
      : price = TextEditingController(
            text: service.usesDefaultPrice ||
                    service.price?.isFinite != true ||
                    (service.price ?? 0) <= 0
                ? null
                : service.price?.toStringAsFixed(3)),
        active = service.companyActive;
  LaundryServiceConfig toConfig() => LaundryServiceConfig(
      serviceId: service.serviceId,
      active: active,
      price: laundryNumber(price.text, positive: true));
  void dispose() => price.dispose();
}

/// Global names are read-only; each item keeps independent availability/pricing.
class LaundryServiceFields extends StatelessWidget {
  final List<LaundryServiceDraft> drafts;
  final VoidCallback onChanged;
  final bool hasLegacyPricing;
  final bool showPrices;
  const LaundryServiceFields(
      {super.key,
      required this.drafts,
      required this.onChanged,
      this.hasLegacyPricing = false,
      this.showPrices = true});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.l10n.laundry_shared_services,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(context.l10n.laundry_shared_services_help),
        if (hasLegacyPricing)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(context.l10n.laundry_legacy_pricing_help)),
        if (drafts.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(context.l10n.laundry_no_shared_services)),
        for (final draft in drafts)
          Card(
              key: ValueKey('laundry-service-${draft.service.serviceId}'),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(draft.service.name(
                                context.l10n.localeName.startsWith('ar'))),
                            subtitle: !draft.service.serviceActive
                                ? Text(context.l10n.laundry_unavailable_admin)
                                : null,
                            value: draft.active,
                            onChanged:
                                draft.service.serviceActive || draft.active
                                    ? (value) {
                                        draft.active = value;
                                        if (!value &&
                                            laundryNumber(draft.price.text,
                                                    positive: true) ==
                                                null) {
                                          draft.price.clear();
                                        }
                                        onChanged();
                                      }
                                    : null),
                        if (showPrices)
                          TextFormField(
                              key: ValueKey(
                                  'laundry-service-price-${draft.service.serviceId}'),
                              controller: draft.price,
                              enabled: draft.active,
                              decoration: InputDecoration(
                                  labelText:
                                      context.l10n.laundry_company_price),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if ((!draft.active ||
                                        !draft.service.serviceActive) &&
                                    (value?.trim().isEmpty ?? true)) {
                                  return null;
                                }
                                return laundryNumber(value ?? '',
                                            positive: true) ==
                                        null
                                    ? context
                                        .l10n.price_must_be_greater_than_zero
                                    : null;
                              }),
                      ]))),
      ]);
}
