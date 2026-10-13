import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/schedule/cleaner_availability.dart';
import 'package:cleaning_service_driver/data/models/schedule/hourly_availability_schedule.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_event.dart';
import 'package:cleaning_service_driver/features/bloc/schedule/employee_availability_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EmployeeAvailabilityScreen extends StatefulWidget {
  final AvailabilityServiceType serviceType;

  const EmployeeAvailabilityScreen({
    super.key,
    this.serviceType = AvailabilityServiceType.houseCleaning,
  });

  @override
  State<EmployeeAvailabilityScreen> createState() =>
      _EmployeeAvailabilityScreenState();
}

class _EmployeeAvailabilityScreenState
    extends State<EmployeeAvailabilityScreen> {
  String get _tourScope =>
      'business_${widget.serviceType.apiValue}_availability_journey';

  int _selectedDayIndex = DateTime.now().weekday % 7;
  late Map<int, List<HourlyAvailabilityCell>> _scheduleByDay;
  late Map<int, List<TextEditingController>> _workerControllers;
  final Map<int, List<HourlyAvailabilityCell>> _disabledDaySchedules = {};
  final Set<int> _dirtyDays = {};
  bool _hasHydrated = false;
  bool _saveRequested = false;
  bool _showValidationErrors = false;
  bool _allowExit = false;
  bool _exitPromptVisible = false;

  final _daysTourKey = GlobalKey(debugLabel: 'availability-days-tour');
  final _dayStatusTourKey = GlobalKey(debugLabel: 'availability-status-tour');
  final _applyDaysTourKey =
      GlobalKey(debugLabel: 'availability-apply-days-tour');
  final _hoursTourKey = GlobalKey(debugLabel: 'availability-hours-tour');
  final _saveTourKey = GlobalKey(debugLabel: 'availability-save-tour');
  late final BusinessShowcaseTourController _tour;
  String? _tourOwnerId;

  List<GlobalKey> get _tourKeys => [
        _daysTourKey,
        _dayStatusTourKey,
        _applyDaysTourKey,
        _hoursTourKey,
        _saveTourKey,
      ];

  @override
  void initState() {
    super.initState();
    _scheduleByDay = HourlyAvailabilitySchedule.emptyWeek();
    _workerControllers = {
      for (var day = 0; day < HourlyAvailabilitySchedule.daysPerWeek; day++)
        day: List.generate(
          HourlyAvailabilitySchedule.hoursPerDay,
          (_) => TextEditingController(text: '1'),
        ),
    };
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    SecureStorageService().getUser().then((user) {
      if (!mounted) return;
      setState(() => _tourOwnerId = businessShowcaseOwnerId(user));
    });
    context
        .read<EmployeeAvailabilityBloc>()
        .add(LoadAvailabilityData(widget.serviceType));
  }

  @override
  void dispose() {
    for (final controllers in _workerControllers.values) {
      for (final controller in controllers) {
        controller.dispose();
      }
    }
    _tour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowExit || _dirtyDays.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onExitRequested();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BusinessBackButton(
            fallbackRouteName: _parentRouteName,
            onPressed: _onExitRequested,
          ),
          centerTitle: true,
          title: Column(
            children: [
              Text(
                context.l10n.weekly_availability_title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_serviceTitle(context)} · '
                '${context.l10n.hourly_availability.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ],
          ),
          actions: [
            BusinessShowcaseHelpButton(onPressed: () => _tour.start(_tourKeys)),
            IconButton(
              tooltip: MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel,
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocConsumer<EmployeeAvailabilityBloc, EmployeeAvailabilityState>(
          listener: _onAvailabilityStateChanged,
          builder: (context, state) {
            if (!_hasHydrated) {
              if (!state.isLoading && state.error != null) {
                return _loadError();
              }
              return const Center(
                child: AppIconSpinner(
                  assetPath: 'assets/images/ic_yourcare.png',
                  size: 88,
                ),
              );
            }

            final ownerId = _tourOwnerId;
            if (ownerId != null) {
              _tour.scheduleStartOnce(
                ownerId: ownerId,
                journeyId: '${widget.serviceType.apiValue}_availability',
                keys: _tourKeys,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          constraints.maxWidth >= 700 ? 24 : 16,
                          16,
                          constraints.maxWidth >= 700 ? 24 : 16,
                          32,
                        ),
                        children: [
                          _scheduleTourStep(
                            key: _daysTourKey,
                            title: context.l10n.weekly_availability_title,
                            description:
                                context.l10n.business_inner_tour_schedule_days,
                            index: 0,
                            child: _daySelector(),
                          ),
                          const SizedBox(height: 16),
                          _infoBanner(),
                          const SizedBox(height: 16),
                          _scheduleTourStep(
                            key: _dayStatusTourKey,
                            title: context.l10n.hourly_availability,
                            description: context
                                .l10n.business_inner_tour_schedule_day_status,
                            index: 1,
                            child: _daySummary(),
                          ),
                          const SizedBox(height: 16),
                          _scheduleTourStep(
                            key: _applyDaysTourKey,
                            title: context.l10n.availability_apply_other_days,
                            description: context
                                .l10n.business_inner_tour_schedule_apply_week,
                            index: 2,
                            child: _copyScheduleCard(),
                          ),
                          const SizedBox(height: 24),
                          _scheduleTourStep(
                            key: _hoursTourKey,
                            title: context.l10n.hourly_availability,
                            description:
                                context.l10n.business_inner_tour_schedule_slots,
                            index: 3,
                            child: _hourlySchedule(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar:
            BlocBuilder<EmployeeAvailabilityBloc, EmployeeAvailabilityState>(
          builder: (context, state) {
            if (!_hasHydrated) return const SizedBox.shrink();
            return _bottomBar(state);
          },
        ),
      ),
    );
  }

  Future<void> _onExitRequested() async {
    if (_dirtyDays.isNotEmpty && !_allowExit) {
      if (_exitPromptVisible) return;
      _exitPromptVisible = true;
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.availability_discard_title),
          content: Text(context.l10n.availability_save_before_leaving),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.availability_discard),
            ),
          ],
        ),
      );
      _exitPromptVisible = false;
      if (discard != true || !mounted) return;
      setState(() => _allowExit = true);
      await WidgetsBinding.instance.endOfFrame;
    }

    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(_parentRouteName);
    }
  }

  void _onAvailabilityStateChanged(
    BuildContext context,
    EmployeeAvailabilityState state,
  ) {
    if (state.serviceType != widget.serviceType) return;

    if (!state.isLoading && !state.isSaving && state.error != null) {
      if (_saveRequested) {
        setState(() => _saveRequested = false);
      }
      context.showErrorToast();
      return;
    }

    if (state.isLoading || state.isSaving || state.error != null) return;
    if (_hasHydrated && !_saveRequested) return;

    final wasSaved = _saveRequested;
    _hydrate(state.slots);
    if (wasSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.availability_saved)),
      );
    }
  }

  Widget _loadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.no_availability,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleTourStep({
    required GlobalKey key,
    required String title,
    required String description,
    required int index,
    required Widget child,
  }) {
    return BusinessShowcaseStep(
      showcaseKey: key,
      scope: _tourScope,
      title: title,
      description: description,
      index: index,
      itemCount: _tourKeys.length,
      child: child,
    );
  }

  Widget _daySelector() {
    final labels = _dayLabels(context);
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dayOrder.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = _dayOrder[index];
          final selected = day == _selectedDayIndex;
          final hasHours = _enabledHours(day) > 0;
          final isDirty = _dirtyDays.contains(day);
          final colors = Theme.of(context).colorScheme;
          return InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                _selectedDayIndex = day;
                _showValidationErrors = false;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minWidth: 72),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? colors.primary : colors.outlineVariant,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labels[day],
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? colors.onPrimary : colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasHours ? Icons.circle : Icons.circle_outlined,
                        size: 9,
                        color: selected
                            ? colors.onPrimary
                            : hasHours
                                ? colors.primary
                                : colors.outline,
                      ),
                      if (isDirty) ...[
                        const SizedBox(width: 5),
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: selected ? colors.onPrimary : colors.tertiary,
                        ),
                      ],
                    ],
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.primary, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.availability_hourly_hint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _daySummary() {
    final colors = Theme.of(context).colorScheme;
    final enabledHours = _enabledHours(_selectedDayIndex);
    final dayLabel = _dayLabels(context)[_selectedDayIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_serviceIcon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  enabledHours == 0
                      ? context.l10n.availability_no_hours_enabled
                      : context.l10n.availability_enabled_hours(enabledHours),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            enabledHours == 0 ? colors.error : colors.primary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            enabledHours > 0
                ? context.l10n.availability_enabled
                : context.l10n.availability_disabled,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: enabledHours > 0 ? colors.primary : colors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: enabledHours > 0
                ? context.l10n.availability_disabled
                : context.l10n.availability_enabled,
            child: Switch(
              value: enabledHours > 0,
              onChanged: _setDayEnabled,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyScheduleCard() {
    final colors = Theme.of(context).colorScheme;
    final dayLabel = _dayLabels(context)[_selectedDayIndex];
    return Material(
      color: colors.secondaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _showCopyScheduleDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.copy_all_outlined,
                color: colors.onSecondaryContainer,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.availability_apply_other_days,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dayLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colors.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hourlySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.hourly_availability,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          _dayLabels(context)[_selectedDayIndex],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
        const SizedBox(height: 14),
        ...List.generate(
          HourlyAvailabilitySchedule.hoursPerDay,
          _hourCard,
        ),
      ],
    );
  }

  Widget _hourCard(int hour) {
    final cell = _scheduleByDay[_selectedDayIndex]![hour];
    final colors = Theme.of(context).colorScheme;
    final controller = _workerControllers[_selectedDayIndex]![hour];
    final invalidWorkers = cell.isEnabled && !_validWorkerText(controller.text);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cell.isEnabled
            ? colors.surface
            : colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showValidationErrors && invalidWorkers
              ? colors.error
              : cell.isEnabled
                  ? colors.primary.withValues(alpha: 0.28)
                  : colors.outlineVariant,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _timeRangeLabel(hour, hour + 1),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cell.isEnabled
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (constraints.maxWidth >= 500) ...[
                Text(
                  cell.isEnabled
                      ? context.l10n.availability_enabled
                      : context.l10n.availability_disabled,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cell.isEnabled
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
              ],
              Tooltip(
                message: cell.isEnabled
                    ? context.l10n.availability_enabled
                    : context.l10n.availability_disabled,
                child: Switch(
                  value: cell.isEnabled,
                  onChanged: (value) => _setHourEnabled(hour, value),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: context.l10n.total_cleaners_label,
                child: Icon(
                  Icons.groups_2_outlined,
                  size: 20,
                  color: cell.isEnabled ? colors.primary : colors.outline,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 62,
                child: TextField(
                  controller: controller,
                  enabled: cell.isEnabled,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: (value) => _onWorkerCountChanged(hour, value),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '1',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _showValidationErrors && invalidWorkers
                            ? colors.error
                            : colors.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _showValidationErrors && invalidWorkers
                            ? colors.error
                            : colors.primary,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomBar(EmployeeAvailabilityState state) {
    final hasChanges = _dirtyDays.isNotEmpty;
    final isSaving = state.isSaving || _saveRequested;
    final changedDaysLabel = Text(
      context.l10n.availability_changed_days(_dirtyDays.length),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
    final saveButton = _scheduleTourStep(
      key: _saveTourKey,
      title: context.l10n.save_weekly_schedule,
      description: context.l10n.business_inner_tour_schedule_save,
      index: 4,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: !hasChanges || isSaving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(context.l10n.save_weekly_schedule),
        ),
      ),
    );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 520) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasChanges) ...[
                        changedDaysLabel,
                        const SizedBox(height: 10),
                      ],
                      saveButton,
                    ],
                  );
                }
                return Row(
                  children: [
                    if (hasChanges)
                      Expanded(child: changedDaysLabel)
                    else
                      const Spacer(),
                    const SizedBox(width: 16),
                    SizedBox(width: 300, child: saveButton),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _hydrate(List<CleanerAvailabilitySlot> slots) {
    final schedule = HourlyAvailabilitySchedule.fromSlots(slots);
    setState(() {
      _scheduleByDay = schedule;
      for (var day = 0; day < HourlyAvailabilitySchedule.daysPerWeek; day++) {
        for (var hour = 0;
            hour < HourlyAvailabilitySchedule.hoursPerDay;
            hour++) {
          _workerControllers[day]![hour].text =
              schedule[day]![hour].totalCleaners.toString();
        }
      }
      _disabledDaySchedules.clear();
      _dirtyDays.clear();
      _showValidationErrors = false;
      _hasHydrated = true;
      _saveRequested = false;
    });
  }

  void _setHourEnabled(int hour, bool isEnabled) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      final controller = _workerControllers[_selectedDayIndex]![hour];
      var workers = int.tryParse(controller.text.trim()) ?? 1;
      if (workers < 1) workers = 1;
      if (isEnabled && !_validWorkerText(controller.text)) {
        controller.text = workers.toString();
      }
      _scheduleByDay[_selectedDayIndex]![hour] =
          _scheduleByDay[_selectedDayIndex]![hour].copyWith(
        isEnabled: isEnabled,
        totalCleaners: workers,
      );
      _dirtyDays.add(_selectedDayIndex);
    });
  }

  void _setDayEnabled(bool isEnabled) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      final currentSchedule = _scheduleByDay[_selectedDayIndex]!;
      if (!isEnabled) {
        if (currentSchedule.any((cell) => cell.isEnabled)) {
          _disabledDaySchedules[_selectedDayIndex] =
              HourlyAvailabilitySchedule.copyDay(currentSchedule);
        }
        _scheduleByDay[_selectedDayIndex] = currentSchedule
            .map((cell) => cell.copyWith(isEnabled: false))
            .toList(growable: false);
      } else {
        final previousSchedule =
            _disabledDaySchedules.remove(_selectedDayIndex);
        if (previousSchedule != null &&
            previousSchedule.any((cell) => cell.isEnabled)) {
          _scheduleByDay[_selectedDayIndex] =
              HourlyAvailabilitySchedule.copyDay(previousSchedule);
        } else {
          _scheduleByDay[_selectedDayIndex] = currentSchedule.map((cell) {
            final workers = cell.totalCleaners < 1 ? 1 : cell.totalCleaners;
            return cell.copyWith(
              isEnabled: true,
              totalCleaners: workers,
            );
          }).toList(growable: false);
        }
        for (var hour = 0;
            hour < HourlyAvailabilitySchedule.hoursPerDay;
            hour++) {
          final cell = _scheduleByDay[_selectedDayIndex]![hour];
          _workerControllers[_selectedDayIndex]![hour].text =
              cell.totalCleaners.toString();
        }
      }
      _dirtyDays.add(_selectedDayIndex);
    });
  }

  void _onWorkerCountChanged(int hour, String value) {
    final workers = int.tryParse(value.trim());
    setState(() {
      if (workers != null && workers > 0) {
        _scheduleByDay[_selectedDayIndex]![hour] =
            _scheduleByDay[_selectedDayIndex]![hour].copyWith(
          totalCleaners: workers,
        );
      }
      _dirtyDays.add(_selectedDayIndex);
    });
  }

  Future<void> _showCopyScheduleDialog() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_synchronizeWorkerCounts({_selectedDayIndex})) {
      setState(() => _showValidationErrors = true);
      _showInvalidWorkersMessage();
      return;
    }

    final targets = _dayOrder
        .where((day) => day != _selectedDayIndex)
        .toList(growable: false);
    var selectedDays = <int>{};
    if (!mounted) return;
    final result = await showDialog<Set<int>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                context.l10n.availability_apply_schedule_title(
                  _dayLabels(context)[_selectedDayIndex],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.availability_select_days_hint),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          selectedDays = selectedDays.length == targets.length
                              ? <int>{}
                              : targets.toSet();
                        });
                      },
                      icon: const Icon(Icons.done_all),
                      label: Text(context.l10n.availability_select_all),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: targets.map((day) {
                        return FilterChip(
                          label: Text(_dayLabels(context)[day]),
                          selected: selectedDays.contains(day),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer
                            .withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.availability_copy_warning,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: selectedDays.isEmpty
                      ? null
                      : () => Navigator.of(dialogContext)
                          .pop(Set<int>.from(selectedDays)),
                  child: Text(context.l10n.availability_apply_selected),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty || !mounted) return;
    final sourceSchedule = _scheduleByDay[_selectedDayIndex]!;
    final sourceControllers = _workerControllers[_selectedDayIndex]!;
    setState(() {
      for (final day in result) {
        _scheduleByDay[day] =
            HourlyAvailabilitySchedule.copyDay(sourceSchedule);
        _disabledDaySchedules.remove(day);
        for (var hour = 0;
            hour < HourlyAvailabilitySchedule.hoursPerDay;
            hour++) {
          _workerControllers[day]![hour].text = sourceControllers[hour].text;
        }
      }
      _dirtyDays.addAll(result);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.availability_schedule_copied)),
    );
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_dirtyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.availability_no_changes)),
      );
      return;
    }
    if (!_synchronizeWorkerCounts(_dirtyDays)) {
      setState(() {
        _showValidationErrors = true;
        _selectedDayIndex = _firstInvalidDay() ?? _selectedDayIndex;
      });
      _showInvalidWorkersMessage();
      return;
    }

    final scheduleByDay = <int, List<CleanerAvailabilityRequest>>{
      for (final day in _dirtyDays)
        day: HourlyAvailabilitySchedule.requestsForDay(
          dayOfWeek: day,
          hours: _scheduleByDay[day]!,
          serviceType: widget.serviceType,
        ),
    };
    setState(() => _saveRequested = true);
    context.read<EmployeeAvailabilityBloc>().add(
          ReplaceAvailabilityDays(
            serviceType: widget.serviceType,
            scheduleByDay: scheduleByDay,
          ),
        );
  }

  bool _synchronizeWorkerCounts(Iterable<int> days) {
    var isValid = true;
    for (final day in days) {
      for (var hour = 0;
          hour < HourlyAvailabilitySchedule.hoursPerDay;
          hour++) {
        final cell = _scheduleByDay[day]![hour];
        if (!cell.isEnabled) continue;
        final workers =
            int.tryParse(_workerControllers[day]![hour].text.trim());
        if (workers == null || workers < 1) {
          isValid = false;
          continue;
        }
        _scheduleByDay[day]![hour] = cell.copyWith(totalCleaners: workers);
      }
    }
    return isValid;
  }

  int? _firstInvalidDay() {
    for (final day in _dayOrder) {
      if (!_dirtyDays.contains(day)) continue;
      for (var hour = 0;
          hour < HourlyAvailabilitySchedule.hoursPerDay;
          hour++) {
        if (_scheduleByDay[day]![hour].isEnabled &&
            !_validWorkerText(_workerControllers[day]![hour].text)) {
          return day;
        }
      }
    }
    return null;
  }

  void _showInvalidWorkersMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.availability_invalid_workers)),
    );
  }

  bool _validWorkerText(String value) {
    final workers = int.tryParse(value.trim());
    return workers != null && workers > 0;
  }

  int _enabledHours(int day) {
    return _scheduleByDay[day]!.where((cell) => cell.isEnabled).length;
  }

  Future<void> _refresh() async {
    if (_dirtyDays.isNotEmpty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.availability_discard_title),
          content: Text(context.l10n.availability_unsaved_changes),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.availability_discard),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    setState(() {
      _hasHydrated = false;
      _saveRequested = false;
      _dirtyDays.clear();
      _showValidationErrors = false;
    });
    context
        .read<EmployeeAvailabilityBloc>()
        .add(LoadAvailabilityData(widget.serviceType));
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

  static const List<int> _dayOrder = [6, 0, 1, 2, 3, 4, 5];

  String _timeRangeLabel(int startHour, int endHour) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.jm(locale);
    final start = DateTime(2025, 1, 1, startHour);
    final end = DateTime(2025, 1, 1, endHour);
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  IconData get _serviceIcon {
    switch (widget.serviceType) {
      case AvailabilityServiceType.houseCleaning:
        return Icons.cleaning_services;
      case AvailabilityServiceType.carWash:
        return Icons.local_car_wash_outlined;
      case AvailabilityServiceType.upholsteryCleaning:
        return Icons.chair_outlined;
    }
  }

  String get _parentRouteName {
    switch (widget.serviceType) {
      case AvailabilityServiceType.houseCleaning:
        return 'housekeeping-main-screen';
      case AvailabilityServiceType.carWash:
        return 'car-wash-main-screen';
      case AvailabilityServiceType.upholsteryCleaning:
        return 'upholstery-configuration-screen';
    }
  }

  String _serviceTitle(BuildContext context) {
    switch (widget.serviceType) {
      case AvailabilityServiceType.houseCleaning:
        return context.l10n.house_keeping_title;
      case AvailabilityServiceType.carWash:
        return context.l10n.car_wash_service;
      case AvailabilityServiceType.upholsteryCleaning:
        return context.l10n.upholstery_cleaning;
    }
  }
}
