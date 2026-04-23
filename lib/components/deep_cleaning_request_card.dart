import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeepCleaningRequestCard extends StatelessWidget {
  const DeepCleaningRequestCard({
    super.key,
    required this.request,
    required this.onSubmitBid,
    this.padding,
  });

  // ─── data ─────────────────────────────────────────────────────────
  final DeepCleaningHistory request;
  final VoidCallback onSubmitBid;
  final EdgeInsetsGeometry? padding;

  static const _blue = Color(0xFF2979FF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardR = BorderRadius.circular(24);
    final detail = request.detail;
    final isApartment = detail.isApartmentOrHouse;
    final isCommercial = detail.isCommercialOrOffice;
    final isOther = detail.isOtherType;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header row ───────────────────────────────────────────
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
                      request.scheduledTime == null
                          ? context.l10n.as_soon_as_possible
                          : DateFormat.yMMMd().format(request.scheduledTime!),
                      style: theme.textTheme.bodyMedium),
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
              Text(detail.propertyTypeTitle,
                  style: theme.textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          // ── detail grid ─────────────────────────────────────────
          if (isApartment) ...[
            if (detail.floor > 0)
              _iconLine(Icons.elevator_outlined,
                  '${detail.floor ?? ""} ${context.l10n.numberOfFloors}'),
            if (detail.bedrooms > 0)
              _iconLine(Icons.king_bed_outlined,
                  '${detail.bedrooms} ${context.l10n.request_card_bedroom}'),
            if (detail.bathrooms > 0)
              _iconLine(Icons.bathtub_outlined,
                  '${detail.bathrooms} ${context.l10n.request_card_bathroom}'),
            if (detail.kitchens > 0)
              _iconLine(Icons.kitchen_outlined,
                  '${detail.kitchens} ${context.l10n.request_card_kitchen}'),
            if (detail.livingRooms > 0)
              _iconLine(Icons.weekend_outlined,
                  '${detail.livingRooms} ${context.l10n.request_card_livingroom}'),
            if (detail.includeFurniture)
              _iconLine(Icons.chair_alt_outlined, context.l10n.yes.toString()),
          ],
          if (isCommercial) ...[
            if (detail.sizeOption != null)
              _iconLine(
                  Icons.straighten, detail.sizeOption!.titleLocalized ?? ''),
            _iconLine(
                Icons.kitchen_outlined,
                '${context.l10n.request_card_kitchen}: '
                '${detail.includeKitchen ? context.l10n.yes : context.l10n.no}'),
            _iconLine(
                Icons.bathtub_outlined,
                '${context.l10n.request_card_bathroom}: '
                '${detail.includeBathroom ? context.l10n.yes : context.l10n.no}'),
          ],
          if (isOther && (detail.notes?.isNotEmpty ?? false))
            _iconLine(Icons.notes_outlined, detail.notes ?? ''),
          if (!isApartment && !isCommercial && !isOther) ...[
            if (detail.sizeOption != null)
              _iconLine(
                  Icons.straighten, detail.sizeOption!.titleLocalized ?? ''),
          ],

          // ── notes & address ─────────────────────────────────────
          if (detail.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(context.l10n.request_card_notes,
                style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text('“${detail.notes}”', style: theme.textTheme.bodyMedium),
          ],

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
              label:
                  Text(context.l10n.submit_bit, style: TextStyle(fontSize: 16)),
              onPressed: onSubmitBid,
            ),
          ),
        ],
      ),
    );
  }

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
