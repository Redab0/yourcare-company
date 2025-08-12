import 'dart:math' as math;

import 'package:cleaning_service_driver/data/viewmodels/StatsVM.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TypeBarCard extends StatelessWidget {
  const TypeBarCard({super.key, required this.vm});
  final StatsVM vm;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final house = vm.houseCleaning.toDouble();
    final deep = vm.deepCleaning.toDouble();
    final maxY = math.max(1.0, math.max(house, deep)) * 1.2;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Request Types', style: t.textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: house,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: deep,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.indigo,
                        ),
                      ],
                    ),
                  ],
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text('House Cleaning'));
                            case 1:
                              return const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text('Deep Cleaning'));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) =>
                            Text(value.toInt().toString()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
