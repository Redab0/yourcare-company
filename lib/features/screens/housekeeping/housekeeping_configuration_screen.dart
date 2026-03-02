import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HousekeepingConfigurationScreen extends StatefulWidget {
  const HousekeepingConfigurationScreen({super.key});

  @override
  State<HousekeepingConfigurationScreen> createState() =>
      _HousekeepingConfigurationScreenState();
}

class _HousekeepingConfigurationScreenState
    extends State<HousekeepingConfigurationScreen> {
  static const double _feeStep = 0.5;
  final _basePriceController = TextEditingController();
  final _basePriceFocus = FocusNode();
  final _numberFormat = NumberFormat('0.###');

  @override
  void initState() {
    super.initState();
    context.read<HousekeepingPricingBloc>().add(const LoadHousekeepingConfig());
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    _basePriceFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<HousekeepingPricingBloc>().add(const LoadHousekeepingConfig());
  }

  double _parseAmount(String input) {
    final normalized = input.replaceAll(',', '.').trim();
    final value = double.tryParse(normalized) ?? 0;
    if (value.isNaN || value.isInfinite) return 0;
    final clamped = value < 0 ? 0 : value;
    return double.parse(clamped.toStringAsFixed(3));
  }

  String _formatAmount(num value) => _numberFormat.format(value);

  void _syncBasePriceText(double value) {
    final formatted = _formatAmount(value);
    if (_basePriceFocus.hasFocus) {
      return;
    }
    if (_basePriceController.text != formatted) {
      _basePriceController.text = formatted;
    }
  }

  void _updateAreaFee(String areaId, double next) {
    final normalized = _parseAmount(next.toString());
    context
        .read<HousekeepingPricingBloc>()
        .add(UpdateAreaFee(areaId: areaId, fee: normalized));
  }

  String _governorateTitle(BuildContext context, Governorate? title) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? (title?.ar ?? title?.en ?? '-')
        : (title?.en ?? title?.ar ?? '-');
  }

  String _areaTitle(BuildContext context, AreaModel area) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? (area.ar ?? area.en ?? area.name ?? '-')
        : (area.en ?? area.ar ?? area.name ?? '-');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.housekeeping_configuration),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: BlocConsumer<HousekeepingPricingBloc, HousekeepingPricingState>(
        listener: (ctx, state) {
          if (state.error != null) {
            ctx.showErrorToast();
          }
        },
        builder: (ctx, state) {
          if (state.isLoading && state.areas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          _syncBasePriceText(state.basePrice);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _pricingSection(state),
                const SizedBox(height: 24),
                _areaFeesSection(state),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pricingSection(HousekeepingPricingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.housekeeping_pricing,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _basePriceController,
                  focusNode: _basePriceFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.l10n.base_price_per_cleaner_per_hour,
                    suffixText: 'KWD',
                  ),
                  onChanged: (value) {
                    final parsed = _parseAmount(value);
                    context
                        .read<HousekeepingPricingBloc>()
                        .add(UpdateBasePrice(parsed));
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: state.isActive,
                  onChanged: (value) {
                    context
                        .read<HousekeepingPricingBloc>()
                        .add(ToggleHousekeepingActive(value));
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.housekeeping_active),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () {
                            final parsed =
                                _parseAmount(_basePriceController.text);
                            context
                                .read<HousekeepingPricingBloc>()
                                .add(UpdateBasePrice(parsed));
                            context
                                .read<HousekeepingPricingBloc>()
                                .add(const SaveHousekeepingPricing());
                          },
                    icon: state.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(context.l10n.save_pricing),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _areaFeesSection(HousekeepingPricingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.housekeeping_area_fees,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (state.areas.isEmpty)
          Text(context.l10n.no_areas_available)
        else
          ...state.areas
              .where((group) => (group.areas ?? const []).isNotEmpty)
              .map((group) => _areaGroupCard(group, state))
              .toList(),
      ],
    );
  }

  Widget _areaGroupCard(AreaResponse group, HousekeepingPricingState state) {
    final areas = group.areas ?? const <AreaModel>[];
    if (areas.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(_governorateTitle(context, group.title)),
        children: areas.map((area) => _areaFeeRow(area, state)).toList(),
      ),
    );
  }

  Widget _areaFeeRow(AreaModel area, HousekeepingPricingState state) {
    final id = area.id;
    final fee = id == null ? 0 : (state.areaFees[id] ?? 0);
    final canDecrease = id != null && fee > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _areaTitle(context, area),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed:
                canDecrease ? () => _updateAreaFee(id!, fee - _feeStep) : null,
          ),
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatAmount(fee),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed:
                id == null ? null : () => _updateAreaFee(id, fee + _feeStep),
          ),
        ],
      ),
    );
  }
}
