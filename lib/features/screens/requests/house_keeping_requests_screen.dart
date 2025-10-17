import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:cleaning_service_driver/data/models/requests/accept_house_keeping_model.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<RequestsActionBloc>().add(FetchWorkersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestsActionBloc, RequestsActionState>(
      listener: (ctx, state) {
        if (state is RequestsActionFailed) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is HouseKeepingRequestObtained) {
          context.goNamed('houseKeepingSuccess', extra: state.request);
        } else if (state is WorkersFetchedState) {
          _workers = state.workers;
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.request_details_label)),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: [
                _title(context.l10n.request_details_label),
                DetailRow(context.l10n.request_price,
                    RequestFmt.price(widget.request.totalPrice)),
                const Divider(),
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
                      final canSelect = isSelected ||
                          _selectedWorkerIds.length <
                              widget.request.detail.cleanersCount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: canSelect
                              ? () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedWorkerIds.remove(w.id);
                                    } else {
                                      _selectedWorkerIds.add(w.id!);
                                    }
                                  });
                                }
                              : null,
                          child: Opacity(
                            opacity: canSelect ? 1.0 : 0.4,
                            child: Column(
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
                                  child: (w.image == null || w.image!.isEmpty)
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
            child: FilledButton(
              onPressed: _selectedWorkerIds.isEmpty
                  ? null
                  : () {
                      context.read<RequestsActionBloc>().add(
                            ObtainHouseKeepingRequest(
                              requestId: widget.request.id ?? "",
                              acceptHouseKeepingModel: AcceptHouseKeepingModel(
                                  cleanerIds: _selectedWorkerIds.toList()),
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
}
