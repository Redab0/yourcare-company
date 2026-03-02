import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/viewmodels/StatsVM.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key, required this.vm, this.currencyCode = 'KWD'});
  final StatsVM vm;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: currencyCode,
      decimalDigits: 3,
    );

    Widget statCard(String title, String value) => Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.textTheme.labelMedium
                        ?.copyWith(color: t.colorScheme.secondary)),
                const SizedBox(height: 6),
                Text(value,
                    style: t.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          statCard(context.l10n.total_requests_label, '${vm.total}'),
          const SizedBox(height: 12),
          statCard(
            context.l10n.total_revenue_label,
            money.format(vm.totalRevenue),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Types', style: t.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _typeRow(context.l10n.houseKeeping, vm.houseCleaning),
                  const SizedBox(height: 8),
                  _typeRow(context.l10n.deepCleaning, vm.deepCleaning),
                ],
              ),
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Status', style: t.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _typeRow(context.l10n.completed, vm.completed),
                  const SizedBox(height: 8),
                  _typeRow(context.l10n.confirmed, vm.confirmed),
                  const SizedBox(height: 8),
                  _typeRow(context.l10n.inprogress, vm.inProgress),
                  const SizedBox(height: 8),
                  _typeRow(context.l10n.cancelled, vm.canceled),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeRow(String label, int count) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      );
}
