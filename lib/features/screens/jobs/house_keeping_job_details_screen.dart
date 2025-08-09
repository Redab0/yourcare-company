import 'package:cleaning_service_driver/components/contact_actions.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/open_map_action.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HouseKeepingJobDetails extends StatefulWidget {
  const HouseKeepingJobDetails({super.key, required this.request});
  final HouseKeepingHistory request;

  @override
  State<HouseKeepingJobDetails> createState() => _HouseKeepingJobDetailsState();
}

class _HouseKeepingJobDetailsState extends State<HouseKeepingJobDetails> {
  bool _isEditingWorkers = false;
  List<User> _allWorkers = [];
  final Set<String> _selectedWorkerIds = {};
  late HouseKeepingHistory _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
    _selectedWorkerIds.clear();
    _currentRequest.assignedWorker
        ?.forEach((w) => _selectedWorkerIds.add(w.id));
  }

  void _toggleEditWorkers() {
    if (!_isEditingWorkers) {
      // first time: fetch the full workers list
      context.read<JobActionsBloc>().add(FetchWorkersEvent());
    }
    setState(() => _isEditingWorkers = !_isEditingWorkers);
  }

  void _saveWorkers() {
    context.read<JobActionsBloc>().add(
          AssignWorkersEvent(_currentRequest.id ?? "",
              AcceptHouseKeepingModel(cleanerIds: _selectedWorkerIds.toList())),
        );
  }

  @override
  Widget build(BuildContext context) {
    final req = _currentRequest;
    final detail = req.detail;
    final hasNotes = (detail.specialNotes?.trim().isNotEmpty ?? false);

    return BlocConsumer<JobActionsBloc, JobActionsState>(
      listener: (ctx, state) {
        if (state is WorkersFetchedState && _isEditingWorkers) {
          // store the list once it arrives
          setState(() => _allWorkers = state.workers);
        }
        if (state is JobActionFailed) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is WorkersAssigned) {
          // they just saved successfully
          setState(() {
            _isEditingWorkers = false;
            // refresh the request’s assignedWorker list
            _currentRequest = (state.model as HouseKeepingHistory);
          });
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(title: Text('#${_currentRequest.id}')),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection(
                    title: context.l10n.bids_bottom_sheet_customer_info,
                    child: Column(
                      children: [
                        DetailRow(context.l10n.signup_name,
                            widget.request.customer.username ?? ""),
                        const Divider(),
                        DetailRow(context.l10n.signup_phone,
                            widget.request.customer.phone ?? ""),
                        ContactActions(
                            phoneNumber: widget.request.customer.phone ?? "")
                      ],
                    ),
                    expanded: true,
                  ),
                  _buildSection(
                    expanded: true,
                    title: context.l10n.job_details,
                    child: Column(
                      children: [
                        DetailRow(context.l10n.request_price,
                            RequestFmt.price(req.totalPrice)),
                        const Divider(),
                        DetailRow(context.l10n.request_card_cleaners,
                            RequestFmt.plural(detail.cleanersCount, 'Cleaner')),
                        const Divider(),
                        DetailRow(context.l10n.request_card_duration,
                            RequestFmt.plural(detail.durationHours, 'hour')),
                        const Divider(),
                        DetailRow(context.l10n.requests_cleaning_product_title,
                            RequestFmt.yesNo(detail.productsIncluded)),
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
                                  latitude: detail.address!.latitude!,
                                  longitude: detail.address!.latitude!))
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
                                        ? () => setState(() {
                                              if (sel) {
                                                _selectedWorkerIds.remove(w.id);
                                              } else {
                                                _selectedWorkerIds.add(w.id!);
                                              }
                                            })
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: _buildWorkerAvatar(w, sel),
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
                                    onPressed: _selectedWorkerIds.isEmpty
                                        ? null
                                        : _saveWorkers,
                                    child: Text(
                                        '${context.l10n.general_save} (${_selectedWorkerIds.length})'),
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
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: FilledButton(
              onPressed: () {
                if (req.requestStatus == RequestStatus.confirmed) {
                  ctx.read<JobActionsBloc>().add(StartJobEvent(req.id ?? ""));
                } else if (req.requestStatus == RequestStatus.inProgress) {
                  ctx
                      .read<JobActionsBloc>()
                      .add(CompleteJobEvent(req.id ?? ""));
                }
              },
              child: Text(
                req.requestStatus == RequestStatus.confirmed
                    ? context.l10n.start_job
                    : req.requestStatus == RequestStatus.inProgress
                        ? context.l10n.complete_job
                        : 'OK',
              ),
            ),
          ),
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
