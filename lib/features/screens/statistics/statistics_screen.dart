import 'package:cleaning_service_driver/components/stats_overview.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/viewmodels/StatsVM.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_event.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(FetchStatisticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.statistics_title)),
      body: BlocConsumer<StatisticsBloc, StatisticsState>(
        listener: (ctx, state) {
          if (state is StatisticsFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Something went wrong')),
            );
          }
        },
        builder: (ctx, state) {
          if (state is StatisticsFetched) {
            final vm = StatsVM.fromResponse(state.response);
            return RefreshIndicator(
              onRefresh: _refresh,
              child: StatsOverview(vm: vm, currencyCode: 'KWD'),
            );
          }
          // Failure or unexpected
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Failed to load statistics'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh() async {
    context.read<StatisticsBloc>().add(FetchStatisticsEvent());
  }
}
