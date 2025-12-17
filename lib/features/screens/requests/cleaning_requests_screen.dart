import 'dart:async';

import 'package:cleaning_service_driver/components/cleaning_job_card.dart';
import 'package:cleaning_service_driver/components/deep_cleaning_request_card.dart';
import 'package:cleaning_service_driver/components/upholstery_cleaning_request_card.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _scrollCtrl = ScrollController();
  late Timer _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    context.read<RequestsBloc>().add(FetchFirstPageRequests());
    context.read<RequestsBloc>().add(FetchExclusivesFirstPageRequests());

    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) {
        // only dispatch if this page is still the top route
        if (!mounted) return;
        final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
        if (isVisible) {
          context.read<RequestsBloc>().add(FetchFirstPageRequests());
          context.read<RequestsBloc>().add(FetchExclusivesFirstPageRequests());
        }
      },
    );

    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      final cur = _scrollCtrl.position.pixels;
      if (cur >= max - 200) {
        context.read<RequestsBloc>().add(FetchNextPageRequests());
        context.read<RequestsBloc>().add(FetchExclusivesNextPageRequests());
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer.cancel();
    _tabs.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<RequestsBloc>().add(FetchFirstPageRequests());
                context
                    .read<RequestsBloc>()
                    .add(FetchExclusivesFirstPageRequests());
              }),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
              child: Text(
                context.l10n.requests_all_requests,
                style: TextStyle(color: AppTheme.cream),
              ),
            ),
            Tab(
                child: Text(context.l10n.requests_deep_cleaning,
                    style: TextStyle(color: AppTheme.cream))),
          ],
        ),
      ),
      body: BlocConsumer<RequestsBloc, RequestsState>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          if (state is RequestsFailed) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontal = isWide ? 16.0 : 0.0;
            final maxWidth = isWide ? 1100.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _buildPaginatedList(
                        state.all,
                        hasMore: state.hasMoreAll,
                        isLoading: state.isLoadingAll,
                        onLoadMore: () => context
                            .read<RequestsBloc>()
                            .add(FetchNextPageRequests()),
                      ),
                      _buildPaginatedList(
                        state.exclusive,
                        hasMore: state.hasMoreExclusive,
                        isLoading: state.isLoadingExclusive,
                        onLoadMore: () => context
                            .read<RequestsBloc>()
                            .add(FetchExclusivesNextPageRequests()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildPaginatedList(List<CleaningRequest> items,
      {required bool hasMore,
      required bool isLoading,
      required VoidCallback onLoadMore}) {
    if (items.isEmpty) {
      return Center(child: Text(context.l10n.requests_no_requests));
    }

    // show an extra slot when more pages exist
    final count = hasMore ? items.length + 1 : items.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
            !isLoading &&
            hasMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: count,
        itemBuilder: (ctx, idx) {
          if (idx < items.length) {
            final req = items[idx];
            return _ExpandableRequestItem(
              request: req,
              summaryLabel: _summaryLabel(req, context),
              summaryDate: DateFormat.MMMd().add_jm().format(req.scheduledTime),
              summaryPrice: req.type?.toLowerCase() == "housecleaning"
                  ? '${req.totalPrice.toStringAsFixed(3)} KWD'
                  : "",
              pillColor: _pillColorFor(req),
              child: _buildRequestCard(context, req),
            );
          } else {
            // loading indicator at bottom
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

Widget _buildRequestCard(BuildContext context, CleaningRequest req) {
  final type = req.type?.toLowerCase() ?? '';
  if (type == 'deepcleaning') {
    return InkWell(
      onTap: () => context.goNamed('deepCleaning', extra: req),
      child: DeepCleaningRequestCard(
        request: req as DeepCleaningHistory,
        onSubmitBid: () {
          context.goNamed('deepCleaning', extra: req);
        },
      ),
    );
  }
  if (type == 'upholsterycleaning') {
    return InkWell(
      onTap: () => context.goNamed('upholsteryCleaning', extra: req),
      child: UpholsteryCleaningRequestCard(
        request: req as UpholsteryCleaningHistory,
        onSubmitBid: () {
          context.goNamed('upholsteryCleaning', extra: req);
        },
      ),
    );
  }
  return InkWell(
    onTap: () {
      context.goNamed('houseKeeping', extra: req);
    },
    child: CleaningJobCard(
      request: req as HouseKeepingHistory,
      onAccept: () {
        context.goNamed('houseKeeping', extra: req);
      },
    ),
  );
}

String _summaryLabel(CleaningRequest req, BuildContext context) {
  final t = (req.type ?? '').toLowerCase();
  if (t == 'deepcleaning') return context.l10n.deepCleaning;
  if (t == 'upholsterycleaning') return context.l10n.upholstery_cleaning;
  if (t == 'housecleaning') return context.l10n.houseKeeping;
  return req.type ?? '';
}

Color _pillColorFor(CleaningRequest req) {
  final t = (req.type ?? '').toLowerCase();
  if (t == 'deepcleaning') return AppTheme.primary;
  if (t == 'upholsterycleaning') return const Color(0xFF8E44AD);
  if (t == 'housecleaning') return const Color(0xFF2E8B57);
  return AppTheme.accent;
}

class _ExpandableRequestItem extends StatefulWidget {
  final CleaningRequest request;
  final Widget child;
  final String summaryLabel;
  final String summaryDate;
  final String summaryPrice;
  final Color pillColor;

  const _ExpandableRequestItem({
    required this.request,
    required this.child,
    required this.summaryLabel,
    required this.summaryDate,
    required this.summaryPrice,
    required this.pillColor,
  });

  @override
  State<_ExpandableRequestItem> createState() => _ExpandableRequestItemState();
}

class _ExpandableRequestItemState extends State<_ExpandableRequestItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Align(
              alignment: Alignment.centerLeft,
              child: _pill(widget.summaryLabel, widget.pillColor),
            ),
            subtitle: Text(widget.summaryDate),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.summaryPrice,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
              child: widget.child,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      );
}
