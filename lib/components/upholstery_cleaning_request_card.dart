import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:flutter/material.dart';

class UpholsteryCleaningRequestCard extends StatelessWidget {
  const UpholsteryCleaningRequestCard({
    super.key,
    required this.request,
    required this.onSubmitBid,
  });

  final UpholsteryCleaningHistory request;
  final VoidCallback onSubmitBid;

  static const _blue = Color(0xFF2979FF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardR = BorderRadius.circular(24);
    final items = request.upholsteryCleaning.items ?? const [];
    final scheduled = request.scheduledTime;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                  const SizedBox(height: 4),
                  Text(context.l10n.request_card_schedule,
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: Colors.grey[600])),
                  Text(
                      '${scheduled.day.toString().padLeft(2, '0')}-${scheduled.month.toString().padLeft(2, '0')}-${scheduled.year}',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(context.l10n.upholstery_details,
              style: theme.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map((it) => _itemTile(context, it)),
          if (items.isEmpty)
            Text(context.l10n.requests_no_requests,
                style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
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
                  style: const TextStyle(fontSize: 16)),
              onPressed: onSubmitBid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile(BuildContext context, UpholsteryCleaningItems it) {
    final theme = Theme.of(context);
    final typeTitle = _titleForType(context, it.type);
    final qty = it.quantity ?? 0;
    final size = it.size?.title ?? '-';
    final material = it.material?.title ?? '-';
    final condition = it.condition?.title ?? '-';
    final price = it.calculatedPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(_iconForTitle(typeTitle), color: _blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$typeTitle x$qty',
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                _line(theme, context.l10n.size, size),
                _line(theme, context.l10n.material, material),
                _line(theme, context.l10n.condition, condition),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _line(ThemeData theme, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Text('$label: ',
                style: theme.textTheme.bodySmall!
                    .copyWith(fontWeight: FontWeight.w600)),
            Flexible(
              child: Text(value,
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: Colors.grey[800])),
            ),
          ],
        ),
      );

  String _titleForType(BuildContext context, CleaningItemType? type) =>
      type?.title ??
      type?.titleEn ??
      type?.titleAr ??
      context.l10n.upholstery_details;

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('sofa') || t.contains('couch') || t.contains('صوفا')) {
      return Icons.chair_outlined;
    }
    if (t.contains('arm') || t.contains('chair')) {
      return Icons.event_seat_outlined;
    }
    if (t.contains('carpet') || t.contains('rug') || t.contains('سج')) {
      return Icons.crop_16_9_outlined;
    }
    if (t.contains('mattress') || t.contains('مرتبة')) {
      return Icons.king_bed_outlined;
    }
    if (t.contains('curtain') || t.contains('ستارة')) {
      return Icons.curtains_closed_outlined;
    }
    return Icons.local_laundry_service_outlined;
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _blue.withOpacity(.15),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(text,
            style: const TextStyle(color: _blue, fontWeight: FontWeight.w600)),
      );
}
