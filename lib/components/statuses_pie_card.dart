import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/viewmodels/StatsVM.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatusPieCard extends StatelessWidget {
  const StatusPieCard({super.key, required this.vm});
  final StatsVM vm;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = vm.total == 0 ? 1 : vm.total; // avoid /0

    final slices = <_Slice>[
      _Slice(RequestStatus.pending.displayText(context), vm.pending,
          Colors.orange),
      _Slice(RequestStatus.confirmed.displayText(context), vm.confirmed,
          Colors.teal),
      _Slice(RequestStatus.inProgress.displayText(context), vm.inProgress,
          Colors.blue),
      _Slice(RequestStatus.completed.displayText(context), vm.completed,
          Colors.green),
      _Slice(RequestStatus.cancelled.displayText(context), vm.canceled,
          Colors.red),
    ].where((s) => s.value > 0).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Requests Status', style: t.textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: slices.map((s) {
                    final pct = (s.value / total * 100).clamp(0, 100);
                    return PieChartSectionData(
                      value: s.value.toDouble(),
                      title: '${pct.toStringAsFixed(0)}%',
                      radius: 70,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      color: s.color,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: slices
                  .map(
                    (s) => _LegendDot(
                        label: '${s.label} (${s.value})', color: s.color),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slice {
  final String label;
  final int value;
  final Color color;
  _Slice(this.label, this.value, this.color);
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color, super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label),
    ]);
  }
}
