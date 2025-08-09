import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:flutter/material.dart';

class DeepCleaningRequestCard extends StatelessWidget {
  const DeepCleaningRequestCard({
    super.key,
    required this.request,
    required this.onSubmitBid,
  });

  // ─── data ─────────────────────────────────────────────────────────
  final DeepCleaningHistory request;
  final VoidCallback onSubmitBid;

  static const _blue = Color(0xFF2979FF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardR = BorderRadius.circular(24);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: cardR),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header row ───────────────────────────────────────────
            Row(
              children: [
                _pill(context.l10n.deepCleaning),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(context.l10n.request_id,
                        style: theme.textTheme.labelSmall!
                            .copyWith(color: Colors.grey[600])),
                    Text('#${request.id}',
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── property type ───────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.house, color: _blue, size: 28),
                const SizedBox(width: 8),
                Text(request.detail.departmentType!.title!,
                    style: theme.textTheme.titleLarge!
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),

            // ── detail grid ─────────────────────────────────────────
            _iconLine(Icons.king_bed_outlined,
                '${request.detail.bedroom!.title} ${context.l10n.request_card_bedroom}'),
            _iconLine(
                Icons.bathtub_outlined,
                '${request.detail.bathroom!.title} ${context.l10n.request_card_bathroom} ${{
                      request.detail.bathroom!.title
                    } == 1 ? '' : 's'}'),
            _iconLine(
                Icons.kitchen_outlined,
                '${request.detail.kitchen!.title} ${context.l10n.request_card_kitchen} ${{
                      request.detail.kitchen!.title
                    } == 1 ? '' : 's'}'),
            _iconLine(
                Icons.weekend_outlined,
                '${request.detail.livingRoom!.title} ${context.l10n.request_card_livingroom} ${{
                      request.detail.livingRoom!.title
                    } == 1 ? '' : 's'}'),

            // ── notes & address ─────────────────────────────────────
            if (request.detail.additionalInformation?.trim().isNotEmpty ??
                false) ...[
              const SizedBox(height: 8),
              Text(context.l10n.request_card_notes,
                  style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text('“${request.detail.additionalInformation?.trim()}”',
                  style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text(context.l10n.address, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(request.detail.address!.area ?? "",
                style: theme.textTheme.bodyMedium),

            const SizedBox(height: 32),
            // ── submit button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: cardR),
                ),
                icon: const Icon(Icons.gavel_rounded),
                label: Text(context.l10n.submit_bit,
                    style: TextStyle(fontSize: 16)),
                onPressed: onSubmitBid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── helpers ────────────────────────────────
  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _blue.withOpacity(.15),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(text,
            style: const TextStyle(color: _blue, fontWeight: FontWeight.w600)),
      );

  Widget _iconLine(IconData icon, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
}
