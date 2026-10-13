import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

/// Booking-time priority; this must never depend on today's company settings.
class LaundrySameDayBadge extends StatelessWidget {
  final bool sameDay;
  const LaundrySameDayBadge({super.key, required this.sameDay});

  @override
  Widget build(BuildContext context) => sameDay
      ? Align(
          alignment: AlignmentDirectional.centerStart,
          child: Chip(
            avatar: const Icon(Icons.today_outlined, size: 18),
            label: Text(context.l10n.laundry_same_day),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        )
      : const SizedBox.shrink();
}
