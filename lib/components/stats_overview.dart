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

    Widget statRow(String title, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: t.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: t.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.statistics_title,
                      style: t.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  statRow(context.l10n.total_requests_label, '${vm.total}'),
                  statRow(context.l10n.total_income_label,
                      money.format(vm.totalIncome)),
                  statRow(context.l10n.total_fees_label,
                      money.format(vm.totalFees)),
                  statRow(
                    context.l10n.total_income_after_fee_label,
                    money.format(vm.totalIncomeAfterFee),
                  ),
                  statRow(
                    context.l10n.average_requests_label,
                    money.format(vm.avgRequestValue),
                  ),
                  const Divider(height: 24),
                  Text(context.l10n.request_types_title,
                      style: t.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _typeRow(context.l10n.houseKeeping, vm.houseCleaning),
                  const SizedBox(height: 8),
                  _typeRow(context.l10n.deepCleaning, vm.deepCleaning),
                  const SizedBox(height: 8),
                  _typeRow(
                    context.l10n.upholstery_cleaning,
                    vm.upholsteryCleaning,
                  ),
                  const Divider(height: 24),
                  Text(
                    context.l10n.request_status_title,
                    style: t.textTheme.titleMedium,
                  ),
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
