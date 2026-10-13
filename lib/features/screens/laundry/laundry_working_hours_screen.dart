import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_settings_cubit.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'laundry_same_day_settings_card.dart';

class LaundryWorkingHoursScreen extends StatefulWidget {
  const LaundryWorkingHoursScreen({super.key});
  @override
  State<LaundryWorkingHoursScreen> createState() =>
      _LaundryWorkingHoursScreenState();
}

class _LaundryWorkingHoursScreenState extends State<LaundryWorkingHoursScreen> {
  static const _scope = 'business_laundry_hours';
  late final _cubit = LaundrySettingsCubit(sl<LaundryRepository>());
  late final _tour = BusinessShowcaseTourController(scope: _scope);
  final _availabilityKey = GlobalKey(debugLabel: 'laundry-availability-tour');
  final _hoursKey = GlobalKey(debugLabel: 'laundry-hours-tour');
  final _sameDayKey = GlobalKey(debugLabel: 'laundry-same-day-tour');
  List<GlobalKey> get _tourKeys => [_availabilityKey, _hoursKey, _sameDayKey];
  bool _canRead = false;
  bool _canEdit = false;
  bool _checkingAccess = true;
  String? _ownerId;
  int _day = 0;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  Future<void> _loadAccess() async {
    try {
      final user = await SecureStorageService().getUser();
      if (!mounted) return;
      setState(() {
        _canRead = canAccessLaundrySettings(user);
        _canEdit = canAccessLaundrySettings(user, edit: true);
        _checkingAccess = false;
        _ownerId = businessShowcaseOwnerId(user);
      });
      if (_canRead) await _cubit.load();
    } catch (_) {
      if (mounted) setState(() => _checkingAccess = false);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _tour.dispose();
    super.dispose();
  }

  List<String> get _days => [
        context.l10n.sunday,
        context.l10n.monday,
        context.l10n.tuesday,
        context.l10n.wednesday,
        context.l10n.thursday,
        context.l10n.friday,
        context.l10n.saturday
      ];
  Future<bool> _confirmDiscard() async =>
      !_cubit.state.dirty ||
      await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                      title: Text(context.l10n.availability_discard_title),
                      content: Text(context.l10n.availability_unsaved_changes),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(context.l10n.cancel)),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(context.l10n.availability_discard))
                      ])) ==
          true;
  Future<void> _back() async {
    if (_tour.isRunning ||
        _cubit.state.saving ||
        !await _confirmDiscard() ||
        !mounted) {
      return;
    }
    setState(() => _allowExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed('laundry-main-screen');
      }
    });
  }

  Future<void> _refresh() async {
    if (await _confirmDiscard() && mounted) await _cubit.load();
  }

  Future<void> _copyDay() async {
    final targets = <int>{};
    final chosen = await showDialog<Set<int>>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: Text(context.l10n
                      .availability_apply_schedule_title(_days[_day])),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(context.l10n.availability_copy_warning),
                    for (var day = 0; day < 7; day++)
                      if (day != _day)
                        CheckboxListTile(
                            value: targets.contains(day),
                            title: Text(_days[day]),
                            onChanged: (value) => setDialogState(() {
                                  if (value == true) {
                                    targets.add(day);
                                  } else {
                                    targets.remove(day);
                                  }
                                })),
                  ])),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.l10n.cancel)),
                    FilledButton(
                        onPressed: targets.isEmpty
                            ? null
                            : () => Navigator.pop(context, targets),
                        child: Text(context.l10n.availability_apply_selected))
                  ],
                )));
    if (chosen != null && mounted) _cubit.copyDay(_day, chosen);
  }

  Widget _step(
          {required GlobalKey key,
          required int index,
          required String title,
          required String description,
          required Widget child}) =>
      BusinessShowcaseStep(
          showcaseKey: key,
          scope: _scope,
          title: title,
          description: description,
          index: index,
          itemCount: 3,
          child: child);
  Widget _timeField(
      LaundryWorkingHour slot, int index, List<LaundryWorkingHour> slots,
      {required bool end, required bool editable}) {
    final selected = end ? slot.endTime : slot.startTime;
    final values = <String>{
      selected,
      for (var minute = end ? 15 : 0;
          minute <= (end ? 1440 : 1425);
          minute += 15)
        '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}'
    }.toList()
      ..sort();
    String displayTime(String value) {
      final parts = value.split(':').map(int.parse).toList();
      final hour = parts[0] % 24;
      return MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: hour, minute: parts[1]),
          alwaysUse24HourFormat: false);
    }

    return Expanded(
        child: DropdownButtonFormField<String>(
            key: ValueKey('laundry-hour-$_day-$index-$end-$selected'),
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
                labelText:
                    end ? context.l10n.end_time : context.l10n.start_time),
            items: values
                .map((value) => DropdownMenuItem(
                    value: value, child: Text(displayTime(value))))
                .toList(),
            onChanged: !editable
                ? null
                : (value) {
                    if (value == null) return;
                    final updated = [...slots];
                    updated[index] = LaundryWorkingHour(
                        dayOfWeek: _day,
                        startTime: end ? slot.startTime : value,
                        endTime: end ? value : slot.endTime);
                    _cubit.setDay(_day, updated);
                  }));
  }

  Widget _hours(LaundrySettingsState state) {
    final slots =
        state.effectiveHours.where((slot) => slot.dayOfWeek == _day).toList();
    final editable = _canEdit && !state.saving;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.laundry_working_hours,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(context.l10n.laundry_working_hours_help),
                  if (state.workingHours == null) ...[
                    const SizedBox(height: 8),
                    Text(context.l10n.laundry_hours_unrestricted)
                  ],
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (var day = 0; day < 7; day++)
                          Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                  key: ValueKey('laundry-day-$day'),
                                  label: Text(_days[day]),
                                  selected: _day == day,
                                  onSelected: (_) =>
                                      setState(() => _day = day))),
                      ])),
                  SwitchListTile.adaptive(
                      key: const ValueKey('laundry-day-open'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(slots.isEmpty
                          ? context.l10n.laundry_day_closed
                          : context.l10n.laundry_day_open),
                      subtitle: Text(_days[_day]),
                      value: slots.isNotEmpty,
                      onChanged: editable
                          ? (value) => _cubit.toggleDay(_day, value)
                          : null),
                  for (var index = 0; index < slots.length; index++)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(children: [
                          _timeField(slots[index], index, slots,
                              end: false, editable: editable),
                          const SizedBox(width: 8),
                          _timeField(slots[index], index, slots,
                              end: true, editable: editable),
                          IconButton(
                              tooltip: context.l10n.delete,
                              onPressed: editable
                                  ? () {
                                      final updated = [...slots]
                                        ..removeAt(index);
                                      _cubit.setDay(_day, updated);
                                    }
                                  : null,
                              icon: const Icon(Icons.delete_outline)),
                        ])),
                  if (editable)
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      OutlinedButton.icon(
                          key: const ValueKey('laundry-add-hours'),
                          onPressed: state.effectiveHours.length >= 168
                              ? null
                              : () {
                                  final sorted = [...slots]..sort(
                                      (a, b) => a.endTime.compareTo(b.endTime));
                                  final start = sorted.isEmpty
                                      ? '09:00'
                                      : sorted.last.endTime == '24:00'
                                          ? '09:00'
                                          : sorted.last.endTime;
                                  final minute =
                                      LaundryWorkingHour.minutes(start) ?? 540;
                                  final endMinute =
                                      (minute + 60).clamp(0, 1440);
                                  final end =
                                      '${(endMinute ~/ 60).toString().padLeft(2, '0')}:${(endMinute % 60).toString().padLeft(2, '0')}';
                                  _cubit.setDay(_day, [
                                    ...slots,
                                    LaundryWorkingHour(
                                        dayOfWeek: _day,
                                        startTime: start,
                                        endTime: end)
                                  ]);
                                },
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.add_time_slot)),
                      TextButton(
                          onPressed: _copyDay,
                          child:
                              Text(context.l10n.availability_apply_other_days)),
                    ]),
                  if (!LaundryWorkingHour.validSchedule(state.workingHours))
                    Text(context.l10n.laundry_hours_invalid,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                ])));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<LaundrySettingsCubit,
          LaundrySettingsState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.saveSucceeded) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.laundry_settings_saved)));
        }
      },
      builder: (context, state) {
        if (_ownerId != null && state.saved != null) {
          _tour.scheduleStartOnce(
              ownerId: _ownerId!,
              journeyId: 'laundry_working_hours',
              keys: _tourKeys);
        }
        return PopScope(
            canPop: _allowExit ||
                (!state.dirty && !state.saving && !_tour.isRunning),
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _back();
            },
            child: Scaffold(
              appBar: AppBar(
                  leading: BusinessBackButton(
                      fallbackRouteName: 'laundry-main-screen',
                      onPressed: _back),
                  title: Text(context.l10n.laundry_working_hours),
                  actions: [
                    BusinessShowcaseHelpButton(
                        onPressed: () => _tour.start(_tourKeys)),
                    IconButton(
                        tooltip: context.l10n.retry,
                        onPressed: _canRead && !state.saving && !state.loading
                            ? _refresh
                            : null,
                        icon: const Icon(Icons.refresh)),
                  ]),
              body: _checkingAccess || state.loading
                  ? const Center(
                      child: AppIconSpinner(
                          assetPath: 'assets/images/ic_yourcare.png'))
                  : !_canRead
                      ? const SizedBox.shrink()
                      : state.saved == null
                          ? Center(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  Text(
                                      context.l10n.laundry_settings_load_error),
                                  TextButton(
                                      onPressed: _cubit.load,
                                      child: Text(context.l10n.retry))
                                ]))
                          : ValueListenableBuilder<bool>(
                              valueListenable:
                                  BusinessShowcaseInteractionLock.listenable,
                              builder: (_, locked, child) => AbsorbPointer(
                                  absorbing: locked || state.saving,
                                  child: child),
                              child: Center(
                                  child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 850),
                                      child: ListView(
                                          padding: const EdgeInsets.all(16),
                                          children: [
                                            _step(
                                                key: _availabilityKey,
                                                index: 0,
                                                title: context
                                                    .l10n.laundry_available,
                                                description: context.l10n
                                                    .laundry_availability_help,
                                                child: Card(
                                                    child: SwitchListTile.adaptive(
                                                        key: const ValueKey(
                                                            'laundry-available'),
                                                        title: Text(context.l10n
                                                            .laundry_available),
                                                        subtitle: Text(context
                                                            .l10n
                                                            .laundry_availability_help),
                                                        value: state.available,
                                                        onChanged: _canEdit
                                                            ? (value) =>
                                                                _cubit.change(
                                                                    available:
                                                                        value)
                                                            : null))),
                                            _step(
                                                key: _hoursKey,
                                                index: 1,
                                                title: context
                                                    .l10n.laundry_working_hours,
                                                description: context.l10n
                                                    .laundry_working_hours_help,
                                                child: _hours(state)),
                                            _step(
                                                key: _sameDayKey,
                                                index: 2,
                                                title: context
                                                    .l10n.laundry_same_day,
                                                description: context
                                                    .l10n.laundry_same_day_help,
                                                child:
                                                    LaundrySameDaySettingsCard(
                                                        cubit: _cubit,
                                                        canEdit: _canEdit,
                                                        showSave: false)),
                                            if (state.error != null)
                                              Text(
                                                  context.l10n
                                                      .laundry_same_day_save_error,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error)),
                                          ])))),
              bottomNavigationBar: !_canEdit || state.saved == null
                  ? null
                  : SafeArea(
                      minimum: const EdgeInsets.all(16),
                      child: state.saving
                          ? const SizedBox(
                              height: 48,
                              child: Center(
                                  child: AppIconSpinner(
                                      assetPath:
                                          'assets/images/ic_yourcare.png')))
                          : FilledButton(
                              key: const ValueKey('laundry-settings-save'),
                              onPressed: state.valid && state.dirty
                                  ? _cubit.save
                                  : null,
                              child: Text(context.l10n.save))),
            ));
      });
}
