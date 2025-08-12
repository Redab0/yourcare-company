import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';

class KpiRow extends StatelessWidget {
  const KpiRow({
    super.key,
    required this.total,
    required this.revenue,
    required this.avg,
  });

  final int total;
  final num revenue;
  final num avg;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget chip(String label, String value) => Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: t.textTheme.labelMedium
                          ?.copyWith(color: t.colorScheme.secondary)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: t.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        );

    return Row(
      children: [
        chip(context.l10n.total_requests_label, '$total'),
        const SizedBox(width: 12),
        chip(context.l10n.total_revenue_label, '$revenue'),
        const SizedBox(width: 12),
        chip(context.l10n.average_requests_label, '$avg'),
      ],
    );
  }
}
