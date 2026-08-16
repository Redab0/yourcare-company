import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_event.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CarWashWorkingHoursScreen extends StatefulWidget {
  const CarWashWorkingHoursScreen({super.key});

  @override
  State<CarWashWorkingHoursScreen> createState() =>
      _CarWashWorkingHoursScreenState();
}

class _CarWashWorkingHoursScreenState extends State<CarWashWorkingHoursScreen> {
  static const _tourScope = 'business_car_wash_hours_journey';
  int _selectedDayIndex = DateTime.now().weekday % 7;
  final _daysTourKey = GlobalKey(debugLabel: 'car-wash-hours-days-tour');
  final _dayStatusTourKey = GlobalKey(debugLabel: 'car-wash-hours-status-tour');
  final _applyWeekTourKey =
      GlobalKey(debugLabel: 'car-wash-hours-apply-week-tour');
  final _slotsTourKey = GlobalKey(debugLabel: 'car-wash-hours-slots-tour');
  final _saveTourKey = GlobalKey(debugLabel: 'car-wash-hours-save-tour');
  late final BusinessShowcaseTourController _tour;
  String? _tourOwnerId;

  List<GlobalKey> get _tourKeys => [
        _daysTourKey,
        _dayStatusTourKey,
        _applyWeekTourKey,
        _slotsTourKey,
        _saveTourKey,
      ];

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    SecureStorageService().getUser().then((user) {
      if (!mounted) return;
      setState(() => _tourOwnerId = businessShowcaseOwnerId(user));
    });
    context.read<CarWashBloc>().add(const LoadCarWashConfig());
  }

  @override
  void dispose() {
    _tour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(
          fallbackRouteName: 'car-wash-main-screen',
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(context.l10n.car_wash_working_hours),
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
          BusinessShowcaseHelpButton(onPressed: () => _tour.start(_tourKeys)),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<CarWashBloc, CarWashState>(
        listener: (context, state) {
          if (state.error != null) context.showErrorToast(state.error);
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(context.l10n.working_hours_saved_successfully),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.workingHours.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final ownerId = _tourOwnerId;
          if (ownerId != null) {
            _tour.scheduleStartOnce(
              ownerId: ownerId,
              journeyId: 'car_wash_working_hours',
              keys: _tourKeys,
            );
          }

          final selectedHour = _hourForSelectedDay(state.workingHours);
          final isClosed = selectedHour == null;
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
                  constraints.maxWidth >= 900 ? 1100.0 : double.infinity;
              return RefreshIndicator(
                onRefresh: _refresh,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        _scheduleTourStep(
                          key: _daysTourKey,
                          description:
                              context.l10n.business_inner_tour_schedule_days,
                          index: 0,
                          child: _daySelector(),
                        ),
                        const SizedBox(height: 12),
                        _infoBanner(),
                        const SizedBox(height: 12),
                        _scheduleTourStep(
                          key: _dayStatusTourKey,
                          description: context
                              .l10n.business_inner_tour_schedule_day_status,
                          index: 1,
                          child: _closedCard(isClosed, selectedHour),
                        ),
                        const SizedBox(height: 12),
                        _scheduleTourStep(
                          key: _applyWeekTourKey,
                          description: context
                              .l10n.business_inner_tour_schedule_apply_week,
                          index: 2,
                          child: _applyToWeekButton(selectedHour),
                        ),
                        const SizedBox(height: 16),
                        _scheduleTourStep(
                          key: _slotsTourKey,
                          description:
                              context.l10n.business_inner_tour_schedule_slots,
                          index: 3,
                          child: _timeSlotSection(selectedHour, isClosed),
                        ),
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
      bottomNavigationBar: BlocBuilder<CarWashBloc, CarWashState>(
        builder: (context, state) {
          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: SizedBox(
                  width: double.infinity,
                  child: _scheduleTourStep(
                    key: _saveTourKey,
                    description: context.l10n.business_inner_tour_schedule_save,
                    index: 4,
                    child: FilledButton.icon(
                      onPressed:
                          state.isSavingWorkingHours || _hasInvalidHours(state)
                              ? null
                              : () => context
                                  .read<CarWashBloc>()
                                  .add(const SaveCarWashWorkingHours()),
                      icon: const Icon(Icons.save),
                      label: Text(context.l10n.save_weekly_schedule),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _scheduleTourStep({
    required GlobalKey key,
    required String description,
    required int index,
    required Widget child,
  }) {
    return BusinessShowcaseStep(
      showcaseKey: key,
      scope: _tourScope,
      title: context.l10n.car_wash_working_hours,
      description: description,
      index: index,
      itemCount: _tourKeys.length,
      child: child,
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
        itemBuilder: (context, index) {
          final dayIndex = order[index];
          final selected = dayIndex == _selectedDayIndex;
          return InkWell(
            onTap: () => setState(() => _selectedDayIndex = dayIndex),
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
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    labels[dayIndex],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: selected ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.settings_repeat_every(dayLabel),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _closedCard(bool isClosed, CarWashWorkingHour? selectedHour) {
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
                color: Colors.redAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.closed_on_day(dayLabel),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
              onChanged: (value) => _toggleClosed(value, selectedHour),
            ),
          ],
        ),
      ),
    );
  }

  Widget _applyToWeekButton(CarWashWorkingHour? selectedHour) {
    final dayLabel = _dayLabels(context)[_selectedDayIndex];
    return OutlinedButton.icon(
      onPressed: selectedHour == null
          ? null
          : () => context.read<CarWashBloc>().add(
                ApplyCarWashWorkingHourToWeek(hour: selectedHour),
              ),
      icon: const Icon(Icons.copy),
      label: Text(context.l10n.apply_day_to_week(dayLabel)),
    );
  }

  Widget _timeSlotSection(CarWashWorkingHour? selectedHour, bool isClosed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _timeSlotsHeader(isClosed, selectedHour),
        const SizedBox(height: 12),
        if (isClosed)
          _closedHint()
        else if (selectedHour == null)
          Text(context.l10n.no_availability)
        else
          _workingHourCard(selectedHour),
      ],
    );
  }

  Widget _timeSlotsHeader(bool isClosed, CarWashWorkingHour? selectedHour) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.time_slots,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        TextButton.icon(
          onPressed: isClosed || selectedHour != null
              ? null
              : () => _openWorkingHourSheet(),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(context.l10n.no_services_day),
    );
  }

  Widget _workingHourCard(CarWashWorkingHour hour) {
    final invalid = _minutes(hour.endTime) <= _minutes(hour.startTime);
    final subtitle = _slotLabel(_parseTime(hour.startTime).hour);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeRangeLabel(hour.startTime, hour.endTime),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invalid ? context.l10n.invalid_time_range : subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: invalid
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).hintColor,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _openWorkingHourSheet(existing: hour),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: () => context.read<CarWashBloc>().add(
                    RemoveCarWashWorkingHour(dayOfWeek: hour.dayOfWeek),
                  ),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWorkingHourSheet({CarWashWorkingHour? existing}) async {
    final result = await showModalBottomSheet<CarWashWorkingHour>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CarWashWorkingHourSheet(
        initial: existing,
        fixedDay: _selectedDayIndex,
      ),
    );
    if (result == null || !mounted) return;
    context.read<CarWashBloc>().add(
          UpdateCarWashWorkingHour(
            dayOfWeek: result.dayOfWeek,
            startTime: result.startTime,
            endTime: result.endTime,
          ),
        );
  }

  CarWashWorkingHour? _hourForSelectedDay(List<CarWashWorkingHour> hours) {
    for (final hour in hours) {
      if (hour.dayOfWeek == _selectedDayIndex) return hour;
    }
    return null;
  }

  bool _hasInvalidHours(CarWashState state) {
    return state.workingHours.any(
      (hour) => _minutes(hour.endTime) <= _minutes(hour.startTime),
    );
  }

  void _toggleClosed(bool value, CarWashWorkingHour? selectedHour) {
    if (value) {
      context.read<CarWashBloc>().add(
            RemoveCarWashWorkingHour(dayOfWeek: _selectedDayIndex),
          );
      return;
    }
    context.read<CarWashBloc>().add(
          UpdateCarWashWorkingHour(
            dayOfWeek: _selectedDayIndex,
            startTime: selectedHour?.startTime ?? '09:00',
            endTime: selectedHour?.endTime ?? '21:00',
          ),
        );
  }

  Future<void> _refresh() async {
    context.read<CarWashBloc>().add(const LoadCarWashConfig());
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

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  int _minutes(String value) {
    final time = _parseTime(value);
    return time.hour * 60 + time.minute;
  }

  String _timeRangeLabel(String startTime, String endTime) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.jm(locale);
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return '${formatter.format(DateTime(2025, 1, 1, start.hour, start.minute))} - '
        '${formatter.format(DateTime(2025, 1, 1, end.hour, end.minute))}';
  }

  String _slotLabel(int startHour) {
    if (startHour < 12) return context.l10n.morning_service;
    if (startHour < 17) return context.l10n.midday_service;
    return context.l10n.evening_service;
  }
}

class _CarWashWorkingHourSheet extends StatefulWidget {
  final CarWashWorkingHour? initial;
  final int fixedDay;

  const _CarWashWorkingHourSheet({
    required this.fixedDay,
    this.initial,
  });

  @override
  State<_CarWashWorkingHourSheet> createState() =>
      _CarWashWorkingHourSheetState();
}

class _CarWashWorkingHourSheetState extends State<_CarWashWorkingHourSheet> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = _parseTime(widget.initial?.startTime ?? '09:00');
    _endTime = _parseTime(widget.initial?.endTime ?? '21:00');
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(isStart: true),
                  icon: const Icon(Icons.schedule),
                  label: Text(
                      '${context.l10n.start_time}: ${_formatTime(_startTime)}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickTime(isStart: false),
                  icon: const Icon(Icons.schedule),
                  label: Text(
                      '${context.l10n.end_time}: ${_formatTime(_endTime)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _save() {
    if (_minutes(_endTime) <= _minutes(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.invalid_time_range)),
      );
      return;
    }
    Navigator.of(context).pop(
      CarWashWorkingHour(
        dayOfWeek: widget.fixedDay,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
      ),
    );
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
