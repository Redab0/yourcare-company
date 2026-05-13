import 'package:cleaning_service_driver/components/contact_actions.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/open_map_action.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/update_request_frequency_request.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart'
    as requests_events;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class HouseKeepingJobDetails extends StatefulWidget {
  const HouseKeepingJobDetails({super.key, required this.request});
  final HouseKeepingHistory request;

  @override
  State<HouseKeepingJobDetails> createState() => _HouseKeepingJobDetailsState();
}

class _HouseKeepingJobDetailsState extends State<HouseKeepingJobDetails> {
  bool _isEditingWorkers = false;
  List<User> _allWorkers = [];
  bool _isFilteringWorkers = false;
  final Set<String> _selectedWorkerIds = {};
  late HouseKeepingHistory _currentRequest;
  bool _hidePriceForWorker = false;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
    _selectedWorkerIds.clear();
    _currentRequest.assignedWorker
        ?.forEach((w) => _selectedWorkerIds.add(w.id));
    _loadRole();
    _loadAvailableWorkers();
  }

  Future<void> _loadRole() async {
    final user = await SecureStorageService().getUser();
    if (!mounted) return;
    setState(() {
      _hidePriceForWorker = user?.role?.toLowerCase() == 'worker';
    });
  }

  void _loadAvailableWorkers() {
    final scheduledTime =
        _currentRequest.detail.scheduledTime ?? _currentRequest.scheduledTime;
    final durationHours = _currentRequest.detail.durationHours;
    setState(() => _isFilteringWorkers = true);
    context.read<JobActionsBloc>().add(
          FetchAvailableWorkersEvent(
            scheduledTime: scheduledTime,
            durationHours: durationHours,
            ignoreRequestId: _currentRequest.id,
            selectedWorkerIds: _selectedWorkerIds.toList(),
          ),
        );
  }

  void _toggleEditWorkers() {
    if (!_isEditingWorkers) {
      if (_allWorkers.isEmpty && !_isFilteringWorkers) {
        _loadAvailableWorkers();
      }
    }
    if (_isEditingWorkers) {
      setState(() => _isFilteringWorkers = false);
    }
    setState(() => _isEditingWorkers = !_isEditingWorkers);
  }

  void _saveWorkers() {
    context.read<JobActionsBloc>().add(
          AssignWorkersEvent(
              _currentRequest.id ?? "",
              AcceptHouseKeepingModel(
                cleanerIds: _selectedWorkerIds.toList(),
                // serviceIntervalDays: 7,
                // serviceFrequencyCount:
                //     widget.request.subRequests?.length ?? 1
              )),
        );
  }

  void _maybeRefreshRequests() {
    try {
      context
          .read<RequestsBloc>()
          .add(requests_events.FetchFirstPageRequests());
    } catch (_) {}
  }

  String _statusPair(RequestStatus status) {
    switch (status) {
      case RequestStatus.confirmed:
        return 'Confirmed / مؤكد';
      case RequestStatus.pending:
        return 'Pending / قيد الانتظار';
      case RequestStatus.inProgress:
        return 'In Progress / قيد التنفيذ';
      case RequestStatus.completed:
        return 'Completed / مكتمل';
      case RequestStatus.cancelled:
      case RequestStatus.canceled:
        return 'Cancelled / ملغي';
      case RequestStatus.notPaid:
        return 'Not Paid / غير مدفوع';
      case RequestStatus.paid:
        return 'Paid / مدفوع';
      case RequestStatus.unknown:
        return 'Unknown / غير معروف';
    }
  }

  Future<void> _shareDetails() async {
    final req = _currentRequest;
    final detail = req.detail;
    final name = req.customer.username?.trim();
    final phone = req.customer.phone?.trim();
    final lat = detail.address?.latitude;
    final lng = detail.address?.longitude;
    final mapUrl = (lat != null && lng != null)
        ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        : null;
    final lines = <String>[
      '==============================',
      'House Keeping / التنظيف المنزلي',
      '==============================',
      '',
      '--- Request / الطلب ---',
      'Request ID / رقم الطلب: ${req.id ?? '-'}',
      'Request Status / حالة الطلب: ${_statusPair(req.requestStatus)}',
      'Date and Time / الوقت والتاريخ: ${RequestFmt.date(req.scheduledTime)} ${RequestFmt.time(req.scheduledTime)}',
      'Address / العنوان: ${detail.fullAddress}',
      '',
      '--- Customer / العميل ---',
      'Customer Name / اسم العميل: ${(name == null || name.isEmpty) ? '-' : name}',
      'Customer Phone / رقم العميل: ${(phone == null || phone.isEmpty) ? '-' : phone}',
      '',
      '--- Location / الموقع ---',
      'Google Maps: ${mapUrl ?? '-'}',
      '',
      '--- Job Details / تفاصيل الطلب ---',
      'Cleaners / عدد العمال: ${detail.cleanersCount}',
      'Duration / المدة: ${detail.durationHours} hour / ساعة',
    ];
    final subRequests = req.subRequests ?? const [];
    if (subRequests.isNotEmpty) {
      lines.add('');
      lines.add('--- ${context.l10n.number_of_visits} ---');
      for (var i = 0; i < subRequests.length; i++) {
        final visit = subRequests[i];
        final dateStr = (visit.date != null)
            ? DateFormat.yMMMd().add_jm().format(visit.date!)
            : '-';
        final statusText = visit.status?.displayText(context) ?? '-';
        lines.add('${i + 1}. $dateStr - $statusText');
      }
    }
    if (!_hidePriceForWorker) {
      lines.add('Price / السعر: ${RequestFmt.price(req.totalPrice)}');
    }
    await Share.share(lines.join('\n'));
  }

  @override
  Widget build(BuildContext context) {
    final req = _currentRequest;
    final detail = req.detail;
    final hasNotes = (detail.specialNotes?.trim().isNotEmpty ?? false);

    return BlocConsumer<JobActionsBloc, JobActionsState>(
      listener: (ctx, state) {
        if (state is WorkersFetchedState) {
          // store the list once it arrives
          setState(() {
            _allWorkers = state.workers;
            _isFilteringWorkers = false;
          });
        } else if (state is JobActionFailed) {
          if (mounted) {
            setState(() => _isFilteringWorkers = false);
          }
          ctx.showErrorToast();
          print("ERROR ${state.message}");
        } else if (state is WorkersAssigned) {
          // they just saved successfully
          setState(() {
            _isEditingWorkers = false;
            // refresh the request’s assignedWorker list
            _currentRequest = (state.model as HouseKeepingHistory);
          });
        } else if (state is JobStarted) {
          setState(() {
            _currentRequest = (state.model as HouseKeepingHistory);
          });
          context.read<JobBloc>().add(LoadJobsEvent());
          _maybeRefreshRequests();
        } else if (state is JobCompleted) {
          setState(() {
            _currentRequest = (state.model as HouseKeepingHistory);
          });
          context.read<JobBloc>().add(LoadJobsEvent());
          _maybeRefreshRequests();
          context.goNamed('jobCompletedSuccessScreen');
        } else if (state is RequestFrequencyUpdated) {
          setState(() {
            _currentRequest = (state.response as HouseKeepingHistory);
          });
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('#${_currentRequest.id}'),
            actions: [
              IconButton(
                onPressed: _shareDetails,
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if ((_currentRequest.subRequests?.isNotEmpty ?? false))
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.transparent)),
                        title: Text(
                          context.l10n.number_of_visits,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: List.generate(
                            _currentRequest.subRequests!.length, (i) {
                          final sr = _currentRequest.subRequests![i];
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
                                          Text(dateStr,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          if (sr.status ==
                                                  RequestStatus.confirmed ||
                                              sr.status ==
                                                  RequestStatus.inProgress)
                                            Row(
                                              children: [
                                                FilledButton(
                                                  onPressed:
                                                      (sr.id == null ||
                                                              sr.id!.isEmpty)
                                                          ? null
                                                          : () => {
                                                                if (sr.status ==
                                                                    RequestStatus
                                                                        .confirmed)
                                                                  {
                                                                    ctx
                                                                        .read<
                                                                            JobActionsBloc>()
                                                                        .add(
                                                                          UpdateFrequencyRequestEvent(
                                                                            UpdateRequestFrequencyRequest(
                                                                              frequencyDateId: sr.id,
                                                                              status: RequestStatus.inProgress,
                                                                            ),
                                                                            widget.request.id ??
                                                                                "",
                                                                          ),
                                                                        )
                                                                  }
                                                                else if (sr
                                                                        .status ==
                                                                    RequestStatus
                                                                        .inProgress)
                                                                  {
                                                                    ctx
                                                                        .read<
                                                                            JobActionsBloc>()
                                                                        .add(
                                                                          UpdateFrequencyRequestEvent(
                                                                            UpdateRequestFrequencyRequest(
                                                                              frequencyDateId: sr.id,
                                                                              status: RequestStatus.completed,
                                                                            ),
                                                                            widget.request.id ??
                                                                                "",
                                                                          ),
                                                                        )
                                                                  }
                                                              },
                                                  child: Text(
                                                    sr.status ==
                                                            RequestStatus
                                                                .confirmed
                                                        ? context.l10n.start_job
                                                        : context
                                                            .l10n.complete_job,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Chip(
                                      label: Text(statusText,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      backgroundColor: statusColor(sr.status!),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                if (i < _currentRequest.subRequests!.length - 1)
                                  const Divider(height: 24), // <- add this line
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  _buildSection(
                    title: context.l10n.bids_bottom_sheet_customer_info,
                    child: Column(
                      children: [
                        DetailRow(context.l10n.signup_name,
                            _currentRequest.customer.username ?? ""),
                        const Divider(),
                        DetailRow(context.l10n.signup_phone,
                            _currentRequest.customer.phone ?? ""),
                        ContactActions(
                            phoneNumber: _currentRequest.customer.phone ?? "")
                      ],
                    ),
                    expanded: true,
                  ),
                  _buildSection(
                    expanded: true,
                    title: context.l10n.job_details,
                    child: Column(
                      children: [
                        if (!_hidePriceForWorker) ...[
                          DetailRow(context.l10n.request_price,
                              RequestFmt.price(req.totalPrice)),
                          const Divider(),
                        ],
                        DetailRow(
                            context.l10n.request_card_cleaners,
                            RequestFmt.plural(
                                detail.cleanersCount, context.l10n.cleaner)),
                        const Divider(),
                        DetailRow(context.l10n.request_card_duration,
                            "${detail.durationHours} ${context.l10n.hour}"),
                        const Divider(),
                        DetailRow(context.l10n.requests_cleaning_product_title,
                            RequestFmt.yesNo(detail.productsIncluded)),
                        // const Divider(),
                        // DetailRow("Sessions",
                        //     "${widget.request.subRequests?.length ?? 1}"),
                      ],
                    ),
                  ),
                  _buildSection(
                    expanded: false,
                    title: context.l10n.request_card_schedule,
                    child: Column(
                      children: [
                        DetailRow(context.l10n.request_date_time,
                            "${RequestFmt.date(req.scheduledTime)}  ${RequestFmt.time(req.scheduledTime)}"),
                      ],
                    ),
                  ),
                  if (detail.address != null)
                    _buildSection(
                      expanded: false,
                      title: context.l10n.address,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DetailRow(context.l10n.request_full_location,
                              detail.fullAddress),
                          DetailWidgetRow(
                              context.l10n.request_location,
                              OpenMapAction(
                                  latitude: detail.address!.latitude ?? 0.0,
                                  longitude: detail.address!.longitude ?? 0.0))
                        ],
                      ),
                    ),
                  if (hasNotes)
                    _buildSection(
                      expanded: false,
                      title: context.l10n.request_card_notes,
                      child: Text(detail.specialNotes!,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // Header with edit/close button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.assigned_team,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isEditingWorkers ? Icons.close : Icons.edit,
                                ),
                                onPressed: _toggleEditWorkers,
                              ),
                            ],
                          ),
                        ),

                        // Body: preview or “no workers” when not editing
                        if (!_isEditingWorkers) ...[
                          if (_currentRequest.assignedWorker?.isNotEmpty ??
                              false)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 12,
                                children: _currentRequest.assignedWorker!
                                    .map((w) => _buildWorkerAvatar(w, true))
                                    .toList(),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  context.l10n.no_team_assigned,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                        ] else ...[
                          // Editable picker when in edit mode
                          if (_isFilteringWorkers)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _allWorkers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (ctx, i) {
                                final w = _allWorkers[i];
                                final sel = _selectedWorkerIds.contains(w.id);
                                final canToggle = sel ||
                                    _selectedWorkerIds.length <
                                        detail.cleanersCount;
                                return Opacity(
                                  opacity: canToggle ? 1 : 0.4,
                                  child: GestureDetector(
                                    onTap: canToggle
                                        ? () {
                                            if (w.id == null) return;
                                            if (sel) {
                                              setState(() {
                                                _selectedWorkerIds.remove(w.id);
                                              });
                                              return;
                                            }
                                            setState(() {
                                              _selectedWorkerIds.add(w.id!);
                                            });
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: _buildWorkerAvatar(
                                        w,
                                        sel,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Save / Cancel buttons
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _toggleEditWorkers,
                                    child: Text(context.l10n.general_cancel),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _selectedWorkerIds.length !=
                                            detail.cleanersCount
                                        ? null
                                        : _saveWorkers,
                                    child: Text(
                                        '${context.l10n.general_save} (${_selectedWorkerIds.length}/${detail.cleanersCount})'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // bottomNavigationBar: req.requestStatus != RequestStatus.completed &&
          //         req.requestStatus != RequestStatus.cancelled
          //     ? Padding(
          //         padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          //         child: FilledButton(
          //           onPressed: () {
          //             if (req.requestStatus == RequestStatus.confirmed) {
          //               ctx
          //                   .read<JobActionsBloc>()
          //                   .add(StartJobEvent(req.id ?? ""));
          //             } else if (req.requestStatus ==
          //                 RequestStatus.inProgress) {
          //               ctx
          //                   .read<JobActionsBloc>()
          //                   .add(CompleteJobEvent(req.id ?? "", null));
          //             }
          //           },
          //           child: Text(
          //             req.requestStatus == RequestStatus.confirmed
          //                 ? context.l10n.start_job
          //                 : req.requestStatus == RequestStatus.inProgress
          //                     ? context.l10n.complete_job
          //                     : 'OK',
          //           ),
          //         ),
          //       )
          //     : SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildWorkerAvatar(dynamic w, bool selected) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  selected ? Colors.blue.shade100 : Colors.grey.shade200,
              backgroundImage: (w.image?.isNotEmpty ?? false)
                  ? NetworkImage(w.image!)
                  : null,
              child: (w.image?.isEmpty ?? true)
                  ? Text(
                      w.username![0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            if (selected)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            w.username ?? '',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Helper to build one expandable section
  Widget _buildSection(
      {required String title, required Widget child, required bool expanded}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          title: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
