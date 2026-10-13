import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';

String laundryStatusLabel(BuildContext context, String status) =>
    switch (status) {
      'pending_pickup' => context.l10n.laundry_pending_pickup,
      'pickup_accepted' => context.l10n.laundry_pickup_accepted,
      'pickup_rejected' => context.l10n.laundry_pickup_rejected,
      'picked_up' => context.l10n.laundry_picked_up,
      'invoice_sent' => context.l10n.laundry_invoice_sent,
      'confirmed' => context.l10n.confirmed,
      'paid' => context.l10n.request_paid,
      'in_progress' => context.l10n.inprogress,
      'ready_for_delivery' => context.l10n.laundry_ready_for_delivery,
      'out_for_delivery' => context.l10n.laundry_out_for_delivery,
      'delivered' => context.l10n.laundry_delivered,
      'completed' => context.l10n.completed,
      'cancelled' => context.l10n.cancelled,
      'draft' => context.l10n.laundry_draft,
      'sent' => context.l10n.laundry_sent,
      'pending' => context.l10n.laundry_payment_pending,
      'refunded' => context.l10n.laundry_payment_refunded,
      'unpaid' => context.l10n.laundry_payment_unpaid,
      'failed' => context.l10n.failed,
      _ => status,
    };

String laundryActionLabel(BuildContext context, String status) =>
    switch (status) {
      'completed' => context.l10n.laundry_complete,
      'cancelled' => context.l10n.laundry_cancel_order,
      _ => laundryStatusLabel(context, status),
    };

String laundryUnitLabel(BuildContext context, String unit, String? label) =>
    switch (unit) {
      'meter' => context.l10n.laundry_unit_meter,
      'custom' => label ?? context.l10n.laundry_unit_custom,
      _ => context.l10n.laundry_unit_item,
    };

/// KWD and measured quantities use three decimal places. Reject NaN/Infinity.
double? laundryNumber(String value, {bool positive = false}) {
  final raw = value.trim().runes.map((rune) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      return String.fromCharCode(rune - 0x0660 + 0x30);
    }
    if (rune >= 0x06f0 && rune <= 0x06f9) {
      return String.fromCharCode(rune - 0x06f0 + 0x30);
    }
    return rune == 0x066b ? '.' : String.fromCharCode(rune);
  }).join();
  if (!RegExp(r'^\d+(?:\.\d{1,3})?$').hasMatch(raw)) return null;
  final number = double.tryParse(raw);
  if (number == null ||
      !number.isFinite ||
      number < 0 ||
      (positive && number == 0) ||
      number > 10000) {
    return null;
  }
  return number;
}

Future<bool> confirmLaundryInvoice(BuildContext context) async =>
    await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.l10n.laundry_send_invoice),
              content: Text(context.l10n.laundry_send_invoice_confirm),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(context.l10n.cancel)),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(context.l10n.laundry_send_invoice)),
              ],
            )) ??
    false;

/// Match the backend's per-line KWD rounding before calculating invoice totals.
double laundryMoney(double amount) => (amount * 1000).round() / 1000;

List<LaundryCategory> laundryCategories(Iterable<LaundryCatalogItem> catalog) {
  final categories = <String, LaundryCategory>{};
  for (final item in catalog) {
    if (item.category != null) categories[item.category!.id] = item.category!;
  }
  return categories.values.toList();
}
