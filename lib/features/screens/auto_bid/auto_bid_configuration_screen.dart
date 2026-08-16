import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_categories.dart';
import 'package:cleaning_service_driver/data/models/auto_bid/auto_bid_config.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_item.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_event.dart';
import 'package:cleaning_service_driver/features/bloc/auto_bid/auto_bid_config_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AutoBidConfigurationScreen extends StatefulWidget {
  const AutoBidConfigurationScreen({super.key});

  @override
  State<AutoBidConfigurationScreen> createState() =>
      _AutoBidConfigurationScreenState();
}

class _AutoBidConfigurationScreenState
    extends State<AutoBidConfigurationScreen> {
  static const _tourScope = 'business_auto_bid_journey';
  static const double _priceStep = 5;
  final _configurationTourKey =
      GlobalKey(debugLabel: 'auto-bid-configuration-tour');
  late final BusinessShowcaseTourController _tour;
  String? _tourOwnerId;
  final _numberFormat = NumberFormat('0.##');
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, FocusNode> _priceFocusNodes = {};
  final Map<String, TextEditingController> _expectedControllers = {};
  final Map<String, FocusNode> _expectedFocusNodes = {};

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    SecureStorageService().getUser().then((user) {
      if (!mounted) return;
      setState(() => _tourOwnerId = businessShowcaseOwnerId(user));
    });
    context.read<AutoBidConfigBloc>().add(const LoadAutoBidConfigs());
  }

  Future<void> _refresh() async {
    context.read<AutoBidConfigBloc>().add(const LoadAutoBidConfigs());
  }

  double _normalize(double value) {
    if (value.isNaN || value.isInfinite) return 0;
    final clamped = value < 0 ? 0 : value;
    return double.parse(clamped.toStringAsFixed(3));
  }

  String _formatAmount(num value) => _numberFormat.format(value);
  String _formatExpectedTime(int? value) => value == null ? '' : '$value';

  double _parseAmount(String input) {
    final normalized = input.replaceAll(',', '.').trim();
    final value = double.tryParse(normalized) ?? 0;
    if (value.isNaN || value.isInfinite) return 0;
    return _normalize(value);
  }

  int? _parseExpectedTime(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll(',', '.');
    final parsedInt = int.tryParse(normalized);
    if (parsedInt != null) return parsedInt < 0 ? 0 : parsedInt;
    final parsedDouble = double.tryParse(normalized);
    if (parsedDouble == null || parsedDouble.isNaN || parsedDouble.isInfinite) {
      return null;
    }
    final rounded = parsedDouble.round();
    return rounded < 0 ? 0 : rounded;
  }

  TextEditingController _controllerFor(String key, double price) {
    final controller = _priceControllers.putIfAbsent(
      key,
      () => TextEditingController(text: _formatAmount(price)),
    );
    final focusNode = _priceFocusNodes[key];
    if (focusNode == null || !focusNode.hasFocus) {
      final formatted = _formatAmount(price);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
    return controller;
  }

  FocusNode _focusFor(String key) {
    return _priceFocusNodes.putIfAbsent(key, () => FocusNode());
  }

  TextEditingController _expectedControllerFor(String key, int? value) {
    final controller = _expectedControllers.putIfAbsent(
      key,
      () => TextEditingController(text: _formatExpectedTime(value)),
    );
    final focusNode = _expectedFocusNodes[key];
    if (focusNode == null || !focusNode.hasFocus) {
      final formatted = _formatExpectedTime(value);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
    return controller;
  }

  FocusNode _expectedFocusFor(String key) {
    return _expectedFocusNodes.putIfAbsent(key, () => FocusNode());
  }

  @override
  void dispose() {
    _tour.dispose();
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    for (final node in _priceFocusNodes.values) {
      node.dispose();
    }
    for (final controller in _expectedControllers.values) {
      controller.dispose();
    }
    for (final node in _expectedFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(fallbackRouteName: 'home'),
        title: Text(context.l10n.auto_bidding),
        actions: [
          BusinessShowcaseHelpButton(
            onPressed: () => _tour.start([_configurationTourKey]),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: BlocConsumer<AutoBidConfigBloc, AutoBidConfigState>(
        listener: (ctx, state) {
          if (state.error != null) {
            ctx.showErrorToast();
          }
        },
        builder: (ctx, state) {
          final showLoading = state.isLoadingDeep &&
              state.deepCategories.departmentTypes.isEmpty;
          if (showLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final ownerId = _tourOwnerId;
          if (ownerId != null) {
            _tour.scheduleStartOnce(
              ownerId: ownerId,
              journeyId: 'auto_bid_configuration',
              keys: [_configurationTourKey],
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                BusinessShowcaseStep(
                  showcaseKey: _configurationTourKey,
                  scope: _tourScope,
                  title: context.l10n.auto_bidding,
                  description: context.l10n.business_setup_tour_auto_bid,
                  index: 0,
                  itemCount: 1,
                  child: _deepCleaningSection(state),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _deepCleaningSection(AutoBidConfigState state) {
    final categories = state.deepCategories.departmentTypes
        .where((dept) => !_isOtherType(dept))
        .toList();

    final groups = <Widget>[];

    for (final dept in categories) {
      final card = _departmentTypeCard(dept, state.deepCleaningPricing);
      if (card != null) {
        groups.add(card);
      }
    }

    return _serviceSection(
      title: context.l10n.deepCleaning,
      isEnabled: state.deepEnabled,
      isLoading: state.isLoadingDeep,
      isSaving: state.isSavingDeep,
      onToggle: (value) {
        context.read<AutoBidConfigBloc>().add(
              ToggleAutoBidEnabled(
                serviceType: AutoBidConfigBloc.deepCleaning,
                isEnabled: value,
              ),
            );
      },
      onSave: () {
        context.read<AutoBidConfigBloc>().add(
              const SaveAutoBidConfig(
                serviceType: AutoBidConfigBloc.deepCleaning,
              ),
            );
      },
      children: groups,
      emptyLabel: context.l10n.no_pricing_options,
      hasData: groups.isNotEmpty,
    );
  }

  Widget _serviceSection({
    required String title,
    required bool isEnabled,
    required bool isLoading,
    required bool isSaving,
    required ValueChanged<bool> onToggle,
    required VoidCallback onSave,
    required List<Widget> children,
    required String emptyLabel,
    required bool hasData,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SwitchListTile(
              value: isEnabled,
              onChanged: onToggle,
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.auto_bidding_enabled),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(emptyLabel),
              )
            else
              ...children,
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(context.l10n.save_auto_bidding),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _departmentTypeCard(
    AutoBidDepartmentType type,
    AutoBidDeepCleaningPricing pricing,
  ) {
    final title = _localizedTitle(type.titleEn, type.titleAr, type.id);
    final isApartment = _isApartmentType(type);
    final isHouse = _isHouseType(type);
    final isCommercialOrOffice = _isCommercialOrOfficeType(type);

    final groups = <Widget>[];

    if (isApartment) {
      groups.add(_subGroupItems(
        context.l10n.request_card_bedroom,
        type.options.bedrooms,
        _priceForOption(pricing.bedrooms),
        _expectedTimeForOption(pricing.bedrooms),
        (id, price) => _updateDeepPrice('bedrooms', id, price),
        (id, expectedTime) =>
            _updateDeepExpectedTime('bedrooms', id, expectedTime),
        fieldPrefix: 'deep:bedrooms',
      ));
    } else if (isHouse) {
      groups.add(_subGroupItems(
        context.l10n.number_of_floors,
        type.options.numberOfFloors,
        _priceForOption(pricing.numberOfFloors),
        _expectedTimeForOption(pricing.numberOfFloors),
        (id, price) => _updateDeepPrice('numberOfFloors', id, price),
        (id, expectedTime) =>
            _updateDeepExpectedTime('numberOfFloors', id, expectedTime),
        fieldPrefix: 'deep:numberOfFloors',
      ));
    } else if (isCommercialOrOffice) {
      groups.add(_subGroupItems(
        context.l10n.size_options,
        type.options.sizeOptions,
        _priceForOption(pricing.sizeOptions),
        _expectedTimeForOption(pricing.sizeOptions),
        (id, price) => _updateDeepPrice('sizeOptions', id, price),
        (id, expectedTime) =>
            _updateDeepExpectedTime('sizeOptions', id, expectedTime),
        fieldPrefix: 'deep:sizeOptions',
      ));
    }

    groups.removeWhere((widget) => widget is SizedBox);

    if (groups.isEmpty) return null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent)),
        title: Text(title),
        children: groups,
      ),
    );
  }

  Widget _upholsteryTypeCard(
    AutoBidUpholsteryTypeCategory type,
    AutoBidUpholsteryPricing pricing,
  ) {
    final id = type.id ?? '-';
    final title = _localizedTitle(type.titleEn, type.titleAr, id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title),
        children: [
          _subGroupItems(
            context.l10n.size,
            type.sizes,
            _upholsteryPriceForOption(pricing, id, 'sizes'),
            _upholsteryExpectedTimeForOption(pricing, id, 'sizes'),
            (optionId, price) =>
                _updateUpholsteryPrice(id, 'sizes', optionId, price),
            (optionId, expectedTime) => _updateUpholsteryExpectedTime(
                id, 'sizes', optionId, expectedTime),
            fieldPrefix: 'uph:$id:sizes',
          ),
          _subGroupItems(
            context.l10n.material,
            type.materials,
            _upholsteryPriceForOption(pricing, id, 'materials'),
            _upholsteryExpectedTimeForOption(pricing, id, 'materials'),
            (optionId, price) =>
                _updateUpholsteryPrice(id, 'materials', optionId, price),
            (optionId, expectedTime) => _updateUpholsteryExpectedTime(
                id, 'materials', optionId, expectedTime),
            fieldPrefix: 'uph:$id:materials',
          ),
          _subGroupItems(
            context.l10n.condition,
            type.conditions,
            _upholsteryPriceForOption(pricing, id, 'conditions'),
            _upholsteryExpectedTimeForOption(pricing, id, 'conditions'),
            (optionId, price) =>
                _updateUpholsteryPrice(id, 'conditions', optionId, price),
            (optionId, expectedTime) => _updateUpholsteryExpectedTime(
                id, 'conditions', optionId, expectedTime),
            fieldPrefix: 'uph:$id:conditions',
          ),
        ],
      ),
    );
  }

  Widget _subGroupItems(
    String title,
    List<CleaningItem> options,
    double Function(String? optionId) priceFor,
    int? Function(String? optionId) expectedTimeFor,
    void Function(String optionId, double price) onUpdate,
    void Function(String optionId, int? expectedTimeInDays)
        onUpdateExpectedTime, {
    required String fieldPrefix,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...options.map((option) {
            final id = option.id;
            final price = priceFor(id);
            final expectedTime = expectedTimeFor(id);
            final fieldKey = '$fieldPrefix:$id';
            final expectedFieldKey = '$fieldPrefix:$id:days';
            return _priceRow(
              _cleaningItemTitle(option, id),
              price,
              expectedTimeInDays: expectedTime,
              fieldKey: fieldKey,
              expectedFieldKey: expectedFieldKey,
              onManualChange:
                  id == null ? null : (value) => onUpdate(id, value),
              onExpectedChange: id == null
                  ? null
                  : (value) => onUpdateExpectedTime(id, value),
              onDecrease: id == null
                  ? null
                  : () => onUpdate(id, _normalize(price - _priceStep)),
              onIncrease: id == null
                  ? null
                  : () => onUpdate(id, _normalize(price + _priceStep)),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _priceRow(
    String title,
    double price, {
    required String fieldKey,
    required String expectedFieldKey,
    required int? expectedTimeInDays,
    ValueChanged<double>? onManualChange,
    ValueChanged<int?>? onExpectedChange,
    VoidCallback? onDecrease,
    VoidCallback? onIncrease,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${context.l10n.number} : $title",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final labelWidth = constraints.maxWidth < 180 ? 40.0 : 60.0;
              final labelStyle = Theme.of(context).textTheme.bodySmall;

              Widget labeledRow(String label, Widget field) {
                return Row(
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Text(label,
                          style: labelStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: field),
                  ],
                );
              }

              Widget iconButton(IconData icon, VoidCallback? onTap) {
                return IconButton(
                  icon: Icon(icon, size: 20),
                  onPressed: onTap,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                );
              }

              final priceField = Row(
                children: [
                  iconButton(Icons.remove_circle_outline, onDecrease),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _controllerFor(fieldKey, price),
                      focusNode: _focusFor(fieldKey),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: onManualChange == null
                          ? null
                          : (value) => onManualChange(_parseAmount(value)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  iconButton(Icons.add_circle_outline, onIncrease),
                ],
              );

              final expectedField = TextField(
                controller: _expectedControllerFor(
                    expectedFieldKey, expectedTimeInDays),
                focusNode: _expectedFocusFor(expectedFieldKey),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: context.l10n.expected_time_days,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onExpectedChange == null
                    ? null
                    : (value) => onExpectedChange(_parseExpectedTime(value)),
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  labeledRow(context.l10n.request_price, priceField),
                  const SizedBox(height: 8),
                  labeledRow(context.l10n.expected_time, expectedField),
                ],
              );
            },
          ),
          SizedBox(
            height: 8,
          ),
          Divider(color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }

  String _localizedTitle(String? en, String? ar, String? fallback) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) {
      return ar ?? en ?? fallback ?? '-';
    }
    return en ?? ar ?? fallback ?? '-';
  }

  String _cleaningItemTitle(CleaningItem item, String? fallback) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) {
      return item.titleAr ?? item.titleEn ?? item.title ?? fallback ?? '-';
    }
    return item.titleEn ?? item.titleAr ?? item.title ?? fallback ?? '-';
  }

  Map<String, double> _priceMap(List<AutoBidOption> items) {
    final map = <String, double>{};
    for (final item in items) {
      final id = item.categoryOptionId;
      if (id == null) continue;
      map[id] = item.price ?? 0;
    }
    return map;
  }

  double Function(String? optionId) _priceForOption(List<AutoBidOption> items) {
    final map = _priceMap(items);
    return (String? optionId) {
      if (optionId == null) return 0;
      return map[optionId] ?? 0;
    };
  }

  Map<String, int?> _expectedTimeMap(List<AutoBidOption> items) {
    final map = <String, int?>{};
    for (final item in items) {
      final id = item.categoryOptionId;
      if (id == null) continue;
      map[id] = item.expectedTimeInDays;
    }
    return map;
  }

  int? Function(String? optionId) _expectedTimeForOption(
    List<AutoBidOption> items,
  ) {
    final map = _expectedTimeMap(items);
    return (String? optionId) {
      if (optionId == null) return null;
      return map[optionId];
    };
  }

  double Function(String? optionId) _upholsteryPriceForOption(
    AutoBidUpholsteryPricing pricing,
    String typeId,
    String section,
  ) {
    return (String? optionId) {
      if (optionId == null) return 0;
      AutoBidTypeOverride? override;
      for (final item in pricing.typeOverrides) {
        if (item.categoryTypeId == typeId) {
          override = item;
          break;
        }
      }
      if (override == null) return 0;
      List<AutoBidOption> list;
      if (section == 'sizes') {
        list = override.sizes;
      } else if (section == 'materials') {
        list = override.materials;
      } else {
        list = override.conditions;
      }
      for (final item in list) {
        if (item.categoryOptionId == optionId) return item.price ?? 0;
      }
      return 0;
    };
  }

  int? Function(String? optionId) _upholsteryExpectedTimeForOption(
    AutoBidUpholsteryPricing pricing,
    String typeId,
    String section,
  ) {
    return (String? optionId) {
      if (optionId == null) return null;
      AutoBidTypeOverride? override;
      for (final item in pricing.typeOverrides) {
        if (item.categoryTypeId == typeId) {
          override = item;
          break;
        }
      }
      if (override == null) return null;
      List<AutoBidOption> list;
      if (section == 'sizes') {
        list = override.sizes;
      } else if (section == 'materials') {
        list = override.materials;
      } else {
        list = override.conditions;
      }
      for (final item in list) {
        if (item.categoryOptionId == optionId) return item.expectedTimeInDays;
      }
      return null;
    };
  }

  bool _isOtherType(AutoBidDepartmentType type) {
    final title = '${type.titleEn ?? ''} ${type.titleAr ?? ''}'.toLowerCase();
    return title.contains('other') ||
        title.contains('أخرى') ||
        title.contains('اخرى') ||
        title.contains('آخر') ||
        title.contains('اخري');
  }

  bool _isApartmentType(AutoBidDepartmentType type) {
    final title = '${type.titleEn ?? ''} ${type.titleAr ?? ''}'.toLowerCase();
    return title.contains('apartment') || title.contains('شقة');
  }

  bool _isHouseType(AutoBidDepartmentType type) {
    final title = '${type.titleEn ?? ''} ${type.titleAr ?? ''}'.toLowerCase();
    return title.contains('house') || title.contains('منزل');
  }

  bool _isCommercialOrOfficeType(AutoBidDepartmentType type) {
    final title = '${type.titleEn ?? ''} ${type.titleAr ?? ''}'.toLowerCase();
    return title.contains('office') ||
        title.contains('commercial') ||
        title.contains('مكتب') ||
        title.contains('تجاري');
  }

  void _updateDeepPrice(String section, String optionId, double price) {
    context.read<AutoBidConfigBloc>().add(
          UpdateDeepCleaningPrice(
            section: section,
            optionId: optionId,
            price: _normalize(price),
          ),
        );
  }

  void _updateDeepExpectedTime(
    String section,
    String optionId,
    int? expectedTimeInDays,
  ) {
    context.read<AutoBidConfigBloc>().add(
          UpdateDeepCleaningExpectedTime(
            section: section,
            optionId: optionId,
            expectedTimeInDays: expectedTimeInDays,
          ),
        );
  }

  void _updateUpholsteryPrice(
    String categoryTypeId,
    String section,
    String optionId,
    double price,
  ) {
    context.read<AutoBidConfigBloc>().add(
          UpdateUpholsteryPrice(
            categoryTypeId: categoryTypeId,
            section: section,
            optionId: optionId,
            price: _normalize(price),
          ),
        );
  }

  void _updateUpholsteryExpectedTime(
    String categoryTypeId,
    String section,
    String optionId,
    int? expectedTimeInDays,
  ) {
    context.read<AutoBidConfigBloc>().add(
          UpdateUpholsteryExpectedTime(
            categoryTypeId: categoryTypeId,
            section: section,
            optionId: optionId,
            expectedTimeInDays: expectedTimeInDays,
          ),
        );
  }
}
