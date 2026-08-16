import 'dart:async';

import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/cleaning_job_card.dart';
import 'package:cleaning_service_driver/components/deep_cleaning_request_card.dart';
import 'package:cleaning_service_driver/components/shimmer_box.dart';
import 'package:cleaning_service_driver/components/upholstery_cleaning_request_card.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const _tourScope = 'business_requests_journey';
  final _requestsTourKey = GlobalKey(debugLabel: 'requests-list-tour');
  final _scrollCtrl = ScrollController();
  late final BusinessShowcaseTourController _tour;
  late Timer _autoRefreshTimer;
  bool _hidePriceForWorker = false;

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    SecureStorageService().getUser().then((user) {
      final ownerId = businessShowcaseOwnerId(user);
      if (ownerId == null) return;
      _tour.scheduleStartOnce(
        ownerId: ownerId,
        journeyId: 'requests',
        keys: [_requestsTourKey],
      );
    });
    _loadRole();
    context.read<RequestsBloc>().add(FetchFirstPageRequests());

    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) {
        // only dispatch if this page is still the top route
        if (!mounted) return;
        final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
        if (isVisible) {
          context.read<RequestsBloc>().add(FetchFirstPageRequests());
        }
      },
    );

    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      final cur = _scrollCtrl.position.pixels;
      if (cur >= max - 200) {
        context.read<RequestsBloc>().add(FetchNextPageRequests());
      }
    });
  }

  Future<void> _loadRole() async {
    final user = await SecureStorageService().getUser();
    if (!mounted) return;
    setState(() {
      _hidePriceForWorker = user?.role?.toLowerCase() == 'worker';
    });
  }

  @override
  void dispose() {
    _tour.dispose();
    _autoRefreshTimer.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(fallbackRouteName: 'home'),
        title: Text(context.l10n.requests_all_requests),
        actions: [
          BusinessShowcaseHelpButton(
            onPressed: () => _tour.start([_requestsTourKey]),
          ),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<RequestsBloc>().add(FetchFirstPageRequests());
              }),
        ],
      ),
      body: BlocConsumer<RequestsBloc, RequestsState>(
        listener: (ctx, state) {
          if (state is RequestsFailed || state.error != null) {
            ctx.showErrorToast();
          }
        },
        builder: (ctx, state) {
          if (state is RequestsFailed || state.error != null) {
            return Center(child: Text(ctx.genericErrorMessage));
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
                  child: BusinessShowcaseStep(
                    showcaseKey: _requestsTourKey,
                    scope: _tourScope,
                    title: context.l10n.requests_all_requests,
                    description: context.l10n.business_inner_tour_requests,
                    index: 0,
                    itemCount: 1,
                    child: _buildPaginatedList(
                      state.all,
                      hasMore: state.hasMoreAll,
                      isLoading: state.isLoadingAll,
                      onLoadMore: () => context
                          .read<RequestsBloc>()
                          .add(FetchNextPageRequests()),
                      hidePriceForWorker: _hidePriceForWorker,
                    ),
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
      required bool hidePriceForWorker,
      required VoidCallback onLoadMore}) {
    if (items.isEmpty) {
      if (isLoading) {
        return _buildRequestsShimmer();
      }
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
              area: _areaForRequest(req),
              summaryLabel: _summaryLabel(req, context),
              summaryDate: req.showsScheduleInBusinessApp
                  ? req.scheduledTime == null
                      ? context.l10n.as_soon_as_possible
                      : req.type == 'houseCleaning'
                          ? DateFormat.yMMMd(Localizations.localeOf(context)
                                  .toLanguageTag())
                              .add_jm()
                              .format(req.scheduledTime!)
                          : DateFormat.yMMMd(Localizations.localeOf(context)
                                  .toLanguageTag())
                              .format(req.scheduledTime!)
                  : null,
              summaryPrice: "",
              pillColor: _pillColorFor(req),
              child: _buildRequestCard(
                context,
                req,
                hidePriceForWorker: hidePriceForWorker,
              ),
            );
          } else {
            // loading indicator at bottom
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildRequestsShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (ctx, idx) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(height: 16, width: 140),
                SizedBox(height: 10),
                ShimmerBox(height: 12, width: 220),
                SizedBox(height: 6),
                ShimmerBox(height: 12, width: 180),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildRequestCard(
  BuildContext context,
  CleaningRequest req, {
  required bool hidePriceForWorker,
}) {
  final type = req.type?.toLowerCase() ?? '';
  if (type == 'deepcleaning') {
    return InkWell(
      onTap: () => context.pushNamed('deepCleaning', extra: req),
      child: DeepCleaningRequestCard(
        request: req as DeepCleaningHistory,
        padding: EdgeInsets.zero,
        onSubmitBid: () {
          context.pushNamed('deepCleaning', extra: req);
        },
      ),
    );
  }
  if (type == 'upholsterycleaning') {
    return InkWell(
      onTap: () => context.pushNamed('upholsteryCleaning', extra: req),
      child: UpholsteryCleaningRequestCard(
        request: req as UpholsteryCleaningHistory,
        padding: EdgeInsets.zero,
        onSubmitBid: () {
          context.pushNamed('upholsteryCleaning', extra: req);
        },
      ),
    );
  }
  return InkWell(
    onTap: () {
      context.pushNamed('houseKeeping', extra: req);
    },
    child: CleaningJobCard(
      request: req as HouseKeepingHistory,
      padding: EdgeInsets.zero,
      hidePrice: hidePriceForWorker,
      onAccept: () {
        context.pushNamed('houseKeeping', extra: req);
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

String _areaForRequest(CleaningRequest req) {
  if (req is DeepCleaningHistory) {
    return req.detail.address?.area ?? req.detail.area ?? '—';
  }
  if (req is UpholsteryCleaningHistory) {
    return req.upholsteryCleaning.address?.area ?? '—';
  }
  if (req is HouseKeepingHistory) {
    return req.detail.address?.area ?? req.detail.area ?? '—';
  }
  return '—';
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
  final String? summaryDate;
  final String summaryPrice;
  final String area;
  final Color pillColor;

  const _ExpandableRequestItem({
    required this.request,
    required this.child,
    required this.summaryLabel,
    this.summaryDate,
    required this.summaryPrice,
    required this.pillColor,
    required this.area,
  });

  @override
  State<_ExpandableRequestItem> createState() => _ExpandableRequestItemState();
}

class _ExpandableRequestItemState extends State<_ExpandableRequestItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasSubmittedBid = (widget.request is DeepCleaningHistory &&
            (widget.request as DeepCleaningHistory).myBid != null) ||
        (widget.request is UpholsteryCleaningHistory &&
            (widget.request as UpholsteryCleaningHistory).myBid != null);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _pill(widget.summaryLabel, widget.pillColor),
                          const Spacer(),
                          if (hasSubmittedBid)
                            _bidPill(context.l10n.bid_submitted),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        textAlign: TextAlign.start,
                        widget.area,
                        overflow: TextOverflow.ellipsis,
                        style: TextTheme.of(context).titleMedium,
                      ),
                      if (widget.summaryDate?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.summaryDate!,
                          textAlign: TextAlign.end,
                          style: TextTheme.of(context).titleMedium,
                        ),
                      ],
                      const SizedBox(height: 4),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(
                              left: 4, right: 4, bottom: 12),
                          child: widget.child,
                        ),
                        crossFadeState: _expanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 180),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
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
                color: color, fontWeight: FontWeight.w900, fontSize: 15)),
      );

  Widget _bidPill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2979FF).withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2979FF),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
}
