import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_settings.dart';
import 'package:cleaning_service_driver/data/models/staff/user_role.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

bool canAccessLaundrySettings(User? user, {bool edit = false}) {
  // Owners bypass profile permissions in the backend permissions guard.
  if (user?.role == UserRole.businessOwner.value) return true;
  if (user?.role != UserRole.manager.value) return false;
  return user?.permissions?.hasPermission(edit
          ? Permission.companyProfileUpdate
          : Permission.companyProfileRead) ??
      false;
}

class LaundrySameDaySettingsCard extends StatelessWidget {
  final LaundrySettingsCubit cubit;
  final bool canEdit;
  final bool showSave;
  const LaundrySameDaySettingsCard(
      {super.key,
      required this.cubit,
      required this.canEdit,
      this.showSave = true});

  Widget _cutoffField(BuildContext context, LaundrySettingsState state) {
    final values = <String>[
      for (var minute = 0; minute < 1440; minute += 15)
        '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}',
    ];
    if (LaundrySettings.isValidCutoff(state.cutoff) &&
        !values.contains(state.cutoff)) {
      values.add(state.cutoff!);
      values.sort();
    }

    String displayTime(String value) {
      final parts = value.split(':').map(int.parse).toList();
      return MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: parts[0], minute: parts[1]),
          alwaysUse24HourFormat: false);
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('laundry-same-day-cutoff-${state.cutoff}'),
      initialValue:
          LaundrySettings.isValidCutoff(state.cutoff) ? state.cutoff : null,
      isExpanded: true,
      decoration:
          InputDecoration(labelText: context.l10n.laundry_same_day_cutoff),
      items: [
        for (final value in values)
          DropdownMenuItem(value: value, child: Text(displayTime(value))),
      ],
      onChanged: !canEdit || state.saving
          ? null
          : (value) {
              if (value != null) cubit.change(cutoff: value);
            },
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LaundrySettingsCubit, LaundrySettingsState>(
        bloc: cubit,
        listener: (context, state) {
          if (showSave && state.saveSucceeded) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.laundry_same_day_saved)));
          }
        },
        builder: (context, state) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.l10n.laundry_same_day,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(context.l10n.laundry_same_day_help),
                  const SizedBox(height: 8),
                  if (state.loading)
                    const Center(
                        child: AppIconSpinner(
                            assetPath: 'assets/images/ic_yourcare.png'))
                  else if (state.saved == null) ...[
                    Text(context.l10n.laundry_same_day_load_error),
                    Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                            onPressed: cubit.load,
                            child: Text(context.l10n.retry))),
                  ] else ...[
                    SwitchListTile.adaptive(
                      key: const ValueKey('laundry-same-day-toggle'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.laundry_same_day_enable),
                      value: state.enabled,
                      onChanged: canEdit && !state.saving
                          ? (value) => cubit.change(enabled: value)
                          : null,
                    ),
                    _cutoffField(context, state),
                    Text(context.l10n.laundry_same_day_kuwait_time),
                    if (state.enabled &&
                        !LaundrySettings.isValidCutoff(state.cutoff)) ...[
                      const SizedBox(height: 8),
                      Text(context.l10n.laundry_same_day_cutoff_required,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    if (state.error != null) ...[
                      const SizedBox(height: 8),
                      Text(context.l10n.laundry_same_day_save_error,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    if (canEdit && showSave) ...[
                      const SizedBox(height: 8),
                      if (state.saving)
                        const Center(
                            child: AppIconSpinner(
                                assetPath: 'assets/images/ic_yourcare.png'))
                      else
                        FilledButton(
                          key: const ValueKey('laundry-same-day-save'),
                          onPressed:
                              state.dirty && state.valid ? cubit.save : null,
                          child: Text(context.l10n.save),
                        ),
                    ],
                  ],
                ]),
          ),
        ),
      );
}
