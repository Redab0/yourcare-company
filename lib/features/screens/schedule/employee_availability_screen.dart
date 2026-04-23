import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_event.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EmployeeAvailabilityScreen extends StatefulWidget {
  const EmployeeAvailabilityScreen({super.key});

  @override
  State<EmployeeAvailabilityScreen> createState() =>
      _EmployeeAvailabilityScreenState();
}

class _EmployeeAvailabilityScreenState
    extends State<EmployeeAvailabilityScreen> {
  String? _selectedEmployeeId;
  int _selectedDayIndex = DateTime.now().weekday % 7;
  final Map<int, bool> _dayClosed = {};

  @override
  void initState() {
    super.initState();
    context.read<EmployeeAvailabilityBloc>().add(const LoadAvailabilityData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('housekeeping-main-screen'),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(context.l10n.weekly_availability_title),
            const SizedBox(height: 2),
            Text(
              context.l10n.fixed_schedule_management.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<EmployeeAvailabilityBloc, EmployeeAvailabilityState>(
        listener: (ctx, state) {
          if (state.error != null) {
            ctx.showErrorToast();
          }
        },
        builder: (ctx, state) {
          if (state.isLoading && state.slots.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final daySlots = _slotsForSelectedDay(state.slots, _selectedDayIndex);
          final isClosed = _isDayClosed();
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final maxWidth = isWide ? 1100.0 : double.infinity;
              final content = isWide
                  ? _buildWideContent(state, daySlots, isClosed)
                  : _buildNarrowContent(state, daySlots, isClosed);
              return RefreshIndicator(
                onRefresh: _refresh,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        content,
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildNarrowContent(
    EmployeeAvailabilityState state,
    List<CleanerAvailabilitySlot> daySlots,
    bool isClosed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _daySelector(),
        const SizedBox(height: 12),
        _infoBanner(),
        const SizedBox(height: 12),
        _closedCard(isClosed),
        const SizedBox(height: 12),
        _applyToWeekButton(daySlots),
        const SizedBox(height: 16),
        _timeSlotsSection(daySlots, isClosed),
        const SizedBox(height: 24),
        _employeesSection(state.employees),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWideContent(
    EmployeeAvailabilityState state,
    List<CleanerAvailabilitySlot> daySlots,
    bool isClosed,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _daySelector(),
              const SizedBox(height: 12),
              _infoBanner(),
              const SizedBox(height: 12),
              _closedCard(isClosed),
              const SizedBox(height: 12),
              _applyToWeekButton(daySlots),
              const SizedBox(height: 16),
              _timeSlotsSection(daySlots, isClosed),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _employeesSection(state.employees),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeSlotsSection(
    List<CleanerAvailabilitySlot> daySlots,
    bool isClosed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timeSlotsHeader(isClosed),
        const SizedBox(height: 12),
        if (isClosed)
          _closedHint()
        else if (daySlots.isEmpty)
          Text(context.l10n.no_availability)
        else
          ...daySlots.map((slot) => _availabilityCard(context, slot)),
      ],
    );
  }

  Widget _employeesSection(List<User> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _assignedEmployeesHeader(employees.length),
        const SizedBox(height: 12),
        ...employees.map(_employeeRow),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: _refresh,
      icon: const Icon(Icons.save),
      label: Text(context.l10n.save_weekly_schedule),
    );
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SizedBox(width: double.infinity, child: button),
        ),
      ),
    );
  }

  Widget _daySelector() {
    final labels = _dayLabels(context);
    final order = _dayOrder();
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: order.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, index) {
          final dayIndex = order[index];
          final selected = dayIndex == _selectedDayIndex;
          final label = labels[dayIndex];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedDayIndex = dayIndex;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(minWidth: 64),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: selected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoBanner() {
    final dayLabel = _dayLabels(context)[_selectedDayIndex];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _withDay(context.l10n.settings_repeat_every(dayLabel), dayLabel),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _closedCard(bool isClosed) {
    final dayLabel = _dayLabels(context)[_selectedDayIndex];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_withDay(context.l10n.closed_on_day(dayLabel), dayLabel),
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.no_services_day,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: isClosed,
              onChanged: (value) => _toggleClosed(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _applyToWeekButton(List<CleanerAvailabilitySlot> daySlots) {
    final dayLabel = _dayLabels(context)[_selectedDayIndex];
    final isDisabled = _selectedEmployeeId != null || daySlots.isEmpty;
    return OutlinedButton.icon(
      onPressed: isDisabled ? null : () => _applyDayToWeek(daySlots),
      icon: const Icon(Icons.copy),
      label: Text(_withDay(context.l10n.apply_day_to_week(dayLabel), dayLabel)),
    );
  }

  Widget _timeSlotsHeader(bool isClosed) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.time_slots,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        TextButton.icon(
          onPressed: isClosed ? null : () => _openAvailabilitySheet(),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.add_slot),
        ),
      ],
    );
  }

  Widget _closedHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(context.l10n.no_services_day),
    );
  }

  Widget _assignedEmployeesHeader(int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.assigned_employees,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Text(
          '$count ${context.l10n.total_label}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _employeeRow(User employee) {
    final isActive = employee.id == _selectedEmployeeId;
    final roleLabel = employee.role ?? context.l10n.employee;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_employeeLabel(employee),
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '$roleLabel · ${context.l10n.available}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value ? employee.id : null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _availabilityCard(BuildContext context, CleanerAvailabilitySlot slot) {
    final timeLabel = _timeRangeLabel(
      slot.startHour ?? 0,
      slot.endHour ?? 0,
    );
    final totalCleaners = slot.totalCleaners ?? 0;
    final slotLabel = _slotLabel(slot.startHour ?? 0);
    final subtitle = totalCleaners > 0
        ? '$slotLabel · ${context.l10n.total_cleaners_label}: $totalCleaners'
        : slotLabel;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.access_time,
                  color: Theme.of(context).colorScheme.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeLabel,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _openAvailabilitySheet(existing: slot),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: () => _confirmDelete(slot),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAvailabilitySheet(
      {CleanerAvailabilitySlot? existing}) async {
    final result = await showModalBottomSheet<CleanerAvailabilityRequest>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return _AvailabilitySheet(
          initial: existing,
          fixedDay: _selectedDayIndex,
        );
      },
    );
    if (result == null) return;
    if (_selectedEmployeeId != null) {
      context.read<EmployeeAvailabilityBloc>().add(
            UpdateAvailabilitySlot(_selectedEmployeeId!, result),
          );
      return;
    }
    final slotId = existing?.id;
    if (slotId != null) {
      context.read<EmployeeAvailabilityBloc>().add(
            UpdateAvailabilitySlot(slotId, result),
          );
      return;
    }
    context
        .read<EmployeeAvailabilityBloc>()
        .add(CreateAvailabilitySlot(result));
  }

  Future<void> _confirmDelete(CleanerAvailabilitySlot slot) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.delete_availability_title),
        content: Text(context.l10n.delete_availability_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (result != true) return;
    final id = _selectedEmployeeId ?? slot.id;
    if (id == null) return;
    context.read<EmployeeAvailabilityBloc>().add(DeleteAvailabilitySlot(id));
  }

  List<CleanerAvailabilitySlot> _filterSlots(
    List<CleanerAvailabilitySlot> slots,
  ) {
    if (_selectedEmployeeId == null) {
      return slots.where((slot) => slot.employeeId == null).toList();
    }
    return slots
        .where((slot) => slot.employeeId == _selectedEmployeeId)
        .toList();
  }

  List<String> _dayLabels(BuildContext context) => [
        context.l10n.sunday,
        context.l10n.monday,
        context.l10n.tuesday,
        context.l10n.wednesday,
        context.l10n.thursday,
        context.l10n.friday,
        context.l10n.saturday,
      ];
  List<int> _dayOrder() => const [6, 0, 1, 2, 3, 4, 5];

  String _timeRangeLabel(int startHour, int endHour) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.jm(locale);
    final start = DateTime(2025, 1, 1, startHour);
    final end = DateTime(2025, 1, 1, endHour);
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  String _employeeLabel(User employee) {
    return employee.username ??
        employee.phone ??
        employee.email ??
        employee.id ??
        '-';
  }

  Future<void> _refresh() async {
    context.read<EmployeeAvailabilityBloc>().add(const LoadAvailabilityData());
  }

  List<CleanerAvailabilitySlot> _slotsForSelectedDay(
    List<CleanerAvailabilitySlot> slots,
    int dayIndex,
  ) {
    final filtered = _filterSlots(slots);
    final daySlots =
        filtered.where((slot) => slot.dayOfWeek == dayIndex).toList();
    daySlots.sort((a, b) => (a.startHour ?? 0).compareTo(b.startHour ?? 0));
    return daySlots;
  }

  bool _isDayClosed() {
    return _dayClosed[_selectedDayIndex] ?? false;
  }

  void _toggleClosed(bool value) {
    setState(() {
      _dayClosed[_selectedDayIndex] = value;
    });
  }

  void _applyDayToWeek(List<CleanerAvailabilitySlot> daySlots) {
    if (daySlots.isEmpty) return;
    final bloc = context.read<EmployeeAvailabilityBloc>();
    final existingSlots = _filterSlots(bloc.state.slots);
    for (var day = 0; day < 7; day++) {
      if (day == _selectedDayIndex) continue;
      for (final slot in daySlots) {
        final exists = existingSlots.any((s) =>
            s.dayOfWeek == day &&
            s.startHour == slot.startHour &&
            s.endHour == slot.endHour);
        if (exists) continue;
        bloc.add(
          CreateAvailabilitySlot(
            CleanerAvailabilityRequest(
              dayOfWeek: day,
              startHour: slot.startHour ?? 0,
              endHour: slot.endHour ?? 0,
              totalCleaners: slot.totalCleaners ?? 1,
            ),
          ),
        );
      }
    }
  }

  String _slotLabel(int startHour) {
    if (startHour < 12) return context.l10n.morning_service;
    if (startHour < 17) return context.l10n.midday_service;
    return context.l10n.evening_service;
  }

  String _withDay(String template, String dayLabel) {
    return template.replaceAll('{day}', dayLabel);
  }
}

class _AvailabilitySheet extends StatefulWidget {
  final CleanerAvailabilitySlot? initial;
  final int? fixedDay;

  const _AvailabilitySheet({this.initial, this.fixedDay});

  @override
  State<_AvailabilitySheet> createState() => _AvailabilitySheetState();
}

class _AvailabilitySheetState extends State<_AvailabilitySheet> {
  late int _dayOfWeek;
  late int _startHour;
  late int _endHour;
  late TextEditingController _totalCleanersController;

  @override
  void initState() {
    super.initState();
    _dayOfWeek = widget.initial?.dayOfWeek ?? widget.fixedDay ?? 0;
    _startHour = widget.initial?.startHour ?? 8;
    _endHour = widget.initial?.endHour ?? 17;
    _totalCleanersController = TextEditingController(
      text: (widget.initial?.totalCleaners ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _totalCleanersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = [
      context.l10n.sunday,
      context.l10n.monday,
      context.l10n.tuesday,
      context.l10n.wednesday,
      context.l10n.thursday,
      context.l10n.friday,
      context.l10n.saturday,
    ];
    const dayOrder = [6, 0, 1, 2, 3, 4, 5];
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.initial == null
                ? context.l10n.add_availability_title
                : context.l10n.edit_availability_title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _dayOfWeek,
            decoration:
                InputDecoration(labelText: context.l10n.day_of_week_label),
            items: dayOrder
                .map(
                  (dayIndex) => DropdownMenuItem<int>(
                    value: dayIndex,
                    child: Text(dayLabels[dayIndex]),
                  ),
                )
                .toList(),
            onChanged: widget.fixedDay != null
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _dayOfWeek = value);
                  },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _startHour,
                  decoration:
                      InputDecoration(labelText: context.l10n.start_hour_label),
                  items: _hourItems(context),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _startHour = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _endHour,
                  decoration:
                      InputDecoration(labelText: context.l10n.end_hour_label),
                  items: _hourItems(context),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _endHour = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _totalCleanersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.total_cleaners_label,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _hourItems(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.jm(locale);
    return List.generate(
      24,
      (hour) => DropdownMenuItem<int>(
        value: hour,
        child: Text(formatter.format(DateTime(2025, 1, 1, hour))),
      ),
    );
  }

  void _save() {
    final totalCleaners =
        int.tryParse(_totalCleanersController.text.trim()) ?? 0;
    if (_endHour <= _startHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalid_time_range)),
      );
      return;
    }
    if (totalCleaners <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalid_total_cleaners)),
      );
      return;
    }
    Navigator.of(context).pop(
      CleanerAvailabilityRequest(
        dayOfWeek: _dayOfWeek,
        startHour: _startHour,
        endHour: _endHour,
        totalCleaners: totalCleaners,
      ),
    );
  }
}
