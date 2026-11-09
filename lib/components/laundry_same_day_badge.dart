import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

/// Booking-time priority; this must never depend on today's company settings.
class LaundrySameDayBadge extends StatelessWidget {
  final bool sameDay;
  final String? deliveryOption;
  const LaundrySameDayBadge(
      {super.key, required this.sameDay, this.deliveryOption});

  @override
  Widget build(BuildContext context) =>
      deliveryOption == 'same_day' || deliveryOption == 'next_day' || sameDay
          ? Align(
              alignment: AlignmentDirectional.centerStart,
              child: Chip(
                avatar: const Icon(Icons.today_outlined, size: 18),
                label: Text(deliveryOption == 'next_day'
                    ? context.l10n.laundry_next_day
                    : context.l10n.laundry_same_day),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            )
          : const SizedBox.shrink();
}
