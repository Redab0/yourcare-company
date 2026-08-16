import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/permissions_helper.dart';
import 'package:cleaning_service_driver/data/models/upholstery/upholstery_pricing_models.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_event.dart';
import 'package:cleaning_service_driver/features/bloc/upholstery/upholstery_pricing_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpholsteryPricingScreen extends StatefulWidget {
  const UpholsteryPricingScreen({super.key});

  @override
  State<UpholsteryPricingScreen> createState() =>
      _UpholsteryPricingScreenState();
}

class _UpholsteryPricingScreenState extends State<UpholsteryPricingScreen> {
  static const _tourScope = 'business_upholstery_configuration_journey';
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _expandedTypeIds = {};
  final _hintTourKey = GlobalKey(debugLabel: 'upholstery-hint-tour');
  final _typeTourKey = GlobalKey(debugLabel: 'upholstery-type-tour');
  final _saveTourKey = GlobalKey(debugLabel: 'upholstery-save-tour');
  late final BusinessShowcaseTourController _tour;
  String? _tourOwnerId;
  bool _canManageAvailability = false;

  List<GlobalKey> get _tourKeys => [
        _hintTourKey,
        _typeTourKey,
        _saveTourKey,
      ];

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    SecureStorageService().getUser().then((user) {
      if (!mounted) return;
      final permissions = user?.permissions ?? const [];
      setState(() {
        _tourOwnerId = businessShowcaseOwnerId(user);
        _canManageAvailability = permissions.hasAnyPermission([
          Permission.cleanerAvailabilityRead,
          Permission.cleanerAvailabilityCreate,
          Permission.cleanerAvailabilityUpdate,
          Permission.cleanerAvailabilityDelete,
        ]);
      });
    });
    context
        .read<UpholsteryPricingBloc>()
        .add(const LoadUpholsteryPricingConfig());
  }

  @override
  void dispose() {
    _tour.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(UpholsteryPricingState state) {
    final activeKeys = <String>{};
    for (final group in state.pricing) {
      for (final package in group.packages) {
        _syncController(
          activeKeys,
          _key(group.upholsteryTypeId, package.rowKey, 'titleEn'),
          package.titleEn ?? '',
        );
        _syncController(
          activeKeys,
          _key(group.upholsteryTypeId, package.rowKey, 'titleAr'),
          package.titleAr ?? '',
        );
        _syncController(
          activeKeys,
          _key(group.upholsteryTypeId, package.rowKey, 'descriptionEn'),
          package.descriptionEn ?? '',
        );
        _syncController(
          activeKeys,
          _key(group.upholsteryTypeId, package.rowKey, 'descriptionAr'),
          package.descriptionAr ?? '',
        );
        _syncController(
          activeKeys,
          _key(group.upholsteryTypeId, package.rowKey, 'price'),
          package.price == 0 ? '' : _formatNumber(package.price),
        );
        _syncController(
          activeKeys,
          _key(group.upholsteryTypeId, package.rowKey, 'discount'),
          package.discountPercentage == 0
              ? ''
              : _formatNumber(package.discountPercentage),
        );
      }
    }

    final staleKeys =
        _controllers.keys.where((key) => !activeKeys.contains(key)).toList();
    for (final key in staleKeys) {
      _controllers.remove(key)?.dispose();
    }
  }

  void _syncController(
    Set<String> activeKeys,
    String key,
    String value,
  ) {
    activeKeys.add(key);
    _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: value),
    );
  }

  String _key(String typeId, String packageKey, String field) =>
      '$typeId:$packageKey:$field';

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _toggleTypeExpansion(String typeId) {
    FocusScope.of(context).unfocus();
    setState(() {
      if (!_expandedTypeIds.add(typeId)) {
        _expandedTypeIds.remove(typeId);
      }
    });
  }

  UpholsteryType? _typeFor(UpholsteryPricingState state, String id) {
    for (final type in state.types) {
      if (type.id == id) return type;
    }
    return null;
  }

  UpholsterySize? _sizeFor(UpholsteryType? type, String? id) {
    if (type == null || id == null) return null;
    for (final size in type.sizes) {
      if (size.id == id) return size;
    }
    return null;
  }

  bool _cannotSave(UpholsteryPricingState state) {
    for (final group in state.pricing) {
      if (!group.isEnabled) continue;
      if (group.packages.isEmpty) return true;
      for (final package in group.packages) {
        if (package.price <= 0) return true;
        if (package.discountPercentage < 0 ||
            package.discountPercentage > 100) {
          return true;
        }
        if ((package.titleEn?.trim().isEmpty ?? true) ||
            (package.titleAr?.trim().isEmpty ?? true)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(fallbackRouteName: 'home'),
        title: Text(context.l10n.upholstery_configuration),
        actions: [
          // if (_canManageAvailability)
          //   IconButton(
          //     tooltip: context.l10n.employee_availability,
          //     onPressed: () => context.pushNamed(
          //       'employee-availability-screen',
          //       queryParameters: {
          //         'serviceType':
          //             AvailabilityServiceType.upholsteryCleaning.apiValue,
          //       },
          //     ),
          //     icon: const Icon(Icons.calendar_month_outlined),
          //   ),
          BusinessShowcaseHelpButton(onPressed: () => _tour.start(_tourKeys)),
        ],
      ),
      body: BlocConsumer<UpholsteryPricingBloc, UpholsteryPricingState>(
        listener: (context, state) {
          if (state.error != null) context.showErrorToast(state.error);
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(context.l10n.pricing_saved_successfully),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          _syncControllers(state);
          if (state.isLoading && state.pricing.isEmpty) {
            // The BLoC already presents the app-logo loading overlay.
            return const SizedBox.expand();
          }
          if (state.pricing.isEmpty) {
            return Center(child: Text(context.l10n.no_upholstery_types));
          }
          final ownerId = _tourOwnerId;
          if (ownerId != null) {
            _tour.scheduleStartOnce(
              ownerId: ownerId,
              journeyId: 'upholstery_configuration',
              keys: _tourKeys,
            );
          }
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                BusinessShowcaseStep(
                  showcaseKey: _hintTourKey,
                  scope: _tourScope,
                  title: context.l10n.upholstery_configuration,
                  description: context.l10n.upholstery_size_pricing_hint,
                  index: 0,
                  itemCount: 3,
                  child: _PricingInfoCard(
                    message: context.l10n.upholstery_size_pricing_hint,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(state.pricing.length, (index) {
                  final group = state.pricing[index];
                  final type = _typeFor(state, group.upholsteryTypeId);
                  final isExpanded =
                      _expandedTypeIds.contains(group.upholsteryTypeId);
                  final isArabic =
                      Localizations.localeOf(context).languageCode == 'ar';
                  final sizePackages = group.packages
                      .where((package) => package.sizeId != null)
                      .toList(growable: false);
                  final customPackages = group.packages
                      .where((package) => package.sizeId == null)
                      .toList(growable: false);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == state.pricing.length - 1 ? 0 : 16,
                    ),
                    child: index == 0
                        ? BusinessShowcaseStep(
                            showcaseKey: _typeTourKey,
                            scope: _tourScope,
                            title: type?.localizedTitle(isArabic: isArabic) ??
                                context.l10n.upholstery_configuration,
                            description: context
                                .l10n.business_inner_tour_upholstery_type,
                            index: 1,
                            itemCount: 3,
                            child: _buildTypeCard(
                              context,
                              state,
                              group,
                              type,
                              isExpanded,
                              isArabic,
                              sizePackages,
                              customPackages,
                            ),
                          )
                        : _buildTypeCard(
                            context,
                            state,
                            group,
                            type,
                            isExpanded,
                            isArabic,
                            sizePackages,
                            customPackages,
                          ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          BlocBuilder<UpholsteryPricingBloc, UpholsteryPricingState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SafeArea(
              child: BusinessShowcaseStep(
                showcaseKey: _saveTourKey,
                scope: _tourScope,
                title: context.l10n.save_pricing,
                description: context.l10n.business_inner_tour_upholstery_save,
                index: 2,
                itemCount: 3,
                child: FilledButton.icon(
                  onPressed:
                      state.isLoading || state.isSaving || _cannotSave(state)
                          ? null
                          : () => context
                              .read<UpholsteryPricingBloc>()
                              .add(const SaveUpholsteryPricing()),
                  icon: const Icon(Icons.save),
                  label: Text(context.l10n.save_pricing),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context,
    UpholsteryPricingState state,
    UpholsteryPricingGroup group,
    UpholsteryType? type,
    bool isExpanded,
    bool isArabic,
    List<UpholsteryPricingPackage> sizePackages,
    List<UpholsteryPricingPackage> customPackages,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: ValueKey(
                        'upholstery-expand-${group.upholsteryTypeId}',
                      ),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _toggleTypeExpansion(
                        group.upholsteryTypeId,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type?.localizedTitle(
                                          isArabic: isArabic,
                                        ) ??
                                        '-',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.l10n.upholstery_details,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? .5 : 0,
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              child: const Icon(
                                Icons.expand_more,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: context.l10n.offer_upholstery_type,
                  child: Switch.adaptive(
                    key: ValueKey(
                      'upholstery-active-${group.upholsteryTypeId}',
                    ),
                    value: group.isEnabled,
                    onChanged: (value) => context
                        .read<UpholsteryPricingBloc>()
                        .add(ToggleUpholsteryType(
                          upholsteryTypeId: group.upholsteryTypeId,
                          isEnabled: value,
                        )),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(height: 24),
              if (sizePackages.isEmpty)
                Text(
                  context.l10n.no_upholstery_sizes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ...sizePackages.map((package) {
                final size = _sizeFor(type, package.sizeId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SizePriceEditor(
                    typeId: group.upholsteryTypeId,
                    package: package,
                    size: size,
                    isArabic: isArabic,
                    controllers: _controllers,
                    keyFor: _key,
                  ),
                );
              }),
              if (customPackages.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.additional_upholstery_packages,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ...customPackages.map(
                  (package) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PackageEditor(
                      typeId: group.upholsteryTypeId,
                      package: package,
                      controllers: _controllers,
                      keyFor: _key,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PricingInfoCard extends StatelessWidget {
  final String message;

  const _PricingInfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _SizePriceEditor extends StatelessWidget {
  final String typeId;
  final UpholsteryPricingPackage package;
  final UpholsterySize? size;
  final bool isArabic;
  final Map<String, TextEditingController> controllers;
  final String Function(String, String, String) keyFor;

  const _SizePriceEditor({
    required this.typeId,
    required this.package,
    required this.size,
    required this.isArabic,
    required this.controllers,
    required this.keyFor,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller(String field) =>
        controllers[keyFor(typeId, package.rowKey, field)]!;
    final description = size?.localizedDescription(isArabic: isArabic);

    final priceField = _TextField(
      controller: controller('price'),
      label: context.l10n.request_price,
      icon: Icons.payments_outlined,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_decimalFormatter],
      onChanged: (value) => context.read<UpholsteryPricingBloc>().add(
            UpdateUpholsteryPackagePrice(
              upholsteryTypeId: typeId,
              packageRowKey: package.rowKey,
              price: double.tryParse(value) ?? 0,
            ),
          ),
    );
    final discountField = _TextField(
      controller: controller('discount'),
      label: context.l10n.discount_percentage,
      icon: Icons.percent,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_decimalFormatter],
      onChanged: (value) => context.read<UpholsteryPricingBloc>().add(
            UpdateUpholsteryPackageDiscount(
              upholsteryTypeId: typeId,
              packageRowKey: package.rowKey,
              discountPercentage: double.tryParse(value) ?? 0,
            ),
          ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              size?.localizedTitle(isArabic: isArabic) ??
                  (isArabic ? package.titleAr : package.titleEn) ??
                  '-',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 520) {
                  return Column(
                    children: [
                      priceField,
                      const SizedBox(height: 12),
                      discountField,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: priceField),
                    const SizedBox(width: 12),
                    Expanded(child: discountField),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageEditor extends StatelessWidget {
  final String typeId;
  final UpholsteryPricingPackage package;
  final Map<String, TextEditingController> controllers;
  final String Function(String, String, String) keyFor;

  const _PackageEditor({
    required this.typeId,
    required this.package,
    required this.controllers,
    required this.keyFor,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller(String field) =>
        controllers[keyFor(typeId, package.rowKey, field)]!;

    void updateDetails({
      String? titleEn,
      String? titleAr,
      String? descriptionEn,
      String? descriptionAr,
    }) {
      context.read<UpholsteryPricingBloc>().add(
            UpdateUpholsteryPackageDetails(
              upholsteryTypeId: typeId,
              packageRowKey: package.rowKey,
              titleEn: titleEn,
              titleAr: titleAr,
              descriptionEn: descriptionEn,
              descriptionAr: descriptionAr,
            ),
          );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.package_label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.remove_package,
                  onPressed: () => context.read<UpholsteryPricingBloc>().add(
                        RemoveUpholsteryPackage(
                          upholsteryTypeId: typeId,
                          packageRowKey: package.rowKey,
                        ),
                      ),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: controller('titleEn'),
              label: context.l10n.covered_services_title_en,
              icon: Icons.title,
              onChanged: (value) => updateDetails(titleEn: value),
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: controller('titleAr'),
              label: context.l10n.covered_services_title_ar,
              icon: Icons.title,
              onChanged: (value) => updateDetails(titleAr: value),
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: controller('descriptionEn'),
              label: context.l10n.upholstery_description_en,
              icon: Icons.description,
              minLines: 2,
              maxLines: 4,
              onChanged: (value) => updateDetails(descriptionEn: value),
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: controller('descriptionAr'),
              label: context.l10n.upholstery_description_ar,
              icon: Icons.description,
              minLines: 2,
              maxLines: 4,
              onChanged: (value) => updateDetails(descriptionAr: value),
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: controller('price'),
              label: context.l10n.request_price,
              icon: Icons.payments_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              onChanged: (value) => context
                  .read<UpholsteryPricingBloc>()
                  .add(UpdateUpholsteryPackagePrice(
                    upholsteryTypeId: typeId,
                    packageRowKey: package.rowKey,
                    price: double.tryParse(value) ?? 0,
                  )),
            ),
            const SizedBox(height: 12),
            _TextField(
              controller: controller('discount'),
              label: context.l10n.discount_percentage,
              icon: Icons.percent,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              onChanged: (value) => context
                  .read<UpholsteryPricingBloc>()
                  .add(UpdateUpholsteryPackageDiscount(
                    upholsteryTypeId: typeId,
                    packageRowKey: package.rowKey,
                    discountPercentage: double.tryParse(value) ?? 0,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

final _decimalFormatter =
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'));

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int maxLines;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
