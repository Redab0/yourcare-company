import 'dart:io';

import 'package:cleaning_service_driver/components/cleaning_item_summary_card.dart';
import 'package:cleaning_service_driver/components/media_carousel_viewer.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/complete_job_media_request.dart';
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
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

enum _MediaChoice { gallery, cameraPhoto, cameraVideo }

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

  List<File> uploadedFiles = [];
  List<String> uploadedFilesUrls = [];
  static const int _maxMedia = 10;
  final ImagePicker _picker = ImagePicker();

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
    final name = req.customer.username?.trim();
    final phone = req.customer.phone?.trim();
    final lat = req.upholsteryCleaning.address?.latitude;
    final lng = req.upholsteryCleaning.address?.longitude;
    final mapUrl = (lat != null && lng != null)
        ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        : null;
    final items = req.upholsteryCleaning.items ?? const [];
    final itemLines = items.map((it) {
      final typeTitle = it.type?.title ?? it.type?.titleEn ?? it.type?.titleAr ?? '-';
      final qty = it.quantity ?? 0;
      return '- $typeTitle x$qty';
    }).toList();

    final lines = <String>[
      '==============================',
      'Upholstery Cleaning / تنظيف المفروشات',
      '==============================',
      '',
      '--- Request / الطلب ---',
      'Request ID / رقم الطلب: ${req.id ?? '-'}',
      'Request Status / حالة الطلب: ${_statusPair(req.requestStatus)}',
      'Date and Time / الوقت والتاريخ: ${RequestFmt.date(req.scheduledTime)} ${RequestFmt.time(req.scheduledTime)}',
      'Address / العنوان: ${req.upholsteryCleaning.fullAddress}',
      '',
      '--- Customer / العميل ---',
      'Customer Name / اسم العميل: ${(name == null || name.isEmpty) ? '-' : name}',
      'Customer Phone / رقم العميل: ${(phone == null || phone.isEmpty) ? '-' : phone}',
      '',
      '--- Location / الموقع ---',
      'Google Maps: ${mapUrl ?? '-'}',
      '',
      '--- Job Details / تفاصيل الطلب ---',
      'Job Details / تفاصيل الطلب',
      ...itemLines,
    ];
    await Share.share(lines.join('\n'));
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
        if (state is MediaUploaded) {
          final urls = state.media.map((r) => r.url).toList();
          setState(() {
            uploadedFilesUrls.addAll(urls);
            if (uploadedFilesUrls.length > 10) {
              uploadedFilesUrls.removeRange(10, uploadedFilesUrls.length);
            }
          });
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Added ${urls.length} item(s)')),
          );
        } else if (state is JobActionFailed) {
          ctx.showErrorToast();
        } else if (state is JobStarted) {
          setState(
              () => _currentRequest = state.model as UpholsteryCleaningHistory);
          context.read<JobBloc>().add(LoadJobsEvent());
          _maybeRefreshRequests();
        } else if (state is JobCompleted) {
          setState(
              () => _currentRequest = state.model as UpholsteryCleaningHistory);
          context.read<JobBloc>().add(LoadJobsEvent());
          _maybeRefreshRequests();
          context.goNamed('jobCompletedSuccessScreen');
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('#${req.id}'),
            actions: [
              IconButton(
                onPressed: _shareDetails,
                icon: const Icon(Icons.share),
              ),
            ],
          ),
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
                          onTap: () =>
                              _openMedia(context, urls, initialIndex: 0),
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
                  final typeTitle = it.type?.title ??
                      it.type?.titleEn ??
                      it.type?.titleAr ??
                      '';
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
                    req.scheduledTime == null
                        ? context.l10n.as_soon_as_possible
                        : DateFormat.yMMMd(
                                Localizations.localeOf(context).toLanguageTag())
                            .format(
                            req.scheduledTime!,
                          ),
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                _title(context.l10n.address),
                Text(req.upholsteryCleaning.address?.area ?? '—',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 80),
                if (_currentRequest.requestStatus == RequestStatus.inProgress)
                  _media(context),
              ],
            ),
          ),
          bottomNavigationBar: (_currentRequest.requestStatus !=
                      RequestStatus.completed &&
                  _currentRequest.requestStatus != RequestStatus.cancelled)
              ? Builder(
                  builder: (context) {
                    // Optional: also disable while uploading
                    final isUploading = context.select<JobActionsBloc, bool>(
                      (bloc) => bloc.state is MediaUploading,
                    );

                    final rs = _currentRequest.requestStatus;
                    final isConfirmed = rs == RequestStatus.confirmed;
                    final isInProgress = rs == RequestStatus.inProgress;

                    // Disable "Complete Job" when in-progress and no media uploaded
                    final canCompleteNow = isInProgress &&
                        uploadedFilesUrls.isNotEmpty &&
                        !isUploading;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: FilledButton(
                        onPressed: isConfirmed
                            ? () {
                                context.read<JobActionsBloc>().add(
                                      StartJobEvent(_currentRequest.id ?? ""),
                                    );
                                // Confirmed -> prompt to attach media (start job flow)
                              }
                            : (isInProgress && canCompleteNow
                                ? () {
                                    // In progress + has media -> complete
                                    final body = CompleteJobRequest(
                                      files:
                                          List<String>.from(uploadedFilesUrls),
                                    );
                                    context.read<JobActionsBloc>().add(
                                          CompleteJobEvent(
                                              _currentRequest.id ?? "", body),
                                        );
                                  }
                                : null), // disabled if no media (or uploading)
                        child: Text(
                          isConfirmed
                              ? context.l10n.start_job
                              : isInProgress
                                  ? context.l10n.complete_job
                                  : 'OK',
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
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
    if (t.contains('curtain') || t.contains('ستارة')) {
      return Icons.window_outlined;
    }
    return Icons.local_laundry_service_outlined;
  }

  bool _picking = false; // in your State

  Future<void> _showAddMediaChooser() async {
    if (_picking) return;
    _picking = true;

    // 1) Present on the ROOT navigator
    final choice = await showModalBottomSheet<_MediaChoice>(
      context: context,
      useRootNavigator: true, // <-- important when using nested navigators
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 12,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from gallery'),
                subtitle: const Text('Images and videos'),
                onTap: () => Navigator.pop(sheetContext,
                    _MediaChoice.gallery), // 2) pop with sheetContext
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () =>
                    Navigator.pop(sheetContext, _MediaChoice.cameraPhoto),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record video'),
                onTap: () =>
                    Navigator.pop(sheetContext, _MediaChoice.cameraVideo),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || choice == null) {
      _picking = false;
      return;
    }

    // 3) Act AFTER sheet resolves (no post-frame, no delay)
    try {
      switch (choice) {
        case _MediaChoice.gallery:
          await _pickFromGallery();
          break;
        case _MediaChoice.cameraPhoto:
          await _capturePhoto();
          break;
        case _MediaChoice.cameraVideo:
          await _captureVideo();
          break;
      }
    } finally {
      _picking = false; // 4) throttle reset
    }
  }

  Future<void> _pickFromGallery() async {
    final remaining = _maxMedia - uploadedFilesUrls.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Max 10 items reached')));
      return;
    }
    final media = await _picker.pickMultipleMedia(); // List<XFile>
    if (media.isEmpty) return;
    final files = media.take(remaining).map((x) => File(x.path)).toList();
    if (media.length > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Only $remaining more item(s) allowed')));
    }
    context.read<JobActionsBloc>().add(UploadMediaEvent(files));
  }

  Future<void> _capturePhoto() async {
    final remaining = _maxMedia - uploadedFilesUrls.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Max 10 items reached')));
      return;
    }
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return;
    context.read<JobActionsBloc>().add(UploadMediaEvent([File(x.path)]));
  }

  Future<void> _captureVideo() async {
    final remaining = _maxMedia - uploadedFilesUrls.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Max 10 items reached')));
      return;
    }
    final x = await _picker.pickVideo(source: ImageSource.camera);
    if (x == null) return;
    context.read<JobActionsBloc>().add(UploadMediaEvent([File(x.path)]));
  }

  bool _isVideoUrl(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.contains('video');
  }

  Widget _media(BuildContext context) {
    final canAdd = uploadedFilesUrls.length < _maxMedia;
    final itemCount = uploadedFilesUrls.length + (canAdd ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Work Media',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text(
              '${uploadedFilesUrls.length}/$_maxMedia',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            IconButton(
              tooltip: context.l10n.gallery,
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
            ),
            IconButton(
              tooltip: context.l10n.camera,
              onPressed: _showAddMediaChooser,
              icon: const Icon(Icons.photo_camera),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: itemCount,
          itemBuilder: (context, i) {
            // Add tile
            if (canAdd && i == itemCount - 1) {
              return InkWell(
                onTap: _showAddMediaChooser,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(height: 4),
                        Text('Add media'),
                      ],
                    ),
                  ),
                ),
              );
            }

            final url = uploadedFilesUrls[i];
            final isVideo = _isVideoUrl(url);

            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isVideo
                      ? Container(
                          color: Colors.black12,
                          child: const Center(
                              child: Icon(Icons.videocam, size: 36)),
                        )
                      : Image.network(url, fit: BoxFit.cover),
                ),
                if (isVideo)
                  const Positioned(
                    left: 6,
                    bottom: 6,
                    child: _VideoBadge(),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => setState(() => uploadedFilesUrls.removeAt(i)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _VideoBadge extends StatelessWidget {
  const _VideoBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Icon(Icons.videocam, size: 14, color: Colors.white),
      ),
    );
  }
}
