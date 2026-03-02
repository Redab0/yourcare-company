import 'package:cleaning_service_driver/components/date_time_picker_field.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/calendar/employee_calendar_response.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_event.dart';
import 'package:cleaning_service_driver/features/bloc/calendar/employee_calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum CalendarViewMode {
  monthly,
  weekly,
  hourly,
}

class EmployeeCalendarScreen extends StatefulWidget {
  const EmployeeCalendarScreen({super.key});

  @override
  State<EmployeeCalendarScreen> createState() => _EmployeeCalendarScreenState();
}

class _EmployeeCalendarScreenState extends State<EmployeeCalendarScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  CalendarViewMode _viewMode = CalendarViewMode.monthly;
  String? _requestType;
  RequestStatus? _requestStatus;
  String? _employeeId;
  String? _teamId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _startDate = _focusedMonth;
    _endDate = DateTime(now.year, now.month + 1, 0);
    _selectedDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<EmployeeCalendarBloc>()
          .add(const LoadEmployeeCalendarFilters());
      _fetchCalendar();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.employee_calendar),
      ),
      body: BlocConsumer<EmployeeCalendarBloc, EmployeeCalendarState>(
        listener: (ctx, state) {
          if (state.error != null) {
            ctx.showErrorToast();
          }
        },
        builder: (ctx, state) {
          return Column(
            children: [
              _filtersCard(context, state),
              Expanded(child: _buildContent(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, EmployeeCalendarState state) {
    if (state.error != null && state.data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.no_calendar_data),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchCalendar,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return Center(child: Text(context.l10n.no_calendar_data));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // if (data.summary != null) _buildSummary(context, data.summary!),
          // const SizedBox(height: 12),
          // if (data.employeeSummaries?.isNotEmpty ?? false)
          //   _buildEmployeeSummaries(context, data.employeeSummaries!),
          // if (data.teamSummaries?.isNotEmpty ?? false)
          //   _buildTeamSummaries(context, data.teamSummaries!),
          // const SizedBox(height: 12),
          _buildViewSwitcher(context),
          const SizedBox(height: 12),
          _buildActiveView(context, data.calendar ?? const []),
        ],
      ),
    );
  }

  Widget _filtersCard(BuildContext context, EmployeeCalendarState state) {
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
          const SizedBox(height: 8),
          if (state.isLoadingFilters)
            const LinearProgressIndicator(minHeight: 2),
          if (state.isLoadingFilters) const SizedBox(height: 12),
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
          DropdownButtonFormField<String?>(
            value: _employeeId,
            decoration: InputDecoration(labelText: context.l10n.employee_id),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.all),
              ),
              ...state.users.map((user) {
                return DropdownMenuItem<String?>(
                  value: user.id,
                  child: Text(_userLabel(user)),
                );
              }),
            ],
            onChanged: (value) => setState(() => _employeeId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _teamId,
            decoration: InputDecoration(labelText: context.l10n.team_id),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.all),
              ),
              ...state.teams.map((team) {
                return DropdownMenuItem<String?>(
                  value: team.id,
                  child: Text(_teamLabel(team)),
                );
              }),
            ],
            onChanged: (value) => setState(() => _teamId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _requestType,
            decoration: InputDecoration(labelText: context.l10n.request_type),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.all),
              ),
              DropdownMenuItem<String?>(
                value: 'houseCleaning',
                child: Text(context.l10n.houseKeeping),
              ),
              DropdownMenuItem<String?>(
                value: 'deepCleaning',
                child: Text(context.l10n.deepCleaning),
              ),
              DropdownMenuItem<String?>(
                value: 'upholsteryCleaning',
                child: Text(context.l10n.upholstery_cleaning),
              ),
            ],
            onChanged: (value) => setState(() => _requestType = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RequestStatus?>(
            value: _requestStatus,
            decoration: InputDecoration(labelText: context.l10n.request_status),
            items: [
              DropdownMenuItem<RequestStatus?>(
                value: null,
                child: Text(context.l10n.all),
              ),
              ..._statusOptions().map((status) {
                return DropdownMenuItem<RequestStatus?>(
                  value: status,
                  child: Text(status.displayText(context)),
                );
              }),
            ],
            onChanged: (value) => setState(() => _requestStatus = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _fetchCalendar,
            child: Text(context.l10n.apply_filters),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher(BuildContext context) {
    final labels = <CalendarViewMode, String>{
      CalendarViewMode.monthly: context.l10n.monthly,
      CalendarViewMode.weekly: context.l10n.weekly,
      CalendarViewMode.hourly: context.l10n.hourly,
    };
    final modes = CalendarViewMode.values;
    return Center(
      child: ToggleButtons(
        isSelected: modes.map((m) => m == _viewMode).toList(),
        onPressed: (index) => _changeView(modes[index]),
        borderRadius: BorderRadius.circular(12),
        children: modes
            .map(
              (mode) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(labels[mode] ?? ''),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActiveView(BuildContext context, List<CalendarDay> days) {
    switch (_viewMode) {
      case CalendarViewMode.weekly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWeekHeader(context),
            const SizedBox(height: 8),
            _buildWeekStrip(context, days),
            const SizedBox(height: 12),
            _buildSelectedDayDetails(context, days),
          ],
        );
      case CalendarViewMode.hourly:
        return _buildHourlyView(context, days);
      case CalendarViewMode.monthly:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthHeader(context),
            const SizedBox(height: 8),
            _buildWeekdayHeader(context),
            const SizedBox(height: 6),
            _buildMonthGrid(context, days),
            const SizedBox(height: 12),
            _buildSelectedDayDetails(context, days),
          ],
        );
    }
  }

  void _changeView(CalendarViewMode mode) {
    if (_viewMode == mode) return;
    final anchor = _selectedDate ?? DateTime.now();
    setState(() {
      _viewMode = mode;
      _setRangeForAnchor(anchor);
    });
    _fetchCalendar();
  }

  void _setRangeForAnchor(DateTime anchor) {
    final range = _rangeFor(anchor);
    _selectedDate = anchor;
    _focusedMonth = DateTime(anchor.year, anchor.month, 1);
    _startDate = range.start;
    _endDate = range.end;
  }

  DateTimeRange _rangeFor(DateTime anchor) {
    final date = _dateOnly(anchor);
    switch (_viewMode) {
      case CalendarViewMode.weekly:
        final start = _weekStart(date);
        return DateTimeRange(
            start: start, end: start.add(const Duration(days: 6)));
      case CalendarViewMode.hourly:
        return DateTimeRange(start: date, end: date);
      case CalendarViewMode.monthly:
      default:
        final start = DateTime(date.year, date.month, 1);
        final end = DateTime(date.year, date.month + 1, 0);
        return DateTimeRange(start: start, end: end);
    }
  }

  DateTime _weekStart(DateTime date) {
    final firstDayIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final weekdayFromSunday = date.weekday % 7;
    final diff = (weekdayFromSunday - firstDayIndex + 7) % 7;
    return _dateOnly(date).subtract(Duration(days: diff));
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget _buildSummary(BuildContext context, CalendarSummary summary) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.currency(
      locale: locale,
      name: 'KWD',
      symbol: 'KWD',
      decimalDigits: 3,
    );

    return Column(
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
                Text(context.l10n.summary, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _statRow(
                  context.l10n.total_works_label,
                  '${summary.totalWorks ?? 0}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.total_revenue_label,
                  money.format(summary.totalRevenue ?? 0),
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.completed,
                  '${summary.completedCount ?? 0}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.confirmed,
                  '${summary.confirmedCount ?? 0}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.inprogress,
                  '${summary.inProgressCount ?? 0}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.pending,
                  '${summary.pendingCount ?? 0}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.cancelled,
                  '${summary.canceledCount ?? 0}',
                ),
              ],
            ),
          ),
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
                Text(context.l10n.request_types,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _statRow(
                  context.l10n.houseKeeping,
                  '${_countByType(summary.worksByType, const [
                        'houseCleaning'
                      ])}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.deepCleaning,
                  '${_countByType(summary.worksByType, const [
                        'deepCleaning'
                      ])}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  context.l10n.upholstery_cleaning,
                  '${_countByType(summary.worksByType, const [
                        'upholsteryCleaning',
                        'upholstery'
                      ])}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeSummaries(
    BuildContext context,
    List<EmployeeSummary> employees,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.currency(
      locale: locale,
      name: 'KWD',
      symbol: 'KWD',
      decimalDigits: 3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.employee_summary, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...employees.map((employee) {
          final info = employee.employee;
          final name = info?.username ?? '-';
          final phone = info?.phone;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phone == null || phone.isEmpty ? name : '$name - $phone',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _statRow(
                    context.l10n.total_works_label,
                    '${employee.totalWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.completed,
                    '${employee.completedWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.inprogress,
                    '${employee.inProgressWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.confirmed,
                    '${employee.confirmedWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.total_revenue_label,
                    money.format(employee.totalRevenue ?? 0),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTeamSummaries(
    BuildContext context,
    List<TeamSummary> teams,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.currency(
      locale: locale,
      name: 'KWD',
      symbol: 'KWD',
      decimalDigits: 3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(context.l10n.team_summary, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...teams.map((teamSummary) {
          final team = teamSummary.team;
          final members = team?.members ?? [];
          final membersLabel = members.isEmpty
              ? context.l10n.no_team_assigned
              : members
                  .map((member) => member.username ?? '-')
                  .where((name) => name.trim().isNotEmpty)
                  .join(', ');
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(membersLabel, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _statRow(
                    context.l10n.total_works_label,
                    '${teamSummary.totalWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.completed,
                    '${teamSummary.completedWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.inprogress,
                    '${teamSummary.inProgressWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.confirmed,
                    '${teamSummary.confirmedWorks ?? 0}',
                  ),
                  const SizedBox(height: 6),
                  _statRow(
                    context.l10n.total_revenue_label,
                    money.format(teamSummary.totalRevenue ?? 0),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    final start = _weekStart(_selectedDate ?? _startDate);
    final end = start.add(const Duration(days: 6));
    final locale = Localizations.localeOf(context).toLanguageTag();
    final rangeLabel =
        '${DateFormat.MMMd(locale).format(start)} - ${DateFormat.MMMd(locale).format(end)}';
    return Row(
      children: [
        IconButton(
          onPressed: _goToPreviousWeek,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              rangeLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          onPressed: _goToNextWeek,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekStrip(BuildContext context, List<CalendarDay> days) {
    final start = _weekStart(_selectedDate ?? _startDate);
    final dateKeyFormat = DateFormat('yyyy-MM-dd');
    final dayMap = {
      for (final day in days)
        if (day.date != null) dateKeyFormat.format(day.date!): day,
    };
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekdayLabels = DateFormat.E(locale);
    return Row(
      children: List.generate(7, (index) {
        final date = start.add(Duration(days: index));
        final key = dateKeyFormat.format(date);
        final dayData = dayMap[key];
        final total = dayData?.totalWorksCount ?? 0;
        final isSelected =
            _selectedDate != null && _isSameDay(_selectedDate!, date);
        final isToday = _isSameDay(DateTime.now(), date);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => setState(() => _selectedDate = date),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                      : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      weekdayLabels.format(date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (total > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$total',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHourlyView(BuildContext context, List<CalendarDay> days) {
    final selected = _selectedDate ?? _startDate;
    final dayData = _findDayData(selected, days);
    final works = dayData.works ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDayHeader(context),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 24,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, hour) {
            final slotStart = DateTime(
              selected.year,
              selected.month,
              selected.day,
              hour,
            );
            final slotWorks = _worksForHour(slotStart, works);
            return _buildHourRow(context, slotStart, slotWorks);
          },
        ),
      ],
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    final selected = _selectedDate ?? _startDate;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = DateFormat.yMMMMd(locale).format(selected);
    return Row(
      children: [
        IconButton(
          onPressed: _goToPreviousDay,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          onPressed: _goToNextDay,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildHourRow(
    BuildContext context,
    DateTime slotStart,
    List<CalendarWork> works,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = DateFormat.jm(locale).format(slotStart);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Expanded(
          child: works.isEmpty
              ? Text('-', style: Theme.of(context).textTheme.bodySmall)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:
                      works.map((work) => _buildWorkCard(context, work)).toList(),
                ),
        ),
      ],
    );
  }

  List<CalendarWork> _worksForHour(
    DateTime slotStart,
    List<CalendarWork> works,
  ) {
    final slotEnd = slotStart.add(const Duration(hours: 1));
    final matches = <CalendarWork>[];
    for (final work in works) {
      final workStart = _toLocal(work.startTime ?? work.scheduledTime);
      if (workStart == null) continue;
      DateTime? workEnd = _toLocal(work.endTime);
      if (workEnd == null &&
          work.durationHours != null &&
          work.durationHours! > 0) {
        workEnd = workStart.add(Duration(hours: work.durationHours!));
      }
      workEnd ??= workStart.add(const Duration(hours: 1));
      if (_overlaps(workStart, workEnd, slotStart, slotEnd)) {
        matches.add(work);
      }
    }
    return matches;
  }

  Widget _buildMonthHeader(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      children: [
        IconButton(
          onPressed: _goToPreviousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              DateFormat.yMMMM(locale).format(_focusedMonth),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          onPressed: _goToNextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayIndex = localizations.firstDayOfWeekIndex;
    final labels = localizations.narrowWeekdays;
    final ordered = List.generate(
      7,
      (index) => labels[(firstDayIndex + index) % 7],
    );
    return Row(
      children: ordered
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthGrid(BuildContext context, List<CalendarDay> days) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayIndex = localizations.firstDayOfWeekIndex;
    final dateKeyFormat = DateFormat('yyyy-MM-dd');
    final dayMap = {
      for (final day in days)
        if (day.date != null) dateKeyFormat.format(day.date!): day,
    };

    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final weekdayFromSunday = firstOfMonth.weekday % 7;
    final leadingEmpty = (weekdayFromSunday - firstDayIndex + 7) % 7;
    const totalCells = 42;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.15,
      ),
      itemCount: totalCells,
      itemBuilder: (ctx, index) {
        final dayNumber = index - leadingEmpty + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }
        final date =
            DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
        final key = dateKeyFormat.format(date);
        final dayData = dayMap[key];
        final total = dayData?.totalWorksCount ?? 0;
        final isSelected =
            _selectedDate != null && _isSameDay(_selectedDate!, date);
        final isToday = _isSameDay(DateTime.now(), date);
        return InkWell(
          onTap: () => setState(() => _selectedDate = date),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$dayNumber',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    if (total > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$total',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (dayData != null && (dayData.works?.isNotEmpty ?? false))
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayDetails(
    BuildContext context,
    List<CalendarDay> days,
  ) {
    final selected = _selectedDate ?? _startDate;
    final dayData = _findDayData(selected, days);
    final title = _formatReadableDate(selected);
    final total = dayData.totalWorksCount ?? 0;
    final works = dayData.works ?? const [];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${context.l10n.total_works_label}: $total',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (works.isEmpty)
              Text(context.l10n.no_requests)
            else
              ...works.map((work) => _buildWorkCard(context, work)),
          ],
        ),
      ),
    );
  }

  void _goToPreviousMonth() {
    final prev = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    setState(() {
      _setRangeForAnchor(prev);
    });
    _fetchCalendar();
  }

  void _goToNextMonth() {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    setState(() {
      _setRangeForAnchor(next);
    });
    _fetchCalendar();
  }

  void _goToPreviousWeek() {
    final anchor =
        (_selectedDate ?? _startDate).subtract(const Duration(days: 7));
    setState(() {
      _setRangeForAnchor(anchor);
    });
    _fetchCalendar();
  }

  void _goToNextWeek() {
    final anchor = (_selectedDate ?? _startDate).add(const Duration(days: 7));
    setState(() {
      _setRangeForAnchor(anchor);
    });
    _fetchCalendar();
  }

  void _goToPreviousDay() {
    final anchor =
        (_selectedDate ?? _startDate).subtract(const Duration(days: 1));
    setState(() {
      _setRangeForAnchor(anchor);
    });
    _fetchCalendar();
  }

  void _goToNextDay() {
    final anchor = (_selectedDate ?? _startDate).add(const Duration(days: 1));
    setState(() {
      _setRangeForAnchor(anchor);
    });
    _fetchCalendar();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  CalendarDay _findDayData(DateTime date, List<CalendarDay> days) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return days.firstWhere(
      (day) =>
          day.date != null &&
          DateFormat('yyyy-MM-dd').format(day.date!) == dateKey,
      orElse: () => CalendarDay(date: date, works: const []),
    );
  }

  bool _overlaps(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  DateTime? _toLocal(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.isUtc ? dateTime.toLocal() : dateTime;
  }

  Widget _buildWorkCard(BuildContext context, CalendarWork work) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = NumberFormat.currency(
      locale: locale,
      name: 'KWD',
      symbol: 'KWD',
      decimalDigits: 3,
    );
    final typeLabel = _typeLabel(context, work.requestType);
    final idLabel = work.readableId ?? work.requestId ?? '-';
    final scheduleLabel =
        _formatTimeRange(work.startTime, work.endTime, work.scheduledTime);
    final customerLabel = _customerLabel(work.customer);
    final assigneesLabel = _assigneesLabel(work);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(typeLabel, style: theme.textTheme.titleMedium),
              ),
              Chip(
                label: Text(
                  work.requestStatus.displayText(context),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: statusColor(work.requestStatus),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('# $idLabel', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          if (scheduleLabel.isNotEmpty)
            Text(scheduleLabel, style: theme.textTheme.bodySmall),
          if ((work.totalPrice ?? 0) > 0)
            Text(money.format(work.totalPrice),
                style: theme.textTheme.bodySmall),
          if (customerLabel.isNotEmpty)
            Text(customerLabel, style: theme.textTheme.bodySmall),
          if (assigneesLabel.isNotEmpty)
            Text(
              '${context.l10n.assigned_to}: $assigneesLabel',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatReadableDate(DateTime? date) {
    if (date == null) return '-';
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('EEE, MMM d', locale).format(date);
  }

  String _formatTimeRange(
    DateTime? start,
    DateTime? end,
    DateTime? scheduled,
  ) {
    final localStart = _toLocal(start);
    final localEnd = _toLocal(end);
    final localScheduled = _toLocal(scheduled);
    if (localStart == null && localScheduled == null) return '';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final timeFormat = DateFormat('hh:mm a', locale);
    if (localStart != null && localEnd != null) {
      return '${timeFormat.format(localStart)} - ${timeFormat.format(localEnd)}';
    }
    final target = localScheduled ?? localStart;
    return target == null ? '' : timeFormat.format(target);
  }

  String _typeLabel(BuildContext context, String? type) {
    switch (type?.toLowerCase()) {
      case 'deepcleaning':
        return context.l10n.deepCleaning;
      case 'housecleaning':
        return context.l10n.houseKeeping;
      case 'upholsterycleaning':
      case 'upholstery':
        return context.l10n.upholstery_cleaning;
      default:
        return type ?? '-';
    }
  }

  String _customerLabel(CalendarCustomer? customer) {
    if (customer == null) return '';
    final name = customer.name ?? '';
    final phone = customer.phone ?? '';
    if (name.isEmpty && phone.isEmpty) return '';
    if (name.isEmpty) return phone;
    if (phone.isEmpty) return name;
    return '$name - $phone';
  }

  String _assigneesLabel(CalendarWork work) {
    final cleaners = work.assignedCleaners ?? [];
    if (cleaners.isNotEmpty) {
      return cleaners
          .map((e) => e.username ?? '')
          .where((name) => name.trim().isNotEmpty)
          .join(', ');
    }
    final teamMembers = work.assignedTeam?.members ?? [];
    if (teamMembers.isEmpty) return '';
    return teamMembers
        .map((e) => e.username ?? '')
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
  }

  Widget _statRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );

  List<RequestStatus> _statusOptions() {
    final options = <RequestStatus>[];
    for (final status in RequestStatus.values) {
      if (status == RequestStatus.unknown) continue;
      if (options.any((s) => requestStatusToJson(s) == status.toJson())) {
        continue;
      }
      options.add(status);
    }
    return options;
  }

  int _countByType(Map<String, int> map, List<String> keys) {
    for (final key in keys) {
      final direct = map[key];
      if (direct != null) return direct;
      final match = map.entries
          .firstWhere(
            (entry) => entry.key.toLowerCase() == key.toLowerCase(),
            orElse: () => const MapEntry('', 0),
          )
          .value;
      if (match > 0) return match;
    }
    return 0;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final current = isStart ? _startDate : _endDate;
    final minDate = DateTime(2000);
    final maxDate = DateTime(now.year + 5);
    final firstDate = isStart
        ? minDate
        : (_startDate.isAfter(minDate) ? _startDate : minDate);
    final lastDate =
        !isStart ? maxDate : (_endDate.isBefore(maxDate) ? _endDate : maxDate);
    var initial = current;
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
      _setRangeForAnchor(picked);
    });
    _fetchCalendar();
  }

  Future<void> _refresh() async {
    _fetchCalendar();
  }

  void _fetchCalendar() {
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
    context.read<EmployeeCalendarBloc>().add(
          FetchEmployeeCalendar(
            startDate: _startDate,
            endDate: _endDate,
            employeeId: _employeeId,
            teamId: _teamId,
            requestType: _requestType,
            requestStatus: _requestStatus == null
                ? null
                : requestStatusToJson(_requestStatus!),
          ),
        );
  }

  String _userLabel(User user) {
    return user.username ?? user.phone ?? user.email ?? user.id ?? '-';
  }

  String _teamLabel(TeamModel team) {
    return team.name ?? team.id ?? '-';
  }
}
