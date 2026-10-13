import 'package:cleaning_service_driver/core/utils/request_action_error.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LaundrySettingsState {
  final LaundrySettings? saved;
  final bool loading;
  final bool saving;
  final bool enabled;
  final String? cutoff;
  final bool available;
  final List<LaundryWorkingHour>? workingHours;
  final String minimumChargeText;
  final String? error;
  final bool saveSucceeded;
  const LaundrySettingsState(
      {this.saved,
      this.loading = false,
      this.saving = false,
      this.enabled = false,
      this.cutoff,
      this.available = true,
      this.workingHours,
      this.minimumChargeText = '0',
      this.error,
      this.saveSucceeded = false});
  double? get minimumCharge {
    final text = minimumChargeText.trim().runes.map((rune) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        return String.fromCharCode(rune - 0x0660 + 0x30);
      }
      if (rune >= 0x06f0 && rune <= 0x06f9) {
        return String.fromCharCode(rune - 0x06f0 + 0x30);
      }
      return rune == 0x066b || rune == 0x2c ? '.' : String.fromCharCode(rune);
    }).join();
    if (!RegExp(r'^\d+(?:\.\d{1,3})?$').hasMatch(text)) return null;
    final value = double.tryParse(text);
    return value != null && value.isFinite && value >= 0 && value <= 100000
        ? value
        : null;
  }

  bool get hoursChanged => !const DeepCollectionEquality().equals(
      workingHours?.map((h) => h.toJson()).toList(),
      saved?.workingHours?.map((h) => h.toJson()).toList());
  bool get dirty =>
      saved != null &&
      (enabled != saved!.sameDayEnabled ||
          cutoff != saved!.sameDayCutoffTime ||
          available != saved!.available ||
          hoursChanged ||
          minimumCharge != saved!.minimumCharge);
  bool get valid =>
      (!enabled || LaundrySettings.isValidCutoff(cutoff)) &&
      LaundryWorkingHour.validSchedule(workingHours) &&
      minimumCharge != null;
  List<LaundryWorkingHour> get effectiveHours =>
      workingHours ??
      List.generate(
          7,
          (day) => LaundryWorkingHour(
              dayOfWeek: day, startTime: '00:00', endTime: '24:00'));
}

/// Independent pages PATCH only their changed fields, preserving other settings.
class LaundrySettingsCubit extends Cubit<LaundrySettingsState> {
  final LaundryRepository repository;
  final Map<int, List<LaundryWorkingHour>> _closedDayBackup = {};
  LaundrySettingsCubit(this.repository) : super(const LaundrySettingsState());
  Future<void> load() async {
    if (state.loading || state.saving) return;
    emit(const LaundrySettingsState(loading: true));
    try {
      final value = await repository.getSettings();
      if (!isClosed) emit(_loaded(value));
    } catch (error) {
      if (!isClosed) {
        emit(LaundrySettingsState(error: requestActionErrorMessage(error)));
      }
    }
  }

  LaundrySettingsState _loaded(LaundrySettings value,
          {bool succeeded = false}) =>
      LaundrySettingsState(
          saved: value,
          enabled: value.sameDayEnabled,
          cutoff: value.sameDayCutoffTime,
          available: value.available,
          workingHours: value.workingHours,
          minimumChargeText: value.minimumCharge.toString(),
          saveSucceeded: succeeded);
  void change(
      {bool? enabled,
      String? cutoff,
      bool? available,
      List<LaundryWorkingHour>? workingHours,
      String? minimumChargeText}) {
    if (state.saved == null || state.saving || state.loading) return;
    emit(LaundrySettingsState(
        saved: state.saved,
        enabled: enabled ?? state.enabled,
        cutoff: cutoff ?? state.cutoff,
        available: available ?? state.available,
        workingHours: workingHours ?? state.workingHours,
        minimumChargeText: minimumChargeText ?? state.minimumChargeText));
  }

  void setDay(int day, List<LaundryWorkingHour> slots) => change(workingHours: [
        ...state.effectiveHours.where((slot) => slot.dayOfWeek != day),
        ...slots.map((slot) => slot.forDay(day))
      ]);
  void toggleDay(int day, bool enabled) {
    if (!enabled) {
      _closedDayBackup[day] =
          state.effectiveHours.where((slot) => slot.dayOfWeek == day).toList();
      setDay(day, []);
    } else {
      setDay(
          day,
          _closedDayBackup[day] ??
              [
                LaundryWorkingHour(
                    dayOfWeek: day, startTime: '09:00', endTime: '17:00')
              ]);
    }
  }

  void copyDay(int source, Iterable<int> targets) {
    final hours = state.effectiveHours;
    final slots = hours.where((slot) => slot.dayOfWeek == source).toList();
    change(workingHours: [
      ...hours.where((slot) => !targets.contains(slot.dayOfWeek)),
      for (final target in targets) ...slots.map((slot) => slot.forDay(target))
    ]);
  }

  LaundrySettingsState _draftState(LaundrySettingsState draft,
          {bool saving = false, String? error}) =>
      LaundrySettingsState(
          saved: draft.saved,
          enabled: draft.enabled,
          cutoff: draft.cutoff,
          available: draft.available,
          workingHours: draft.workingHours,
          minimumChargeText: draft.minimumChargeText,
          saving: saving,
          error: error);
  Future<void> save() async {
    if (state.saving || state.loading || !state.dirty || !state.valid) return;
    final draft = state;
    final sameDayChanged = draft.enabled != draft.saved!.sameDayEnabled ||
        draft.cutoff != draft.saved!.sameDayCutoffTime;
    emit(_draftState(draft, saving: true));
    try {
      final value = await repository.updateSettings(LaundrySettingsRequest(
          sameDayEnabled: sameDayChanged ? draft.enabled : null,
          sameDayCutoffTime: sameDayChanged ? draft.cutoff : null,
          available: draft.available != draft.saved!.available
              ? draft.available
              : null,
          workingHours: draft.hoursChanged ? draft.workingHours : null,
          minimumCharge: draft.minimumCharge != draft.saved!.minimumCharge
              ? draft.minimumCharge
              : null));
      if (!isClosed) emit(_loaded(value, succeeded: true));
    } catch (error) {
      if (!isClosed) {
        emit(_draftState(draft, error: requestActionErrorMessage(error)));
      }
    }
  }
}
