import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/contact_actions.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/extra_invoice.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/address.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/chats/presentation/chat_open_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class CarWashJobDetailsScreen extends StatefulWidget {
  final CarWashHistory request;

  const CarWashJobDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  State<CarWashJobDetailsScreen> createState() =>
      _CarWashJobDetailsScreenState();
}

class _CarWashJobDetailsScreenState extends State<CarWashJobDetailsScreen> {
  late CarWashHistory _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
  }

  Address? get _serviceAddress {
    final detail = _currentRequest.detail;
    if (detail?.address != null) return detail!.address;

    final addresses = _currentRequest.customer.addresses ?? const <Address>[];
    final addressId = detail?.addressId;
    if (addressId != null && addressId.isNotEmpty) {
      for (final address in addresses) {
        if (address.id == addressId) return address;
      }
    }
    for (final address in addresses) {
      if (address.isDefault ?? false) return address;
    }
    return addresses.firstOrNull;
  }

  DateTime? get _scheduledTime =>
      _currentRequest.detail?.scheduledTime ?? _currentRequest.scheduledTime;

  bool get _canChat =>
      _currentRequest.canCreateExtraInvoice &&
      (_currentRequest.id?.isNotEmpty ?? false);

  String _localized(String? en, String? ar) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final primary = (isArabic ? ar : en)?.trim();
    final fallback = (isArabic ? en : ar)?.trim();
    if (primary?.isNotEmpty ?? false) return primary!;
    if (fallback?.isNotEmpty ?? false) return fallback!;
    return '';
  }

  String _addressLabel(Address? address) {
    if (address == null) return '-';
    final parts = <String>[
      if ((address.area ?? '').trim().isNotEmpty) address.area!.trim(),
      if ((address.block ?? '').trim().isNotEmpty)
        '${context.l10n.address_block} ${address.block}',
      if ((address.street ?? '').trim().isNotEmpty)
        '${context.l10n.address_street} ${address.street}',
      if ((address.building ?? '').trim().isNotEmpty)
        '${context.l10n.address_building} ${address.building}',
    ];
    return parts.isEmpty ? '-' : parts.join(' - ');
  }

  Future<void> _showExtraInvoiceDialog() async {
    final id = _currentRequest.id;
    if (!_currentRequest.canCreateExtraInvoice ||
        _currentRequest.awaitingExtraPayment ||
        id == null ||
        id.isEmpty) {
      return;
    }

    final request = await showExtraInvoiceDialog(context);
    if (!mounted || request == null) return;

    // Recheck after the dialog in case a job action changed the request status.
    if (!_currentRequest.canCreateExtraInvoice ||
        _currentRequest.awaitingExtraPayment) {
      return;
    }
    context.read<JobActionsBloc>().add(
          AddExtraFeesEvent(id, request),
        );
  }

  void _refreshJobs() {
    context.read<JobBloc>().add(LoadJobsEvent());
  }

  Future<void> _shareDetails() async {
    final request = _currentRequest;
    final specialNotes = request.customerSpecialNotes;
    final lines = <String>[
      context.l10n.car_wash_service,
      '${context.l10n.request_id}: ${request.id ?? '-'}',
      '${context.l10n.request_status}: ${request.requestStatus.displayText(context)}',
      '${context.l10n.signup_name}: ${request.customer.username ?? '-'}',
      '${context.l10n.signup_phone}: ${request.customer.phone ?? '-'}',
      '${context.l10n.request_date_time}: ${RequestFmt.date(_scheduledTime)} ${RequestFmt.time(_scheduledTime)}',
      '${context.l10n.address}: ${_addressLabel(_serviceAddress)}',
      '${context.l10n.request_price}: ${RequestFmt.price(request.totalPrice)}',
      if (specialNotes != null)
        '${context.l10n.request_card_notes}: $specialNotes',
      if ((request.extraFees ?? 0) > 0)
        '${context.l10n.extra_invoice_amount}: ${RequestFmt.price(request.extraFees)}',
      if (request.extraFeesDescription?.isNotEmpty ?? false)
        '${context.l10n.extra_invoice_reason}: ${request.extraFeesDescription}',
    ];
    await Share.share(lines.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    final request = _currentRequest;
    final status = request.requestStatus;
    final vehicles = request.detail?.vehicles ?? const [];
    final specialNotes = request.customerSpecialNotes;
    final canManageJob = request.canCreateExtraInvoice;

    return BlocConsumer<JobActionsBloc, JobActionsState>(
      listener: (context, state) {
        if (state is ExtraFeesAdded) {
          setState(() {
            _currentRequest = resolveExtraInvoiceResult(
              currentRequest: _currentRequest,
              submittedRequest: state.request,
              updatedRequest: state.updatedRequest,
            );
          });
          _refreshJobs();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.extra_invoice_created_successfully),
            ),
          );
        } else if (state is JobStarted && state.model is CarWashHistory) {
          setState(() => _currentRequest = state.model as CarWashHistory);
          _refreshJobs();
        } else if (state is JobCompleted && state.model is CarWashHistory) {
          setState(() => _currentRequest = state.model as CarWashHistory);
          _refreshJobs();
          context.goNamed('jobCompletedSuccessScreen');
        } else if (state is JobActionFailed) {
          context.showErrorToast(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: const BusinessBackButton(
              fallbackRouteName: 'jobs-main-screen',
            ),
            title: Text('#${request.id ?? '-'}'),
            actions: [
              IconButton(
                onPressed: _shareDetails,
                icon: const Icon(Icons.share_outlined),
                tooltip: context.l10n.share,
              ),
            ],
          ),
          body: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: ListView(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Chip(
                    label: Text(
                      status.displayText(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: statusColor(status),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: context.l10n.bids_bottom_sheet_customer_info,
                  child: Column(
                    children: [
                      DetailRow(
                        context.l10n.signup_name,
                        request.customer.username ?? '-',
                      ),
                      const Divider(height: 1),
                      DetailRow(
                        context.l10n.signup_phone,
                        request.customer.phone ?? '-',
                      ),
                      if ((request.customer.phone ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ContactActions(phoneNumber: request.customer.phone!),
                      ],
                    ],
                  ),
                ),
                _SectionCard(
                  title: context.l10n.job_details,
                  child: Column(
                    children: [
                      DetailRow(
                        context.l10n.original_order_total,
                        RequestFmt.price(request.totalPrice),
                      ),
                      const Divider(height: 1),
                      DetailRow(
                        context.l10n.request_date_time,
                        '${RequestFmt.date(_scheduledTime)}  ${RequestFmt.time(_scheduledTime)}',
                      ),
                      const Divider(height: 1),
                      DetailRow(
                        context.l10n.address,
                        _addressLabel(_serviceAddress),
                      ),
                    ],
                  ),
                ),
                _SectionCard(
                  title: context.l10n.car_wash_request_vehicles,
                  child: vehicles.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            context.l10n.no_car_wash_vehicle_details,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : Column(
                          children: List.generate(vehicles.length, (index) {
                            final vehicle = vehicles[index];
                            final vehicleTitle = _localized(
                              vehicle.vehicleTitleEn,
                              vehicle.vehicleTitleAr,
                            );
                            final packageTitle = _localized(
                              vehicle.packageTitleEn,
                              vehicle.packageTitleAr,
                            );
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == vehicles.length - 1 ? 0 : 12,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_car_wash_outlined,
                                        color: AppTheme.primary,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicleTitle.isEmpty
                                                  ? '${context.l10n.vehicle_type} ${index + 1}'
                                                  : vehicleTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              packageTitle.isEmpty
                                                  ? context.l10n.package_label
                                                  : packageTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        RequestFmt.price(vehicle.price),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                ),
                if (specialNotes != null)
                  _SectionCard(
                    title: context.l10n.request_card_notes,
                    child: Text(
                      specialNotes,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                if ((request.extraFees ?? 0) > 0 ||
                    request.awaitingExtraPayment)
                  ExtraInvoiceStatusCard(request: request),
              ],
            ),
          ),
          bottomNavigationBar: canManageJob
              ? SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExtraInvoiceActionButton(
                        request: request,
                        onPressed: _showExtraInvoiceDialog,
                      ),
                      if (_canChat) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => openChatForRequest(
                              context: context,
                              businessId: request.companyInformation?.id,
                              requestId: request.id!,
                            ),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(context.l10n.chat_with_customer),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: status == RequestStatus.confirmed
                              ? () => context.read<JobActionsBloc>().add(
                                    StartJobEvent(request.id ?? ''),
                                  )
                              : status == RequestStatus.inProgress
                                  ? () => context.read<JobActionsBloc>().add(
                                        CompleteJobEvent(
                                          request.id ?? '',
                                          null,
                                        ),
                                      )
                                  : null,
                          child: Text(
                            status == RequestStatus.confirmed
                                ? context.l10n.start_job
                                : context.l10n.complete_job,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
