import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LaundryMinimumChargeCard extends StatelessWidget {
  final LaundrySettingsCubit cubit;
  final bool canEdit;
  const LaundryMinimumChargeCard(
      {super.key, required this.cubit, required this.canEdit});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LaundrySettingsCubit, LaundrySettingsState>(
        bloc: cubit,
        listener: (context, state) {
          if (state.saveSucceeded) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.laundry_settings_saved)));
          }
        },
        builder: (context, state) => Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.l10n.laundry_minimum_charge,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(context.l10n.laundry_minimum_charge_help),
                      const SizedBox(height: 12),
                      if (state.loading || state.saving)
                        const Center(
                            child: AppIconSpinner(
                                assetPath: 'assets/images/ic_yourcare.png'))
                      else if (state.saved == null) ...[
                        Text(context.l10n.laundry_settings_load_error),
                        TextButton(
                            onPressed: cubit.load,
                            child: Text(context.l10n.retry)),
                      ] else ...[
                        TextFormField(
                            key: ValueKey(
                                'laundry-minimum-charge-${state.saved!.minimumCharge}'),
                            initialValue: state.minimumChargeText,
                            enabled: canEdit,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                                labelText: context.l10n.laundry_minimum_charge,
                                suffixText: context.l10n.kwd,
                                errorMaxLines: 3,
                                errorText: state.minimumCharge == null
                                    ? context
                                        .l10n.laundry_minimum_charge_invalid
                                    : null),
                            onChanged: (value) =>
                                cubit.change(minimumChargeText: value)),
                        if (state.error != null)
                          Text(context.l10n.laundry_same_day_save_error,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        if (canEdit) ...[
                          const SizedBox(height: 8),
                          FilledButton(
                              key: const ValueKey('laundry-minimum-save'),
                              onPressed: state.valid && state.dirty
                                  ? cubit.save
                                  : null,
                              child: Text(context.l10n.save)),
                        ],
                      ],
                    ]))),
      );
}
