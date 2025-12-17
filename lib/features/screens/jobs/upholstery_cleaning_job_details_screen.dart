import 'package:cleaning_service_driver/components/cleaning_item_summary_card.dart';
import 'package:cleaning_service_driver/components/media_carousel_viewer.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
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

class UpholsteryCleaningJobDetailsScreen extends StatefulWidget {
  final UpholsteryCleaningHistory request;
  const UpholsteryCleaningJobDetailsScreen({super.key, required this.request});

  @override
  State<UpholsteryCleaningJobDetailsScreen> createState() =>
      _UpholsteryCleaningJobDetailsState();
}

class _UpholsteryCleaningJobDetailsState
    extends State<UpholsteryCleaningJobDetailsScreen> {
  late UpholsteryCleaningHistory _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
  }

  bool _isVideo(String url) {
    final l = url.toLowerCase();
    return l.endsWith('.mp4') ||
        l.endsWith('.mov') ||
        l.endsWith('.mkv') ||
        l.endsWith('.webm') ||
        l.endsWith('.avi');
  }

  Future<void> _openMedia(BuildContext context, List<String> urls,
      {int initialIndex = 0}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) =>
          MediaCarouselViewer(urls: urls, initialIndex: initialIndex),
    );
  }

  Widget _mediaThumb(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isVideo(url)
                ? const ColoredBox(color: Color(0x11000000))
                : Image.network(url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0x11000000))),
          ),
          if (_isVideo(url))
            const Center(
              child:
                  Icon(Icons.play_circle_fill, size: 42, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = _currentRequest;
    final items = req.upholsteryCleaning.items ?? const [];
    final status = req.requestStatus;
    final isConfirmed = status == RequestStatus.confirmed;
    final isInProgress = status == RequestStatus.inProgress;

    return BlocConsumer<JobActionsBloc, JobActionsState>(
      listener: (ctx, state) {
        if (state is JobActionFailed) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(ctx.genericErrorMessage)));
        } else if (state is JobStarted) {
          setState(() => _currentRequest = state.model as UpholsteryCleaningHistory);
          context.read<JobBloc>().add(LoadJobsEvent());
          _maybeRefreshRequests();
        } else if (state is JobCompleted) {
          setState(() => _currentRequest = state.model as UpholsteryCleaningHistory);
          context.read<JobBloc>().add(LoadJobsEvent());
          _maybeRefreshRequests();
          context.pop();
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(title: Text('#${req.id}')),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      req.requestStatus.displayText(context),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: statusColor(req.requestStatus),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
                const SizedBox(height: 12),
                if (items.any((i) => (i.mediaUrls?.isNotEmpty ?? false)))
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items
                          .where((i) => (i.mediaUrls?.isNotEmpty ?? false))
                          .length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, idx) {
                        final mediaItem = items
                            .where((i) => (i.mediaUrls?.isNotEmpty ?? false))
                            .toList()[idx];
                        final urls = mediaItem.mediaUrls!;
                        return GestureDetector(
                          onTap: () => _openMedia(context, urls, initialIndex: 0),
                          child: SizedBox(
                            width: 260,
                            height: 160,
                            child: _mediaThumb(urls.first),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                _title(context.l10n.job_details),
                ...items.map((it) {
                  final typeTitle =
                      it.type?.title ?? it.type?.titleEn ?? it.type?.titleAr ?? '';
                  final qty = it.quantity ?? 0;
                  final size = it.size?.title ?? '-';
                  final material = it.material?.title ?? '-';
                  final condition = it.condition?.title ?? '-';
                  final mediaUrls = (it.mediaUrls ?? [])
                      .where((u) => u.startsWith('http'))
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CleaningItemSummaryCard(
                      icon: _iconForTitle(typeTitle),
                      title: qty > 0 ? '$typeTitle x$qty' : typeTitle,
                      size: size,
                      material: material,
                      condition: condition,
                      mediaGallery: mediaUrls.isEmpty
                          ? null
                          : SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: mediaUrls.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, i) {
                                  final url = mediaUrls[i];
                                  return GestureDetector(
                                    onTap: () => _openMedia(context, mediaUrls,
                                        initialIndex: i),
                                    child: SizedBox(
                                      width: 220,
                                      child: _mediaThumb(url),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                _title(context.l10n.request_card_schedule),
                Text(
                    DateFormat.yMMMd().add_jm().format(
                          req.scheduledTime,
                        ),
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                _title(context.l10n.address),
                Text(req.customer.addresses?.first.area ?? '—',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: FilledButton(
                onPressed: isConfirmed
                    ? () => ctx
                        .read<JobActionsBloc>()
                        .add(StartJobEvent(_currentRequest.id))
                    : isInProgress
                        ? () => ctx
                            .read<JobActionsBloc>()
                            .add(CompleteJobEvent(_currentRequest.id, null))
                        : null,
              child: Text(isConfirmed
                  ? context.l10n.start_job
                  : isInProgress
                      ? context.l10n.complete_job
                      : context.l10n.complete_job),
            ),
          ),
        );
      },
    );
  }

  void _maybeRefreshRequests() {
    try {
      context
          .read<RequestsBloc>()
          .add(requests_events.FetchFirstPageRequests());
    } catch (_) {}
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      );

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('sofa') || t.contains('couch') || t.contains('صوفا')) {
      return Icons.chair_outlined;
    }
    if (t.contains('arm') || t.contains('chair')) {
      return Icons.event_seat_outlined;
    }
    if (t.contains('carpet') || t.contains('rug') || t.contains('سج')) {
      return Icons.crop_16_9_outlined;
    }
    if (t.contains('mattress') || t.contains('مرتبة')) {
      return Icons.king_bed_outlined;
    }
    return Icons.local_laundry_service_outlined;
  }
}
