import 'package:cleaning_service_driver/components/statuses_pie_card.dart';
import 'package:cleaning_service_driver/data/viewmodels/StatsVM.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'kpi_row.dart';
import 'type_bar_card.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key, required this.vm, this.currencyCode = 'KWD'});
  final StatsVM vm;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.currency(
      locale: locale,
      name: 'KWD',
      symbol: 'KWD', // ← force this
      decimalDigits:
          3, // KWD typically has 3 fraction digits; use 0 if you don't want decimals
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KpiRow(
            total: vm.total,
            revenue: vm.totalRevenue,
            avg: vm.avgRequestValue,
          ),
          const SizedBox(height: 12),
          StatusPieCard(vm: vm),
          const SizedBox(height: 12),
          TypeBarCard(vm: vm),
        ],
      ),
    );
  }
}
