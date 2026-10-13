import 'dart:async';

import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/contact_actions.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/extra_invoice.dart';
import 'package:cleaning_service_driver/components/laundry_same_day_badge.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/components/open_map_action.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/kuwait_schedule.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/share_utils.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_models.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_cubit.dart';
import 'package:cleaning_service_driver/features/chats/presentation/chat_open_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'laundry_catalog_load_notice.dart';
import 'laundry_catalog_screen.dart';
import 'laundry_invoice_editor.dart';
import 'laundry_presentation.dart';

class LaundryJobDetailsScreen extends StatefulWidget {
  final LaundryHistory request;
  const LaundryJobDetailsScreen({super.key, required this.request});
  @override
  State<LaundryJobDetailsScreen> createState() =>
      _LaundryJobDetailsScreenState();
}

class _LaundryJobDetailsScreenState extends State<LaundryJobDetailsScreen> {
  late final _cubit =
      LaundryCubit(sl<LaundryRepository>(), order: widget.request);
  bool _catalogLoaded = false;
  bool _openingInvoice = false;
  LaundryInvoiceRequest? _pendingInvoice;
  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _invoice() async {
    if (_openingInvoice ||
        _cubit.state.loading ||
        !_cubit.state.order!.displayDetail.canEditInvoice) {
      return;
    }
    setState(() => _openingInvoice = true);
    try {
      if (!_catalogLoaded) {
        await _cubit.loadCatalog();
        if (!mounted ||
            _cubit.state.catalogFailure != null ||
            _cubit.state.error != null) {
          return;
        }
        _catalogLoaded = true;
      }
      if (!mounted) return;
      final body = await Navigator.of(context).push<LaundryInvoiceRequest>(
          MaterialPageRoute(
              builder: (_) => LaundryInvoiceEditor(
                  catalog: _cubit.state.catalog,
                  draft: _pendingInvoice,
                  onManageCatalog: _manageCatalog,
                  minimumCharge: _cubit.state.order!.detail.minimumCharge,
                  invoice: _cubit.state.order!.detail.invoice)));
      if (mounted &&
          body != null &&
          _cubit.state.order!.displayDetail.canEditInvoice) {
        _pendingInvoice = body;
        await _cubit.saveInvoice(body);
        if (_cubit.state.error != null) {
          _catalogLoaded = false;
        } else {
          _pendingInvoice = null;
        }
      }
    } finally {
      if (mounted) setState(() => _openingInvoice = false);
    }
  }

  Future<List<LaundryCatalogItem>?> _manageCatalog() async {
    await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const LaundryCatalogScreen()));
    if (!mounted) return null;
    await _cubit.loadCatalog();
    if (!mounted) return null;
    if (_cubit.state.catalogFailure == LaundryCatalogFailure.timeout) {
      throw TimeoutException('Laundry catalog request timed out');
    }
    if (_cubit.state.error != null) throw Exception(_cubit.state.error);
    _catalogLoaded = true;
    return _cubit.state.catalog;
  }

  Future<void> _reloadInvoice() async {
    final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(context.l10n.laundry_reload_invoice),
                content: Text(context.l10n.laundry_reload_invoice_confirm),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.l10n.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.l10n.laundry_reload_invoice))
                ]));
    if (discard != true || !mounted) return;
    await _cubit.refreshOrder();
    if (!mounted || _cubit.state.error != null) return;
    setState(() {
      _pendingInvoice = null;
      _catalogLoaded = false;
    });
    if (_cubit.state.order!.displayDetail.canEditInvoice) await _invoice();
  }

  Future<void> _sendInvoice() async {
    if (!_cubit.state.order!.displayDetail.canSendInvoice) return;
    if (await confirmLaundryInvoice(context) &&
        mounted &&
        _cubit.state.order!.displayDetail.canSendInvoice) {
      await _cubit.sendInvoice();
    }
  }

  Future<void> _createExtraInvoice() async {
    final order = _cubit.state.order!;
    if (!order.canCreateExtraInvoice ||
        order.hasPendingExtraInvoicePayment ||
        order.id?.isNotEmpty != true) {
      return;
    }
    final request = await showExtraInvoiceDialog(context);
    if (!mounted || request == null) return;
    final current = _cubit.state.order!;
    if (!current.canCreateExtraInvoice ||
        current.hasPendingExtraInvoicePayment) {
      return;
    }
    _jobActionsBloc(context)?.add(AddExtraFeesEvent(current.id!, request));
  }

  JobActionsBloc? _jobActionsBloc(BuildContext context) {
    try {
      return context.read<JobActionsBloc>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  Future<void> _status(String status) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(laundryActionLabel(context, status)),
                content: Text(context.l10n.laundry_confirm_action),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.l10n.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(laundryActionLabel(context, status)))
                ]));
    if (confirm == true &&
        mounted &&
        _cubit.state.order!.displayDetail.nextStatuses.contains(status)) {
      await _cubit.updateStatus(status);
    }
  }

  Widget _row(String label, String value) =>
      Padding(padding: EdgeInsets.zero, child: DetailRow(label, value));

  Widget _section(String title, List<Widget> children) => Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppTheme.primary)),
            const SizedBox(height: 8),
            ...children
          ])));

  String _addressLabel(LaundryHistory order) {
    final address = order.pickupAddress;
    if (address == null) return '-';
    final parts = <String>[
      if ((address.name ?? '').trim().isNotEmpty) address.name!.trim(),
      if ((address.area ?? '').trim().isNotEmpty) address.area!.trim(),
      if ((address.block ?? '').trim().isNotEmpty)
        '${context.l10n.address_block} ${address.block}',
      if ((address.street ?? '').trim().isNotEmpty)
        '${context.l10n.address_street} ${address.street}',
      if ((address.building ?? '').trim().isNotEmpty)
        '${context.l10n.address_building} ${address.building}',
      if ((address.floor ?? '').trim().isNotEmpty)
        '${context.l10n.address_floor} ${address.floor}',
      if ((address.apartment ?? '').trim().isNotEmpty)
        '${context.l10n.address_apartment_number} ${address.apartment}',
    ];
    return parts.isEmpty ? address.name ?? '-' : parts.join(' - ');
  }

  Future<void> _shareDetails(BuildContext shareContext) async {
    final order = _cubit.state.order!;
    final detail = order.displayDetail;
    final scheduled = detail.scheduledTime ?? order.scheduledTime;
    final address = order.pickupAddress;
    final mapLink =
        OpenMapAction.googleMapsLink(address?.latitude, address?.longitude);
    await shareTextFrom(
        shareContext,
        [
          context.l10n.laundry_order,
          '${context.l10n.request_id}: ${order.id ?? '-'}',
          '${context.l10n.request_status}: ${laundryStatusLabel(context, detail.displayStatus)}',
          '${context.l10n.signup_name}: ${order.customer.username ?? '-'}',
          '${context.l10n.signup_phone}: ${order.customer.phone ?? '-'}',
          '${context.l10n.request_date_time}: ${RequestFmt.date(scheduled)} ${RequestFmt.time(scheduled)}',
          '${context.l10n.address}: ${_addressLabel(order)}',
          if (mapLink != null) 'Google Maps: $mapLink',
          '${context.l10n.laundry_payment_status}: ${laundryStatusLabel(context, detail.paymentStatus)}',
          if (detail.invoice != null)
            '${context.l10n.laundry_total}: ${RequestFmt.price(detail.invoice!.total)}'
          else
            '${context.l10n.laundry_total}: ${RequestFmt.price(order.totalPrice)}',
          if (detail.specialNotes?.trim().isNotEmpty == true)
            '${context.l10n.notes}: ${detail.specialNotes}',
        ].join('\n'));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<LaundryCubit,
          LaundryState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.error != null && state.catalogFailure == null) {
          context.showErrorToast(state.error);
        }
      },
      builder: (context, state) {
        final jobActionsBloc = _jobActionsBloc(context);
        final order = state.order!;
        final detail = order.displayDetail;
        final address = order.pickupAddress;
        final arabic = context.l10n.localeName.startsWith('ar');
        final invoice = detail.invoice;
        final scheduled = detail.scheduledTime ?? order.scheduledTime;
        final statusAccent =
            detail.status == 'cancelled' || detail.status == 'pickup_rejected'
                ? Theme.of(context).colorScheme.error
                : detail.isPaid
                    ? Colors.green.shade800
                    : detail.isAwaitingPayment
                        ? Colors.orange.shade800
                        : AppTheme.primary;
        final scaffold = Scaffold(
          appBar: AppBar(
              leading: const BusinessBackButton(
                  fallbackRouteName: 'jobs-main-screen'),
              title: Text('#${order.id ?? ''}'),
              actions: [
                IconButton(
                    tooltip: context.l10n.laundry_refresh,
                    onPressed: state.loading ? null : _cubit.refreshOrder,
                    icon: const Icon(Icons.refresh)),
                Builder(
                    builder: (shareContext) => IconButton(
                        tooltip: context.l10n.share,
                        onPressed: () => _shareDetails(shareContext),
                        icon: const Icon(Icons.share_outlined)))
              ]),
          body: state.loading && !state.loadingCatalog
              ? const Center(
                  child: AppIconSpinner(
                      assetPath: 'assets/images/ic_yourcare.png'))
              : RefreshIndicator(
                  onRefresh: _cubit.refreshOrder,
                  child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Chip(
                            label: Text(
                              laundryStatusLabel(context, detail.displayStatus),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                            backgroundColor: statusAccent,
                          ),
                        ),
                        LaundrySameDayBadge(sameDay: detail.sameDay),
                        _section(context.l10n.laundry_customer, [
                          _row(context.l10n.signup_name,
                              order.customer.username ?? '-'),
                          _row(context.l10n.signup_phone,
                              order.customer.phone ?? '-'),
                          if (order.customer.phone?.isNotEmpty == true)
                            ContactActions(phoneNumber: order.customer.phone!),
                        ]),
                        _section(context.l10n.job_details, [
                          if (scheduled != null)
                            _row(
                                context.l10n.request_date_time,
                                DateFormat.yMMMd(context.l10n.localeName)
                                    .add_jm()
                                    .format(kuwaitWallTime(scheduled))),
                          _row(context.l10n.address, _addressLabel(order)),
                          if (OpenMapAction.hasValidCoordinates(
                              address?.latitude, address?.longitude))
                            DetailWidgetRow(
                              context.l10n.request_location,
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: OpenMapAction(
                                  latitude: address!.latitude!,
                                  longitude: address.longitude!,
                                ),
                              ),
                            ),
                          if (detail.numberOfBags != null)
                            _row(context.l10n.laundry_bags,
                                '${detail.numberOfBags}'),
                        ]),
                        _section(context.l10n.laundry_items, [
                          if (detail.displayedItems.isEmpty)
                            Text(detail.isPickupFirst
                                ? context.l10n.laundry_bag_items_help
                                : context.l10n.laundry_no_items),
                          for (var index = 0;
                              index < detail.displayedItems.length;
                              index++) ...[
                            if (index > 0) const Divider(height: 20),
                            Builder(builder: (context) {
                              final line = detail.displayedItems[index];
                              final descriptor = <String>[
                                if (line.sizeName(arabic)?.isNotEmpty == true)
                                  '${line.serviceId != null ? context.l10n.laundry_item_service : context.l10n.laundry_size}: ${line.sizeName(arabic)}',
                                '${context.l10n.laundry_quantity}: ${line.quantity} × ${RequestFmt.price(line.unitPrice)} ${laundryUnitLabel(context, line.unit, line.unitLabel)}',
                              ].join(' · ');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _row(line.name(arabic),
                                      RequestFmt.price(line.total)),
                                  Text(descriptor,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              );
                            }),
                          ],
                        ]),
                        _section(
                            invoice == null
                                ? context.l10n.laundry_total
                                : context.l10n.laundry_invoice,
                            [
                              _row(
                                  context.l10n.laundry_payment_status,
                                  laundryStatusLabel(
                                      context, detail.paymentStatus)),
                              if (!detail.isPickupFirst || detail.isPaid)
                                _row(context.l10n.original_order_total,
                                    RequestFmt.price(order.totalPrice)),
                              if (detail.invoiceMinimumCharge > 0 &&
                                  detail.canEditInvoice) ...[
                                _row(
                                    context.l10n.laundry_minimum_charge,
                                    RequestFmt.price(
                                        detail.invoiceMinimumCharge)),
                                if (!detail.invoiceMeetsMinimum)
                                  Text(context
                                      .l10n.laundry_minimum_invoice_help),
                              ],
                              if (detail.isAwaitingPayment)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                      context.l10n.laundry_waiting_payment),
                                ),
                            ]),
                        if (detail.specialNotes?.trim().isNotEmpty == true)
                          _section(context.l10n.request_card_notes, [
                            Text(detail.specialNotes!,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ]),
                        if (order.hasExtraInvoice)
                          ExtraInvoiceStatusCard(request: order),
                        if (order.id?.isNotEmpty == true &&
                            detail.canEditInvoice)
                          LaundryCatalogLoadNotice(
                            loading: state.loadingCatalog,
                            failure: state.catalogFailure,
                            onRetry: _invoice,
                          ),
                      ])),
          bottomNavigationBar: order.id?.isNotEmpty != true
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (jobActionsBloc != null)
                        ExtraInvoiceActionButton(
                          request: order,
                          onPressed: _createExtraInvoice,
                        ),
                      if (detail.canEditInvoice)
                        OutlinedButton.icon(
                          onPressed: state.loading || _openingInvoice
                              ? null
                              : _invoice,
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: Text(invoice == null
                              ? context.l10n.laundry_create_invoice
                              : context.l10n.laundry_edit_invoice),
                        ),
                      if (detail.canEditInvoice && _pendingInvoice != null)
                        TextButton(
                          onPressed: state.loading || _openingInvoice
                              ? null
                              : _reloadInvoice,
                          child: Text(context.l10n.laundry_reload_invoice),
                        ),
                      if (detail.canSendInvoice)
                        FilledButton.icon(
                          onPressed: state.loading || _openingInvoice
                              ? null
                              : _sendInvoice,
                          icon: const Icon(Icons.send_outlined),
                          label: Text(context.l10n.laundry_send_invoice),
                        ),
                      if (detail.nextStatuses.contains('completed'))
                        FilledButton(
                          onPressed: state.loading || _openingInvoice
                              ? null
                              : () => _status('completed'),
                          child: Text(context.l10n.laundry_complete),
                        ),
                      for (final status in detail.nextStatuses
                          .where((status) => status != 'completed'))
                        OutlinedButton(
                          onPressed: state.loading || _openingInvoice
                              ? null
                              : () => _status(status),
                          child: Text(laundryActionLabel(context, status)),
                        ),
                      if (!['completed', 'cancelled', 'pickup_rejected']
                          .contains(detail.status))
                        OutlinedButton.icon(
                          onPressed: () => openChatForRequest(
                              context: context, requestId: order.id!),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: Text(context.l10n.chat_with_customer),
                        ),
                    ],
                  ),
                ),
        );
        if (jobActionsBloc == null) return scaffold;
        return BlocListener<JobActionsBloc, JobActionsState>(
          bloc: jobActionsBloc,
          listener: (context, actionState) {
            if (actionState is ExtraFeesAdded) {
              final current = _cubit.state.order;
              if (current == null) return;
              _cubit.updateOrder(resolveExtraInvoiceResult<LaundryHistory>(
                currentRequest: current,
                submittedRequest: actionState.request,
                updatedRequest: actionState.updatedRequest,
              ));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(context.l10n.extra_invoice_created_successfully)));
            } else if (actionState is JobRefreshed &&
                actionState.model is LaundryHistory &&
                actionState.model.id == _cubit.state.order?.id) {
              _cubit.updateOrder(actionState.model as LaundryHistory);
            } else if (actionState is JobActionFailed) {
              context.showErrorToast(actionState.message);
            }
          },
          child: scaffold,
        );
      });
}
