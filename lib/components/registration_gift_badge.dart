import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationGiftBadge extends StatelessWidget {
  final CleaningRequest request;
  const RegistrationGiftBadge({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    if (!request.hasVisibleCampaignBenefit) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final campaign = request.campaignSnapshot;
    final String label;
    if (campaign == null || request.hasActiveRegistrationGift) {
      final discount = request.registrationGiftDiscountKwd;
      final amount = discount == null ? null : _kwd(context, discount);
      if (request.isRegistrationGiftReserved) {
        label = amount == null
            ? context.l10n.registrationGiftReserved
            : context.l10n.registrationGiftReservedAmount(amount);
      } else {
        label = amount == null
            ? context.l10n.registrationGiftApplied
            : context.l10n.registrationGiftAppliedAmount(amount);
      }
    } else if (campaign.hasActiveDiscount) {
      final amount = _kwd(context, campaign.discountKwd!);
      label = campaign.isReserved
          ? context.l10n.campaignDiscountReservedAmount(amount)
          : context.l10n.campaignDiscountAppliedAmount(amount);
    } else if (campaign.hasActiveCashback) {
      final amount = _kwd(context, campaign.cashbackKwd!);
      label = campaign.isReserved
          ? context.l10n.campaignCashbackReservedAmount(amount)
          : context.l10n.campaignCashbackAppliedAmount(amount);
    } else {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: colors.onPrimaryContainer, fontWeight: FontWeight.w700)),
    );
  }

  String _kwd(BuildContext context, double amount) =>
      NumberFormat('0.000', context.l10n.localeName).format(amount);
}
