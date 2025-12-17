import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CleaningJobCard extends StatelessWidget {
  const CleaningJobCard({
    super.key,
    required this.request,
    required this.onAccept,
  });

  // ─── data ─────────────────────────────────────────────────────────
  final HouseKeepingHistory request;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tGreen = const Color(0xFF10B981);
    final cardR = BorderRadius.circular(24);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── header row ────────────────────────────────────────────
          Row(
            children: [
              Column(
                children: [
                  Text(context.l10n.request_price,
                      style: theme.textTheme.labelLarge!
                          .copyWith(color: Colors.grey[600])),
                  Text('${request.totalPrice.toStringAsFixed(3)} KWD',
                      style: theme.textTheme.headlineMedium!.copyWith(
                          color: tGreen, fontWeight: FontWeight.w700)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.l10n.request_id,
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: Colors.grey[600])),
                  Text(request.id ?? "",
                      style: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(context.l10n.request_card_schedule,
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: Colors.grey[600])),
                  Text(
                    DateFormat.yMMMd().add_jm().format(request.scheduledTime),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── price ────────────────────────────────────────────────
          const SizedBox(height: 4),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          // ── cleaners & duration row ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconLabel(Icons.groups,
                    '${request.detail.cleanersCount} Cleaner${request.detail.cleanersCount > 1 ? 's' : ''}'),
                _iconLabel(Icons.timer,
                    '${request.detail.durationHours} Hours'),
              ],
            ),
          const SizedBox(height: 20),
          // ── products included ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iconLabel(
                Icons.cleaning_services_outlined,
                (request.detail.cleaningProducts?.option?.title ?? '')
                        .contains('Eco-friendly')
                    ? context.l10n.request_products_included
                    : context.l10n.request_products_not_included,
              ),
              _iconLabel(Icons.repeat,
                  'Frequency ${request.subRequests?.length ?? '1'}')
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 28),
          // ── accept button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: tGreen,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: cardR),
              ),
              onPressed: onAccept,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(context.l10n.request_accept_job,
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── helpers ────────────────────────────────
  Widget _pill(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(32)),
        child: Text(text,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _iconLabel(IconData icon, String label) => Column(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(height: 4),
          Text(label),
        ],
      );
}
