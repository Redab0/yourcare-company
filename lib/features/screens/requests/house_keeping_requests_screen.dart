import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart'
    as requests_events;
import 'package:cleaning_service_driver/features/chats/presentation/chat_open_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HouseKeepingRequestScreen extends StatefulWidget {
  const HouseKeepingRequestScreen({super.key, required this.request});
  final HouseKeepingHistory request;

  @override
  State<HouseKeepingRequestScreen> createState() =>
      _HouseKeepingRequestScreenState();
}

class _HouseKeepingRequestScreenState extends State<HouseKeepingRequestScreen> {
  List<User> _workers = [];
  final Set<String> _selectedWorkerIds = {};
  String? _checkingWorkerId;
  String? _pendingWorkerId;
  bool _hidePriceForWorker = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    context.read<RequestsActionBloc>().add(FetchWorkersEvent());
  }

  Future<void> _loadRole() async {
    final user = await SecureStorageService().getUser();
    if (!mounted) return;
    setState(() {
      _hidePriceForWorker = user?.role?.toLowerCase() == 'worker';
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRequestId = widget.request.id;
    final canChat = (widget.request.requestStatus == RequestStatus.confirmed ||
            widget.request.requestStatus == RequestStatus.inProgress) &&
        ((effectiveRequestId ?? '').isNotEmpty);
    return BlocConsumer<RequestsActionBloc, RequestsActionState>(
      listener: (ctx, state) {
        if (state is RequestsActionFailed) {
          ctx.showErrorToast();
          if (mounted) {
            setState(() {
              _checkingWorkerId = null;
              _pendingWorkerId = null;
            });
          }
        } else if (state is HouseKeepingRequestObtained) {
          context.goNamed('houseKeepingSuccess', extra: state.request);
          // refresh requests after returning
          context.read<RequestsBloc>().add(
                requests_events.FetchFirstPageRequests(),
              );
        } else if (state is WorkersFetchedState) {
          setState(() {
            _workers = state.workers;
          });
        } else if (state is WorkerAvailabilityChecking) {
          if (mounted) {
            setState(() {
              _checkingWorkerId = state.employeeId;
            });
          }
        } else if (state is WorkerAvailabilityChecked) {
          if (mounted) {
            setState(() {
              _checkingWorkerId = null;
            });
          }
          if (state.employeeId != _pendingWorkerId) return;
          _pendingWorkerId = null;
          if (state.hasConflict) {
            _showConflictDialog();
            return;
          }
          if (mounted) {
            setState(() {
              _selectedWorkerIds.add(state.employeeId);
            });
          }
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            leading: const BusinessBackButton(
              fallbackRouteName: 'requests-main-screen',
            ),
            title: Text(context.l10n.request_details_label),
          ),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: [
                _title(context.l10n.request_details_label),
                if (!_hidePriceForWorker) ...[
                  DetailRow(context.l10n.request_price,
                      RequestFmt.price(widget.request.totalPrice)),
                  const Divider(),
                ],
                DetailRow(
                    context.l10n.request_card_cleaners,
                    RequestFmt.plural(widget.request.detail.cleanersCount,
                        context.l10n.cleaner)),
                const Divider(),
                DetailRow(
                    context.l10n.request_card_duration,
                    RequestFmt.plural(widget.request.detail.durationHours,
                        context.l10n.hour)),
                const Divider(),
                DetailRow(context.l10n.request_card_products,
                    RequestFmt.yesNo(widget.request.detail.productsIncluded)),

                const SizedBox(height: 32),
                _title(context.l10n.request_card_schedule),
                DetailRow(
                    context.l10n.request_date_time,
                    "${RequestFmt.date(widget.request.scheduledTime)}"
                    "${RequestFmt.time(widget.request.scheduledTime)}"),
                const SizedBox(height: 32),
                _title(context.l10n.address),
                Text(widget.request.detail.fullAddress,
                    style: Theme.of(context).textTheme.bodyLarge),

                const SizedBox(height: 32),
                if (widget.request.detail.specialNotes?.trim().isNotEmpty ??
                    false) ...[
                  _title(context.l10n.request_card_notes),
                  Text(widget.request.detail.specialNotes!,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 32),
                ],

                if ((widget.request.subRequests?.isNotEmpty ?? false))
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent)),
                      title: Text(
                        "Sessions", // or a hardcoded 'Package sessions'
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: List.generate(
                          widget.request.subRequests!.length, (i) {
                        final sr = widget.request.subRequests![i];
                        final dateStr = (sr.date != null)
                            ? DateFormat.yMMMd().add_jm().format(sr.date!)
                            : "N/A";
                        final statusText =
                            sr.status?.displayText(context) ?? "N/A";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateStr,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                              if (i < widget.request.subRequests!.length - 1)
                                const Divider(height: 24), // <- add this line
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                // --- Workers Selection ---
                _title(context.l10n.assigned_team),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _workers.length,
                    itemBuilder: (context, idx) {
                      final w = _workers[idx];
                      final isSelected = _selectedWorkerIds.contains(w.id);
                      final isChecking = _checkingWorkerId == w.id;
                      final canSelect = isSelected ||
                          _selectedWorkerIds.length <
                              widget.request.detail.cleanersCount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: canSelect
                              ? () {
                                  if (w.id == null) return;
                                  if (isSelected) {
                                    setState(() {
                                      _selectedWorkerIds.remove(w.id);
                                    });
                                    return;
                                  }
                                  if (_checkingWorkerId != null) return;
                                  setState(() {
                                    _checkingWorkerId = w.id;
                                    _pendingWorkerId = w.id;
                                  });
                                  final scheduledTime =
                                      widget.request.detail.scheduledTime ??
                                          widget.request.scheduledTime;
                                  final durationHours =
                                      widget.request.detail.durationHours;
                                  context.read<RequestsActionBloc>().add(
                                        CheckWorkerAvailability(
                                          employeeId: w.id!,
                                          scheduledTime: scheduledTime,
                                          durationHours: durationHours,
                                        ),
                                      );
                                }
                              : null,
                          child: Opacity(
                            opacity: canSelect ? 1.0 : 0.4,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          w.image != null && w.image!.isNotEmpty
                                              ? NetworkImage(w.image!)
                                              : null,
                                      backgroundColor: isSelected
                                          ? Theme.of(context).primaryColorLight
                                          : Colors.grey.shade200,
                                      child:
                                          (w.image == null || w.image!.isEmpty)
                                              ? Text(
                                                  w.username!
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                    ),
                                    if (isChecking)
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(14),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    w.username ?? "",
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canChat) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => openChatForRequest(
                          context: context,
                          businessId: widget.request.companyInformation?.id,
                          requestId: effectiveRequestId!,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: Text(context.l10n.chat_with_customer),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedWorkerIds.length !=
                              widget.request.detail.cleanersCount
                          ? null
                          : () {
                              context.read<RequestsActionBloc>().add(
                                    ObtainHouseKeepingRequest(
                                      requestId: widget.request.id ?? "",
                                      acceptHouseKeepingModel:
                                          AcceptHouseKeepingModel(
                                        cleanerIds: _selectedWorkerIds.toList(),
                                        serviceIntervalDays: 7,
                                        serviceFrequencyCount: widget
                                                .request.subRequests?.length ??
                                            1,
                                      ),
                                    ),
                                  );
                            },
                      child: Text(
                        _selectedWorkerIds.isEmpty
                            ? context.l10n.select_cleaners
                            : '${context.l10n.request_accept_job} (${_selectedWorkerIds.length}/'
                                '${widget.request.detail.cleanersCount})',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 16),
        child: Text(
          t,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      );

  Future<void> _showConflictDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.schedule_conflict_title),
        content: Text(context.l10n.schedule_conflict_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }
}
