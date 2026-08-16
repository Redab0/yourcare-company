import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/date_time_picker_field.dart';
import 'package:cleaning_service_driver/components/stats_overview.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/viewmodels/StatsVM.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_event.dart';
import 'package:cleaning_service_driver/features/bloc/statistics/statistics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, String> getPeriodLabels(BuildContext context) {
    final Map<String, String> _periodLabels = {
      'weekly': context.l10n.weekly,
      'monthly': context.l10n.monthly,
      'quartarly': context.l10n.quarterly,
      'annually': context.l10n.annually,
      'lifetime': context.l10n.lifetime,
    };
    return _periodLabels;
  }

  Map<String, String> getPeriodAPILabel(BuildContext context) {
    final Map<String, String> _periodLabels = {
      context.l10n.weekly: 'Weekly',
      context.l10n.monthly: 'Monthly',
      context.l10n.quarterly: 'Quarterly',
      context.l10n.annually: 'Annually',
      context.l10n.lifetime: 'Lifetime',
    };
    return _periodLabels;
  }

  String _periodType = 'monthly';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(fallbackRouteName: 'home'),
        title: Text(context.l10n.statistics_title),
      ),
      body: BlocConsumer<StatisticsBloc, StatisticsState>(
        listener: (ctx, state) {
          if (state is StatisticsFailure) {
            ctx.showErrorToast();
          }
        },
        builder: (ctx, state) {
          if (state is StatisticsFetched) {
            final vm = StatsVM.fromResponse(state.response);
            return Column(
              children: [
                _filtersCard(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: StatsOverview(vm: vm, currencyCode: 'KWD'),
                  ),
                ),
              ],
            );
          } else if (state is StatisticsFailure) {
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
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Future<void> _refresh() async {
    _fetchStats();
  }

  void _fetchStats() {
    context.read<StatisticsBloc>().add(
          FetchStatisticsEvent(
            periodType: _periodType,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final current = isStart ? _startDate : _endDate;
    final minDate = DateTime(2000);
    final maxDate = DateTime(now.year + 5);
    final firstDate =
        isStart ? minDate : (_startDate != null ? _startDate! : minDate);
    final lastDate =
        !isStart ? maxDate : (_endDate != null ? _endDate! : maxDate);
    var initial = current ?? now;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _startDate!.isAfter(picked)) {
          _startDate = picked;
        }
      }
    });
  }

  Widget _filtersCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        title: Text(context.l10n.filters),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          SizedBox(
            height: 8,
          ),
          DropdownButtonFormField<String>(
            value: _periodType,
            decoration: InputDecoration(
              labelText: context.l10n.period_type,
            ),
            items: getPeriodLabels(context).entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _periodType = value);
            },
          ),
          const SizedBox(height: 12),
          DateTimePickerField(
            label: context.l10n.start_date,
            value: _formatDate(_startDate),
            hintText: 'YYYY-MM-DD',
            icon: Icons.event,
            onTap: () => _pickDate(isStart: true),
          ),
          const SizedBox(height: 12),
          DateTimePickerField(
            label: context.l10n.end_date,
            value: _formatDate(_endDate),
            hintText: 'YYYY-MM-DD',
            icon: Icons.event,
            onTap: () => _pickDate(isStart: false),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _fetchStats,
            child: Text(context.l10n.filters),
          ),
        ],
      ),
    );
  }
}
