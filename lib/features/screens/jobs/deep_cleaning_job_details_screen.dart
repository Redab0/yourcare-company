import 'package:cleaning_service_driver/components/contact_actions.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/open_map_action.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeepCleaningJobDetailsScreen extends StatefulWidget {
  final DeepCleaningHistory request;
  DeepCleaningJobDetailsScreen({super.key, required this.request});

  @override
  State<DeepCleaningJobDetailsScreen> createState() =>
      _DeepCleaningJobDetailsState();
}

class _DeepCleaningJobDetailsState extends State<DeepCleaningJobDetailsScreen> {
  bool _isEditingTeams = false;
  List<TeamModel> _allTeams = [];
  String _selectedTeamId = "";
  late DeepCleaningHistory _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
    _selectedTeamId = _currentRequest.assignedTeam?.id ?? "";
  }

  void _toggleEditTeam() {
    if (!_isEditingTeams) {
      // first time: fetch the full workers list
      context.read<JobActionsBloc>().add(FetchTeamsEvent());
    }
    setState(() => _isEditingTeams = !_isEditingTeams);
  }

  void _saveTeam() {
    context.read<JobActionsBloc>().add(
          AssignTeamEvent(_currentRequest.id ?? "", _selectedTeamId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.request.detail;
    final hasNotes =
        (widget.request.detail.additionalInformation?.trim().isNotEmpty ??
            false);
    // final hasWorkers = (widget.request.?.isNotEmpty ?? false);
    return BlocConsumer<JobActionsBloc, JobActionsState>(
      listener: (ctx, state) {
        if (state is OfferSubmitted) {
          context.goNamed('deepCleaningSuccess');
        } else if (state is JobActionFailed) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is TeamsFetchedState) {
          // <-- Add this:
          setState(() {
            _allTeams = state.teams;
            // if you want to auto-enter edit mode you could:
            // _isEditingTeams = true;
          });
        } else if (state is TeamAssigned) {
          _isEditingTeams = false;
          // refresh the request’s assignedWorker list
          _currentRequest = (state.model as DeepCleaningHistory);
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(title: Text('#${widget.request.id}')),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (d.photosAndVideos?.isNotEmpty ?? false)
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: d.photosAndVideos!.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            d.photosAndVideos![i],
                            width: 260,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
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
                          DetailRow(context.l10n.request_card_bedroom,
                              d.bedrooms.toString()),
                          const Divider(),
                          DetailRow(context.l10n.request_card_bathroom,
                              d.bathrooms.toString()),
                          const Divider(),
                          DetailRow(context.l10n.request_card_kitchen,
                              d.kitchens.toString()),
                          const Divider(),
                          DetailRow(context.l10n.request_card_livingroom,
                              d.livingRooms.toString()),
                          const SizedBox(height: 32),
                        ],
                      )),
                  _buildSection(
                      expanded: false,
                      title: context.l10n.request_card_schedule,
                      child: Column(
                        children: [
                          DetailRow(context.l10n.request_date_time,
                              "${RequestFmt.date(d.scheduledTime)}  ${RequestFmt.time(d.scheduledTime)}"),
                        ],
                      )),
                  if (d.address != null)
                    _buildSection(
                      expanded: false,
                      title: context.l10n.address,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DetailRow(context.l10n.request_full_location,
                              d.fullAddress),
                          DetailWidgetRow(
                              context.l10n.request_location,
                              OpenMapAction(
                                  latitude: d.address!.latitude!,
                                  longitude: d.address!.latitude!))
                        ],
                      ),
                    ),
                  if (hasNotes)
                    _buildSection(
                      expanded: false,
                      title: context.l10n.request_card_notes,
                      child: Text(d.additionalInformation!,
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
                                    _isEditingTeams ? Icons.close : Icons.edit),
                                onPressed: _toggleEditTeam,
                              ),
                            ],
                          ),
                        ),

                        // Preview mode
                        if (!_isEditingTeams) ...[
                          if (_currentRequest.assignedTeam != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.group,
                                            size: 24, color: Colors.black54),
                                        const SizedBox(height: 4),
                                        Text(
                                          _currentRequest.assignedTeam!.name ??
                                              "",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _currentRequest.assignedTeam!.name ?? "",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
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
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                        ] else ...[
                          // Edit mode: pick one team from the list
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _allTeams.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (ctx, i) {
                                final team = _allTeams[i];
                                final isSel = _selectedTeamId == team.id;
                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedTeamId = team.id!),
                                  child: Column(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: isSel
                                                ? Colors.blue.shade100
                                                : Colors.grey.shade200,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.group,
                                                    size: 24,
                                                    color: Colors.black54),
                                                const SizedBox(height: 4),
                                              ],
                                            ),
                                          ),
                                          if (isSel)
                                            const Positioned(
                                              top: -2,
                                              left: -2,
                                              child: Icon(Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          team.name!,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.visible,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
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
                                    onPressed: _toggleEditTeam,
                                    child: Text(context.l10n.general_cancel),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _selectedTeamId.isEmpty
                                        ? null
                                        : _saveTeam,
                                    child: Text(context.l10n.general_save),
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
                // Could pop up a dialog to enter an amount.
                context.read<JobActionsBloc>().add(
                      StartJobEvent(widget.request.id ?? ""),
                    );
              },
              child: const Text('Start Job'),
            ),
          ),
        );
      },
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

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      );
}
