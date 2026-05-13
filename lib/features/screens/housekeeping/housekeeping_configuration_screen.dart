import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_service_frequency_option.dart';
import 'package:cleaning_service_driver/data/models/housekeeping/housekeeping_pricing.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/housekeeping/housekeeping_pricing_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final _cleaningProductsController = TextEditingController();
  final _cleaningProductsFocus = FocusNode();
  final Map<String, TextEditingController> _optionPriceControllers = {};
  final Map<String, FocusNode> _optionPriceFocusNodes = {};
  final Map<String, TextEditingController> _frequencyDiscountControllers = {};
  final Map<String, FocusNode> _frequencyDiscountFocusNodes = {};
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
    _cleaningProductsController.dispose();
    _cleaningProductsFocus.dispose();
    for (final controller in _optionPriceControllers.values) {
      controller.dispose();
    }
    for (final focus in _optionPriceFocusNodes.values) {
      focus.dispose();
    }
    for (final controller in _frequencyDiscountControllers.values) {
      controller.dispose();
    }
    for (final focus in _frequencyDiscountFocusNodes.values) {
      focus.dispose();
    }
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

  void _syncCleaningProductsText(double value) {
    final formatted = _formatAmount(value);
    if (_cleaningProductsFocus.hasFocus) return;
    if (_cleaningProductsController.text != formatted) {
      _cleaningProductsController.text = formatted;
    }
  }

  void _syncMultipleOptionTexts(HousekeepingPricingState state) {
    for (final option in state.multiplePricingOptions) {
      final id = option.optionId;
      if (id.isEmpty) continue;
      final controller = _optionPriceControllers.putIfAbsent(
        id,
        TextEditingController.new,
      );
      final focusNode = _optionPriceFocusNodes.putIfAbsent(id, FocusNode.new);
      if (focusNode.hasFocus) continue;
      final formatted = _formatAmount(option.price);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
  }

  void _syncServiceFrequencyTexts(HousekeepingPricingState state) {
    for (final option in state.serviceFrequencyOptions) {
      final id = option.id;
      if (id.isEmpty) continue;
      final controller = _frequencyDiscountControllers.putIfAbsent(
        id,
        TextEditingController.new,
      );
      final focusNode = _frequencyDiscountFocusNodes.putIfAbsent(
        id,
        FocusNode.new,
      );
      if (focusNode.hasFocus) continue;
      final value = state.serviceFrequencyDiscounts[id];
      final formatted = value == null ? '' : _formatAmount(value);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
  }

  void _updateAreaFee(String areaId, double next) {
    final normalized = _parseAmount(next.toString());
    context
        .read<HousekeepingPricingBloc>()
        .add(UpdateAreaFee(areaId: areaId, fee: normalized));
  }

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  String _governorateTitle(BuildContext context, Governorate? title) {
    final isAr = _isArabic(context);
    return isAr
        ? (title?.ar ?? title?.en ?? '-')
        : (title?.en ?? title?.ar ?? '-');
  }

  String _areaTitle(BuildContext context, AreaModel area) {
    final isAr = _isArabic(context);
    return isAr
        ? (area.ar ?? area.en ?? area.name ?? '-')
        : (area.en ?? area.ar ?? area.name ?? '-');
  }

  String _optionHoursLabel(HousekeepingPricingOption option) {
    final useAr = _isArabic(context);
    final raw = (useAr ? option.titleAr : option.titleEn) ??
        option.titleEn ??
        option.titleAr ??
        '';
    final parsed = int.tryParse(raw.trim());
    if (parsed == null) return raw;
    return parsed == 1
        ? '$parsed ${context.l10n.hour}'
        : '$parsed ${context.l10n.hours}';
  }

  String _serviceFrequencyLabel(HousekeepingServiceFrequencyOption option) {
    final useAr = _isArabic(context);
    final raw = (useAr ? option.titleAr : option.titleEn) ??
        option.titleEn ??
        option.titleAr ??
        '';
    final title = raw.trim();
    if (title.isNotEmpty) {
      return '$title ${context.l10n.frequency_visits_per_week}';
    }
    final visits = option.numberOfWeeklyVisits;
    if (visits == null) return '-';
    return '$visits ${context.l10n.frequency_visits_per_week}';
  }

  void _savePricing(HousekeepingPricingState state) {
    final base = _parseAmount(_basePriceController.text);
    final cleaningProducts = _parseAmount(_cleaningProductsController.text);

    if (state.singlePricingModelActive && base <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.price_must_be_greater_than_zero)),
      );
      return;
    }

    if (state.multiplePricingModelActive &&
        state.multiplePricingOptions.any((o) => o.price <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.price_must_be_greater_than_zero)),
      );
      return;
    }

    final frequencyIds = state.serviceFrequencyOptions
        .map((option) => option.id)
        .where((id) => id.isNotEmpty)
        .toList();
    final hasAllFrequencyDiscounts = frequencyIds.every((id) {
      final value = state.serviceFrequencyDiscounts[id];
      return value != null && value >= 0;
    });
    if (!hasAllFrequencyDiscounts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enter_all_frequency_discounts)),
      );
      return;
    }

    context.read<HousekeepingPricingBloc>().add(UpdateBasePrice(base));
    context
        .read<HousekeepingPricingBloc>()
        .add(UpdateCleaningProductsPrice(cleaningProducts));
    context
        .read<HousekeepingPricingBloc>()
        .add(const SaveHousekeepingPricing());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('housekeeping-main-screen'),
        ),
        title: Text(context.l10n.housekeeping_configuration),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: NotificationListener<UserScrollNotification>(
          onNotification: (n) {
            if (n.direction != ScrollDirection.idle) {
              FocusScope.of(context).unfocus();
            }
            return false;
          },
          child:
              BlocConsumer<HousekeepingPricingBloc, HousekeepingPricingState>(
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
              _syncCleaningProductsText(state.cleaningProductsPrice);
              _syncMultipleOptionTexts(state);
              _syncServiceFrequencyTexts(state);
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
        ),
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
                Text(
                  context.l10n.single_pricing_model,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _basePriceController,
                  focusNode: _basePriceFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.l10n.base_price_per_cleaner_per_hour,
                    suffixText: context.l10n.kwd,
                  ),
                  onChanged: (value) {
                    final parsed = _parseAmount(value);
                    if (parsed > 0) {
                      context
                          .read<HousekeepingPricingBloc>()
                          .add(UpdateBasePrice(parsed));
                    }
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: state.singlePricingModelActive,
                  onChanged: (value) {
                    context
                        .read<HousekeepingPricingBloc>()
                        .add(ToggleSinglePricingModelActive(value));
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.housekeeping_active),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  context.l10n.multiple_pricing_model,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.hours,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...state.multiplePricingOptions.map((option) {
                  if (option.optionId.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final controller = _optionPriceControllers[option.optionId]!;
                  final focusNode = _optionPriceFocusNodes[option.optionId]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            _optionHoursLabel(option),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              suffixText: context.l10n.kwd,
                            ),
                            onChanged: (value) {
                              final parsed = _parseAmount(value);
                              if (parsed > 0) {
                                context.read<HousekeepingPricingBloc>().add(
                                      UpdateMultipleOptionPrice(
                                        optionId: option.optionId,
                                        price: parsed,
                                      ),
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Text(
                  context.l10n.service_frequency,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...state.serviceFrequencyOptions.map((option) {
                  if (option.id.isEmpty) return const SizedBox.shrink();
                  final controller = _frequencyDiscountControllers[option.id]!;
                  final focusNode = _frequencyDiscountFocusNodes[option.id]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 160,
                          child: Text(
                            _serviceFrequencyLabel(option),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: context.l10n.discount_percentage,
                              suffixText: '%',
                            ),
                            onChanged: (value) {
                              final parsed = _parseAmount(value);
                              context.read<HousekeepingPricingBloc>().add(
                                    UpdateServiceFrequencyDiscount(
                                      optionId: option.id,
                                      discountPercentage: parsed,
                                    ),
                                  );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: state.multiplePricingModelActive,
                  onChanged: (value) {
                    context
                        .read<HousekeepingPricingBloc>()
                        .add(ToggleMultiplePricingModelActive(value));
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.housekeeping_active),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cleaningProductsController,
                  focusNode: _cleaningProductsFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.l10n.cleaning_products_price,
                    suffixText: context.l10n.kwd,
                  ),
                  onChanged: (value) {
                    context.read<HousekeepingPricingBloc>().add(
                          UpdateCleaningProductsPrice(_parseAmount(value)),
                        );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        state.isSaving ? null : () => _savePricing(state),
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
              .map((group) => _areaGroupCard(group, state)),
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
                canDecrease ? () => _updateAreaFee(id, fee - _feeStep) : null,
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
