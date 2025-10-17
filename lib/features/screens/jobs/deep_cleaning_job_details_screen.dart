import 'dart:io';

import 'package:cleaning_service_driver/components/contact_actions.dart';
import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/media_carousel_viewer.dart';
import 'package:cleaning_service_driver/components/open_map_action.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/complete_job_media_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  List<File> uploadedFiles = [];
  List<String> uploadedFilesUrls = [];
  static const int _maxMedia = 10;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
    _selectedTeamId = _currentRequest.assignedTeam?.id ?? "";
  }

  void _toggleEditTeam() {
    if (!_isEditingTeams) {
      context.read<JobActionsBloc>().add(FetchTeamsEvent());
    }
    setState(() => _isEditingTeams = !_isEditingTeams);
  }

  void _saveTeam() {
    context.read<JobActionsBloc>().add(
          AssignTeamEvent(_currentRequest.id ?? "", _selectedTeamId),
        );
  }

  Future<void> openMediaCarousel(BuildContext context, List<String> urls,
      {int initialIndex = 0}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) =>
          MediaCarouselViewer(urls: urls, initialIndex: initialIndex),
    );
  }

  Widget _mediaThumb(String url) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Clipped image or placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _isVideoUrl(url)
                  ? const ColoredBox(color: Color(0x11000000))
                  : Image.network(url, fit: BoxFit.cover),
            ),
            if (_isVideoUrl(url))
              const Center(
                child:
                    Icon(Icons.play_circle_fill, size: 42, color: Colors.white),
              ),
          ],
        ),
      ),
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
          setState(() {
            _allTeams = state.teams;
          });
        } else if (state is TeamAssigned) {
          _isEditingTeams = false;
          // refresh the request’s assignedWorker list
          _currentRequest = (state.model as DeepCleaningHistory);
        }
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
                  if ((d.photosAndVideos?.isNotEmpty ?? false))
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: d.photosAndVideos!.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) {
                          final url = d.photosAndVideos![i];
                          return GestureDetector(
                            onTap: () => openMediaCarousel(
                                context, d.photosAndVideos!,
                                initialIndex: i),
                            child: SizedBox(
                                width: 260,
                                height: 160,
                                child: _mediaThumb(url)),
                          );
                        },
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
                  if (widget.request.requestStatus == RequestStatus.inProgress)
                    _media(context),
                ],
              ),
            ),
          ),
          bottomNavigationBar: (widget.request.requestStatus !=
                      RequestStatus.completed &&
                  widget.request.requestStatus != RequestStatus.cancelled)
              ? Builder(
                  builder: (context) {
                    // Optional: also disable while uploading
                    final isUploading = context.select<JobActionsBloc, bool>(
                      (bloc) => bloc.state is MediaUploading,
                    );

                    final rs = widget.request.requestStatus;
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
                                // Confirmed -> prompt to attach media (start job flow)
                                _showAttachFirstSheet(
                                    context, widget.request.id ?? "");
                              }
                            : (canCompleteNow
                                ? () {
                                    // In progress + has media -> complete
                                    final body = CompleteJobRequest(
                                      files:
                                          List<String>.from(uploadedFilesUrls),
                                    );
                                    context.read<JobActionsBloc>().add(
                                          CompleteJobEvent(
                                              widget.request.id ?? "", body),
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

  void _showAttachFirstSheet(BuildContext context, String requestId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add photos/videos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Please attach pictures or videos before completing the job.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add media'),
                    onPressed: () {
                      Navigator.pop(context);
                      _pickFromGallery(); // opens your picker
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Use camera'),
                    onPressed: () {
                      Navigator.pop(context);
                      _cameraSheet(); // camera or video capture chooser
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideoUrl(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.contains('video');
  }

  void _showAddMediaChooser() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 12,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from gallery'),
                subtitle: const Text('Images and videos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Use camera'),
                subtitle: const Text('Photo or video'),
                onTap: () {
                  Navigator.pop(context);
                  _cameraSheet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final remaining = _maxMedia - uploadedFilesUrls.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 10 items reached')),
      );
      return;
    }

    // Prefer pickMultipleMedia (supports images + videos)
    List<XFile> picked = [];
    try {
      final media =
          await _picker.pickMultipleMedia(); // requires image_picker >= 1.0
      picked = media ?? [];
    } catch (_) {
      // Fallback if not supported
      final images = await _picker.pickMultiImage();
      if (images != null) picked.addAll(images);
      // For videos, user would use the camera option or you can add a separate gallery video picker:
      // final video = await _picker.pickVideo(source: ImageSource.gallery);
      // if (video != null) picked.add(video);
    }

    if (picked.isEmpty) return;

    // Enforce remaining cap
    if (picked.length > remaining) {
      picked = picked.take(remaining).toList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only $remaining more item(s) allowed')),
      );
    }

    final files = picked.map((x) => File(x.path)).toList();

    // Dispatch upload (your event takes only List<File>)
    context.read<JobActionsBloc>().add(UploadMediaEvent(files));
  }

  Future<void> _cameraSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 12,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _capturePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record video'),
                onTap: () async {
                  Navigator.pop(context);
                  await _captureVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    final remaining = _maxMedia - uploadedFilesUrls.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 10 items reached')),
      );
      return;
    }
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return;
    final file = File(x.path);
    context.read<JobActionsBloc>().add(UploadMediaEvent([file]));
  }

  Future<void> _captureVideo() async {
    final remaining = _maxMedia - uploadedFilesUrls.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 10 items reached')),
      );
      return;
    }
    final x = await _picker.pickVideo(source: ImageSource.camera);
    if (x == null) return;
    final file = File(x.path);
    context.read<JobActionsBloc>().add(UploadMediaEvent([file]));
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
              tooltip: 'Gallery',
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
            ),
            IconButton(
              tooltip: 'Camera',
              onPressed: _cameraSheet,
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
