import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/data/models/car_wash/car_wash_models.dart';
import 'package:cleaning_service_driver/data/models/profile/area_response.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_event.dart';
import 'package:cleaning_service_driver/features/bloc/car_wash/car_wash_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarWashPricingScreen extends StatefulWidget {
  const CarWashPricingScreen({super.key});

  @override
  State<CarWashPricingScreen> createState() => _CarWashPricingScreenState();
}

class _CarWashPricingScreenState extends State<CarWashPricingScreen> {
  static const _tourScope = 'business_car_wash_pricing_journey';
  int _selectedSection = 0;
  final _sectionsTourKey = GlobalKey(debugLabel: 'car-wash-sections-tour');
  final _contentTourKey = GlobalKey(debugLabel: 'car-wash-content-tour');
  late final BusinessShowcaseTourController _tour;
  String? _tourOwnerId;

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
        title: Text(context.l10n.car_wash_packages_and_pricing),
        actions: [
          BusinessShowcaseHelpButton(
            onPressed: () => _tour.start([
              _sectionsTourKey,
              _contentTourKey,
            ]),
          ),
          IconButton(
            tooltip: context.l10n.refresh,
            onPressed: () =>
                context.read<CarWashBloc>().add(const LoadCarWashConfig()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocConsumer<CarWashBloc, CarWashState>(
        listener: _listenForFeedback,
        builder: (context, state) {
          final hasNoLoadedContent = state.vehicleTypes.isEmpty &&
              state.packages.isEmpty &&
              state.areas.isEmpty;
          if (state.isLoading && hasNoLoadedContent) {
            // LoadingController already displays the branded app loader.
            return const SizedBox.expand();
          }
          final ownerId = _tourOwnerId;
          if (ownerId != null) {
            _tour.scheduleStartOnce(
              ownerId: ownerId,
              journeyId: 'car_wash_pricing',
              keys: [_sectionsTourKey, _contentTourKey],
            );
          }

          return Column(
            children: [
              BusinessShowcaseStep(
                showcaseKey: _sectionsTourKey,
                scope: _tourScope,
                title: context.l10n.car_wash_packages_and_pricing,
                description: context.l10n.business_inner_tour_car_wash_sections,
                index: 0,
                itemCount: 2,
                targetPadding: EdgeInsets.zero,
                child: _SectionSelector(
                  selectedIndex: _selectedSection,
                  onSelected: (index) {
                    FocusScope.of(context).unfocus();
                    setState(() => _selectedSection = index);
                  },
                ),
              ),
              Expanded(
                child: BusinessShowcaseStep(
                  showcaseKey: _contentTourKey,
                  scope: _tourScope,
                  title: context.l10n.car_wash_packages,
                  description:
                      context.l10n.business_inner_tour_car_wash_package_editor,
                  index: 1,
                  itemCount: 2,
                  child: IndexedStack(
                    index: _selectedSection,
                    children: [
                      _PackagesSection(
                        packages: state.packages,
                        onCreate: () => _openPackageEditor(),
                        onEdit: _openPackageEditor,
                        onDelete: _confirmDeletePackage,
                      ),
                      _VehicleAssignmentsSection(
                        state: state,
                        onCreatePackage: () {
                          setState(() => _selectedSection = 0);
                          _openPackageEditor();
                        },
                      ),
                      _AreaFeesSection(
                        areas: state.areas,
                        areaFees: state.areaFees,
                        onEdit: _openAreaFeeEditor,
                        onDelete: _confirmDeleteAreaFee,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedSection == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openPackageEditor(),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.create_car_wash_package),
            )
          : null,
      bottomNavigationBar: _selectedSection == 1
          ? BlocBuilder<CarWashBloc, CarWashState>(
              builder: (context, state) => SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  onPressed: state.isLoading || state.isSavingPricing
                      ? null
                      : () => context
                          .read<CarWashBloc>()
                          .add(const SaveCarWashPricing()),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(context.l10n.save_package_assignments),
                ),
              ),
            )
          : null,
    );
  }

  void _listenForFeedback(BuildContext context, CarWashState state) {
    if (state.error != null) context.showErrorToast(state.error);
    final message = switch (state.successMessage) {
      'packageCreated' => context.l10n.package_created_successfully,
      'packageUpdated' => context.l10n.package_updated_successfully,
      'packageDeleted' => context.l10n.package_deleted_successfully,
      'assignmentsSaved' => context.l10n.package_assignments_saved_successfully,
      'areaFeeSaved' => context.l10n.area_fee_saved_successfully,
      'areaFeeDeleted' => context.l10n.area_fee_deleted_successfully,
      _ => null,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openPackageEditor([CarWashPackage? package]) async {
    final request = await showModalBottomSheet<CarWashPackageMutationRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _PackageEditorSheet(package: package),
    );
    if (!mounted || request == null) return;
    if (package == null) {
      context.read<CarWashBloc>().add(CreateCarWashPackage(request));
      return;
    }
    context.read<CarWashBloc>().add(
          UpdateCarWashPackage(
            packageId: package.id,
            request: request,
          ),
        );
  }

  Future<void> _confirmDeletePackage(CarWashPackage package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.delete_car_wash_package),
        content: Text(context.l10n.delete_car_wash_package_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<CarWashBloc>().add(DeleteCarWashPackage(package.id));
  }

  Future<void> _openAreaFeeEditor(AreaModel area, double? currentFee) async {
    final areaId = area.id;
    if (areaId == null || areaId.isEmpty) return;
    final fee = await showDialog<double>(
      context: context,
      builder: (_) => _AreaFeeDialog(
        areaName: _areaTitle(context, area),
        currentFee: currentFee,
      ),
    );
    if (!mounted || fee == null) return;
    context.read<CarWashBloc>().add(
          UpsertCarWashAreaFee(areaId: areaId, fee: fee),
        );
  }

  Future<void> _confirmDeleteAreaFee(AreaModel area) async {
    final areaId = area.id;
    if (areaId == null || areaId.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.remove_delivery_fee),
        content: Text(context.l10n.remove_delivery_fee_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<CarWashBloc>().add(DeleteCarWashAreaFee(areaId));
  }
}

class _SectionSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SectionSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sections = [
      (Icons.inventory_2_outlined, context.l10n.car_wash_packages),
      (
        Icons.directions_car_outlined,
        context.l10n.car_wash_vehicle_assignments
      ),
      (Icons.location_on_outlined, context.l10n.car_wash_area_fees),
    ];
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: List.generate(sections.length, (index) {
              final section = sections[index];
              final selected = index == selectedIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == sections.length - 1 ? 0 : 6,
                  ),
                  child: Material(
                    color: selected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              section.$1,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              section.$2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PackagesSection extends StatelessWidget {
  final List<CarWashPackage> packages;
  final VoidCallback onCreate;
  final ValueChanged<CarWashPackage> onEdit;
  final ValueChanged<CarWashPackage> onDelete;

  const _PackagesSection({
    required this.packages,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('car-wash-packages'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      children: [
        _InfoCard(message: context.l10n.car_wash_packages_hint),
        const SizedBox(height: 16),
        if (packages.isEmpty)
          _EmptyCard(
            icon: Icons.inventory_2_outlined,
            message: context.l10n.no_car_wash_packages,
            buttonLabel: context.l10n.create_car_wash_package,
            onPressed: onCreate,
          )
        else
          ...packages.map(
            (package) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PackageCard(
                package: package,
                onEdit: () => onEdit(package),
                onDelete: () => onDelete(package),
              ),
            ),
          ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final CarWashPackage package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PackageCard({
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final description = _localizedPackageDescription(context, package);
    final slots = [...package.workingHours]..sort((a, b) {
        final day = a.dayOfWeek.compareTo(b.dayOfWeek);
        return day != 0 ? day : a.startTime.compareTo(b.startTime);
      });
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizedPackageTitle(context, package),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.edit_car_wash_package,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: context.l10n.delete_car_wash_package,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ValueChip(
                  icon: Icons.payments_outlined,
                  label: '${_formatNumber(package.price)} ${context.l10n.kwd}',
                ),
                if (package.discountPercentage > 0)
                  _ValueChip(
                    icon: Icons.percent,
                    label: _formatNumber(package.discountPercentage),
                  ),
                if (package.duration > 0)
                  _ValueChip(
                    icon: Icons.timer_outlined,
                    label: '${package.duration} ${context.l10n.minutes_short}',
                  ),
                _ValueChip(
                  icon: Icons.schedule_outlined,
                  label: slots.isEmpty
                      ? context.l10n.package_availability_not_set
                      : '${slots.length} ${context.l10n.package_time_slots}',
                ),
              ],
            ),
            if (slots.isNotEmpty) ...[
              const Divider(height: 24),
              ...slots.map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_dayLabel(context, slot.dayOfWeek)}: '
                          '${_displayTime(context, slot.startTime)} - '
                          '${_displayTime(context, slot.endTime)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VehicleAssignmentsSection extends StatelessWidget {
  final CarWashState state;
  final VoidCallback onCreatePackage;

  const _VehicleAssignmentsSection({
    required this.state,
    required this.onCreatePackage,
  });

  @override
  Widget build(BuildContext context) {
    final packages = state.packages;
    return ListView(
      key: const PageStorageKey('car-wash-vehicle-assignments'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _InfoCard(message: context.l10n.car_wash_vehicle_assignments_hint),
        const SizedBox(height: 16),
        if (packages.isEmpty)
          _EmptyCard(
            icon: Icons.inventory_2_outlined,
            message: context.l10n.create_package_first,
            buttonLabel: context.l10n.create_car_wash_package,
            onPressed: onCreatePackage,
          )
        else if (state.vehicleTypes.isEmpty)
          _EmptyCard(
            icon: Icons.directions_car_outlined,
            message: context.l10n.no_car_wash_options,
          )
        else
          ...state.vehicleTypes.map(
            (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VehicleAssignmentCard(
                vehicle: vehicle,
                packages: packages,
                assignedPackageIds:
                    _assignedPackageIds(state.assignments, vehicle.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _VehicleAssignmentCard extends StatelessWidget {
  final CarWashVehicleType vehicle;
  final List<CarWashPackage> packages;
  final Set<String> assignedPackageIds;

  const _VehicleAssignmentCard({
    required this.vehicle,
    required this.packages,
    required this.assignedPackageIds,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey<String>(
          'car-wash-vehicle-assignment-${vehicle.id}',
        ),
        initiallyExpanded: assignedPackageIds.isNotEmpty,
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: .12),
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.directions_car_outlined),
        ),
        title: Text(
          _localizedVehicleTitle(context, vehicle),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(context.l10n.assign_packages_to_vehicle),
        children: [
          const Divider(height: 1),
          ...packages.map(
            (package) => CheckboxListTile(
              value: assignedPackageIds.contains(package.id),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _localizedPackageTitle(context, package),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Text(
                '${_formatNumber(package.price)} ${context.l10n.kwd}'
                '${package.discountPercentage > 0 ? ' | ${_formatNumber(package.discountPercentage)}%' : ''}',
              ),
              onChanged: (selected) => context.read<CarWashBloc>().add(
                    ToggleCarWashPackageAssignment(
                      vehicleTypeId: vehicle.id,
                      packageId: package.id,
                      isAssigned: selected ?? false,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaFeesSection extends StatelessWidget {
  final List<AreaResponse> areas;
  final Map<String, double> areaFees;
  final void Function(AreaModel area, double? fee) onEdit;
  final ValueChanged<AreaModel> onDelete;

  const _AreaFeesSection({
    required this.areas,
    required this.areaFees,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final groups = areas
        .where((group) => (group.areas ?? const <AreaModel>[]).isNotEmpty)
        .toList(growable: false);
    return ListView(
      key: const PageStorageKey('car-wash-area-fees'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _InfoCard(message: context.l10n.car_wash_area_fees_hint),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          _EmptyCard(
            icon: Icons.location_off_outlined,
            message: context.l10n.no_areas_available,
          )
        else
          ...groups.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  key: PageStorageKey<String>(
                    'car-wash-area-fee-group-${entry.$1}',
                  ),
                  title: Text(
                    _governorateTitle(context, entry.$2.title),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  children: (entry.$2.areas ?? const <AreaModel>[])
                      .map((area) => _AreaFeeTile(
                            area: area,
                            fee: area.id == null ? null : areaFees[area.id],
                            isSet: area.id != null &&
                                areaFees.containsKey(area.id),
                            onEdit: onEdit,
                            onDelete: onDelete,
                          ))
                      .toList(growable: false),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AreaFeeTile extends StatelessWidget {
  final AreaModel area;
  final double? fee;
  final bool isSet;
  final void Function(AreaModel area, double? fee) onEdit;
  final ValueChanged<AreaModel> onDelete;

  const _AreaFeeTile({
    required this.area,
    required this.fee,
    required this.isSet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = area.id?.isNotEmpty ?? false;
    return ListTile(
      title: Text(
        _areaTitle(context, area),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        isSet
            ? '${_formatNumber(fee ?? 0)} ${context.l10n.kwd}'
            : context.l10n.fee_not_set,
      ),
      trailing: Wrap(
        spacing: 2,
        children: [
          IconButton(
            tooltip: isSet
                ? context.l10n.edit_delivery_fee
                : context.l10n.set_delivery_fee,
            onPressed: enabled ? () => onEdit(area, fee) : null,
            icon: Icon(isSet ? Icons.edit_outlined : Icons.add_circle_outline),
          ),
          if (isSet)
            IconButton(
              tooltip: context.l10n.remove_delivery_fee,
              onPressed: enabled ? () => onDelete(area) : null,
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
      onTap: enabled ? () => onEdit(area, fee) : null,
    );
  }
}

class _PackageEditorSheet extends StatefulWidget {
  final CarWashPackage? package;

  const _PackageEditorSheet({this.package});

  @override
  State<_PackageEditorSheet> createState() => _PackageEditorSheetState();
}

class _PackageEditorSheetState extends State<_PackageEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleArController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _durationController;
  late List<CarWashPackageWorkingHour> _workingHours;
  String? _workingHoursError;

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    _titleEnController = TextEditingController(text: package?.titleEn ?? '');
    _titleArController = TextEditingController(text: package?.titleAr ?? '');
    _descriptionEnController =
        TextEditingController(text: package?.descriptionEn ?? '');
    _descriptionArController =
        TextEditingController(text: package?.descriptionAr ?? '');
    _priceController = TextEditingController(
      text: package == null ? '' : _formatNumber(package.price),
    );
    _discountController = TextEditingController(
      text: package == null || package.discountPercentage == 0
          ? ''
          : _formatNumber(package.discountPercentage),
    );
    _durationController = TextEditingController(
      text: (package?.duration ?? 0) > 0 ? package!.duration.toString() : '30',
    );
    _workingHours = [...?package?.workingHours]..sort(_compareWorkingHours);
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _descriptionEnController.dispose();
    _descriptionArController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.package != null;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing
                          ? context.l10n.edit_car_wash_package
                          : context.l10n.create_car_wash_package,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextFormField(
                      controller: _titleEnController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.l10n.covered_services_title_en,
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleArController,
                      textInputAction: TextInputAction.next,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: context.l10n.covered_services_title_ar,
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionEnController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: context.l10n.car_wash_description_en,
                        prefixIcon: const Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionArController,
                      minLines: 2,
                      maxLines: 4,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: context.l10n.car_wash_description_ar,
                        prefixIcon: const Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [_decimalInputFormatter],
                            decoration: InputDecoration(
                              labelText: context.l10n.request_price,
                              prefixIcon: const Icon(Icons.payments_outlined),
                              suffixText: context.l10n.kwd,
                            ),
                            validator: (value) => _parseNumber(value) <= 0
                                ? context.l10n.price_must_be_greater_than_zero
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [_decimalInputFormatter],
                            decoration: InputDecoration(
                              labelText: context.l10n.discount_percentage,
                              prefixIcon: const Icon(Icons.percent),
                            ),
                            validator: (value) {
                              final discount = _parseNumber(value);
                              return discount < 0 || discount > 100
                                  ? context.l10n.invalid_discount_percentage
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: context.l10n.package_duration_minutes,
                        helperText: context.l10n.package_duration_minutes_hint,
                        prefixIcon: const Icon(Icons.timer_outlined),
                        suffixText: context.l10n.minutes_short,
                      ),
                      validator: (value) {
                        final duration = int.tryParse(value ?? '') ?? 0;
                        return duration <= 0
                            ? context.l10n.duration_must_be_positive
                            : null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.package_working_hours,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.package_working_hours_hint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_workingHours.isEmpty)
                      _InlineEmptyState(
                        message: context.l10n.package_availability_not_set,
                      )
                    else
                      ...List.generate(
                        _workingHours.length,
                        (index) => _WorkingHourEditorTile(
                          hour: _workingHours[index],
                          onEdit: () => _editWorkingHour(index),
                          onDelete: () {
                            setState(() {
                              _workingHours.removeAt(index);
                              _workingHoursError = null;
                            });
                          },
                        ),
                      ),
                    if (_workingHoursError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _workingHoursError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _editWorkingHour(),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.add_time_slot),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(context.l10n.save_package),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateTitle(String? value) {
    return value?.trim().isEmpty ?? true
        ? context.l10n.package_title_required
        : null;
  }

  Future<void> _editWorkingHour([int? index]) async {
    final existing = index == null ? null : _workingHours[index];
    final result = await showDialog<CarWashPackageWorkingHour>(
      context: context,
      builder: (_) => _WorkingHourDialog(initial: existing),
    );
    if (!mounted || result == null) return;
    final otherHours = [..._workingHours];
    if (index != null) otherHours.removeAt(index);
    if (_hasOverlap(result, otherHours)) {
      setState(() => _workingHoursError = context.l10n.overlapping_time_slot);
      return;
    }
    setState(() {
      if (index == null) {
        _workingHours.add(result);
      } else {
        _workingHours[index] = result;
      }
      _workingHours.sort(_compareWorkingHours);
      _workingHoursError = null;
    });
  }

  void _submit() {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    String? hoursError;
    if (_containsOverlaps(_workingHours)) {
      hoursError = context.l10n.overlapping_time_slot;
    }
    setState(() => _workingHoursError = hoursError);
    if (!formIsValid || hoursError != null) return;

    Navigator.of(context).pop(
      CarWashPackageMutationRequest(
        titleEn: _titleEnController.text,
        titleAr: _titleArController.text,
        descriptionEn: _descriptionEnController.text,
        descriptionAr: _descriptionArController.text,
        price: _parseNumber(_priceController.text),
        discountPercentage: _parseNumber(_discountController.text),
        duration: int.parse(_durationController.text),
        workingHours: List.unmodifiable(_workingHours),
      ),
    );
  }
}

class _WorkingHourEditorTile extends StatelessWidget {
  final CarWashPackageWorkingHour hour;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkingHourEditorTile({
    required this.hour,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        title: Text(
          _dayLabel(context, hour.dayOfWeek),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          '${_displayTime(context, hour.startTime)} - '
          '${_displayTime(context, hour.endTime)}',
        ),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              tooltip: context.l10n.edit_time_slot,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: context.l10n.delete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkingHourDialog extends StatefulWidget {
  final CarWashPackageWorkingHour? initial;

  const _WorkingHourDialog({this.initial});

  @override
  State<_WorkingHourDialog> createState() => _WorkingHourDialogState();
}

class _WorkingHourDialogState extends State<_WorkingHourDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _dayOfWeek;
  late int _startMinutes;
  late int _endMinutes;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _dayOfWeek = initial?.dayOfWeek ?? 0;
    _startMinutes = _storedTimeMinutes(initial?.startTime ?? '09:00');
    _endMinutes = _storedTimeMinutes(initial?.endTime ?? '17:00');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? context.l10n.add_time_slot
            : context.l10n.edit_time_slot,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: InputDecoration(
                  labelText: context.l10n.day_of_week_label,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                items: List.generate(
                  7,
                  (day) => DropdownMenuItem(
                    value: day,
                    child: Text(_dayLabel(context, day)),
                  ),
                ),
                onChanged: (day) {
                  if (day != null) setState(() => _dayOfWeek = day);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _startMinutes,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.start_hour_label,
                      ),
                      items: _hourItems(
                        context,
                        minHour: 0,
                        maxHour: 23,
                        currentMinutes: _startMinutes,
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _startMinutes = value;
                          _timeError = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _endMinutes,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.end_hour_label,
                      ),
                      items: _hourItems(
                        context,
                        minHour: 1,
                        maxHour: 24,
                        currentMinutes: _endMinutes,
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _endMinutes = value;
                          _timeError = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (_timeError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _timeError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> _hourItems(
    BuildContext context, {
    required int minHour,
    required int maxHour,
    required int currentMinutes,
  }) {
    final values = <int>{
      for (var hour = minHour; hour <= maxHour; hour++) hour * 60,
      if (currentMinutes >= 0 && currentMinutes <= 24 * 60) currentMinutes,
    }.toList()
      ..sort();
    return values
        .map(
          (minutes) => DropdownMenuItem<int>(
            value: minutes,
            child: Text(_displayMinutes(context, minutes)),
          ),
        )
        .toList(growable: false);
  }

  String _displayMinutes(BuildContext context, int minutes) {
    final normalized = minutes % (24 * 60);
    return TimeOfDay(
      hour: normalized ~/ 60,
      minute: normalized % 60,
    ).format(context);
  }

  String _storageMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  void _submit() {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    final validRange = _endMinutes > _startMinutes;
    setState(() {
      _timeError = validRange ? null : context.l10n.invalid_time_range;
    });
    if (!formIsValid || !validRange) return;
    Navigator.of(context).pop(
      CarWashPackageWorkingHour(
        dayOfWeek: _dayOfWeek,
        startTime: _storageMinutes(_startMinutes),
        endTime: _storageMinutes(_endMinutes),
      ),
    );
  }
}

class _AreaFeeDialog extends StatefulWidget {
  final String areaName;
  final double? currentFee;

  const _AreaFeeDialog({required this.areaName, this.currentFee});

  @override
  State<_AreaFeeDialog> createState() => _AreaFeeDialogState();
}

class _AreaFeeDialogState extends State<_AreaFeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentFee == null ? '' : _formatNumber(widget.currentFee!),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.currentFee == null
            ? context.l10n.set_delivery_fee
            : context.l10n.edit_delivery_fee,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.areaName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalInputFormatter],
              decoration: InputDecoration(
                labelText: context.l10n.delivery_fee,
                prefixIcon: const Icon(Icons.payments_outlined),
                suffixText: context.l10n.kwd,
              ),
              validator: (value) => _parseNumber(value) < 0
                  ? context.l10n.fee_cannot_be_negative
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(_parseNumber(_controller.text));
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String message;

  const _InfoCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const _EmptyCard({
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  final String message;

  const _InlineEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.schedule_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ValueChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17),
            const SizedBox(width: 6),
            Flexible(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

final _decimalInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*[.,]?\d{0,3}'),
);

Set<String> _assignedPackageIds(
  List<CarWashVehiclePackageAssignment> assignments,
  String vehicleTypeId,
) {
  for (final assignment in assignments) {
    if (assignment.vehicleTypeId == vehicleTypeId) {
      return assignment.packageIds.toSet();
    }
  }
  return <String>{};
}

String _localizedPackageTitle(BuildContext context, CarWashPackage package) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final preferred = isArabic ? package.titleAr : package.titleEn;
  final fallback = isArabic ? package.titleEn : package.titleAr;
  return preferred.trim().isNotEmpty
      ? preferred.trim()
      : fallback.trim().isNotEmpty
          ? fallback.trim()
          : context.l10n.package_label;
}

String _localizedPackageDescription(
  BuildContext context,
  CarWashPackage package,
) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final preferred = isArabic ? package.descriptionAr : package.descriptionEn;
  final fallback = isArabic ? package.descriptionEn : package.descriptionAr;
  return preferred.trim().isNotEmpty ? preferred.trim() : fallback.trim();
}

String _localizedVehicleTitle(
  BuildContext context,
  CarWashVehicleType vehicle,
) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final preferred = isArabic ? vehicle.titleAr : vehicle.titleEn;
  final fallback = isArabic ? vehicle.titleEn : vehicle.titleAr;
  return preferred?.trim().isNotEmpty ?? false
      ? preferred!.trim()
      : fallback?.trim().isNotEmpty ?? false
          ? fallback!.trim()
          : context.l10n.vehicle_type;
}

String _governorateTitle(BuildContext context, Governorate? governorate) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final preferred = isArabic ? governorate?.ar : governorate?.en;
  final fallback = isArabic ? governorate?.en : governorate?.ar;
  return preferred?.trim().isNotEmpty ?? false
      ? preferred!.trim()
      : fallback?.trim().isNotEmpty ?? false
          ? fallback!.trim()
          : '-';
}

String _areaTitle(BuildContext context, AreaModel area) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final preferred = isArabic ? area.ar ?? area.areaAr : area.en ?? area.areaEn;
  final fallback = isArabic ? area.en ?? area.areaEn : area.ar ?? area.areaAr;
  return preferred?.trim().isNotEmpty ?? false
      ? preferred!.trim()
      : fallback?.trim().isNotEmpty ?? false
          ? fallback!.trim()
          : area.name?.trim().isNotEmpty ?? false
              ? area.name!.trim()
              : '-';
}

String _dayLabel(BuildContext context, int dayOfWeek) {
  final labels = [
    context.l10n.sunday,
    context.l10n.monday,
    context.l10n.tuesday,
    context.l10n.wednesday,
    context.l10n.thursday,
    context.l10n.friday,
    context.l10n.saturday,
  ];
  return labels[dayOfWeek.clamp(0, 6)];
}

String _displayTime(BuildContext context, String value) {
  final normalized = _storedTimeMinutes(value) % (24 * 60);
  return TimeOfDay(
    hour: normalized ~/ 60,
    minute: normalized % 60,
  ).format(context);
}

int _storedTimeMinutes(String value) {
  final parts = value.split(':');
  final hour = (int.tryParse(parts.firstOrNull ?? '') ?? 0).clamp(0, 24);
  final minute =
      (int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0).clamp(0, 59);
  return hour == 24 ? 24 * 60 : hour * 60 + minute;
}

int _compareWorkingHours(
  CarWashPackageWorkingHour a,
  CarWashPackageWorkingHour b,
) {
  final dayComparison = a.dayOfWeek.compareTo(b.dayOfWeek);
  return dayComparison != 0
      ? dayComparison
      : _storedTimeMinutes(a.startTime)
          .compareTo(_storedTimeMinutes(b.startTime));
}

bool _hasOverlap(
  CarWashPackageWorkingHour candidate,
  List<CarWashPackageWorkingHour> existing,
) {
  final candidateStart = _storedTimeMinutes(candidate.startTime);
  final candidateEnd = _storedTimeMinutes(candidate.endTime);
  return existing.any((hour) {
    if (hour.dayOfWeek != candidate.dayOfWeek) return false;
    final start = _storedTimeMinutes(hour.startTime);
    final end = _storedTimeMinutes(hour.endTime);
    return candidateStart < end && start < candidateEnd;
  });
}

bool _containsOverlaps(List<CarWashPackageWorkingHour> hours) {
  for (var index = 0; index < hours.length; index++) {
    final others = [...hours]..removeAt(index);
    if (_hasOverlap(hours[index], others)) return true;
  }
  return false;
}

double _parseNumber(String? value) {
  return double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0;
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
