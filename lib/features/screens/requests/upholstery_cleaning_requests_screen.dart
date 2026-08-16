import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/media_carousel_viewer.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/features/chats/presentation/chat_open_helper.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../components/cleaning_item_summary_card.dart';

class UpholsteryCleaningRequestScreen extends StatefulWidget {
  final UpholsteryCleaningHistory request;
  const UpholsteryCleaningRequestScreen({super.key, required this.request});

  @override
  State<UpholsteryCleaningRequestScreen> createState() =>
      _UpholsteryCleaningRequestState();
}

class _UpholsteryCleaningRequestState
    extends State<UpholsteryCleaningRequestScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  double? _bidAmount;
  String? _selectedTimelineHours;

  @override
  void initState() {
    super.initState();
    final myBid = widget.request.myBid;
    if (myBid != null) {
      _amountController.text = myBid.totalPrice.toString();
      _bidAmount = myBid.totalPrice;
      final timeline = myBid.timelineBusinessOffer ?? '';
      if (const ['2', '5', '8', '12', '24+'].contains(timeline)) {
        _selectedTimelineHours = timeline;
      }
      _descriptionController.text = myBid.descriptionBusinessOffer ?? '';
    }
    _amountController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority;
  }

  bool _isVideoUrl(String u) {
    final s = u.toLowerCase();
    return s.endsWith('.mp4') ||
        s.endsWith('.mov') ||
        s.endsWith('.mkv') ||
        s.endsWith('.webm') ||
        s.endsWith('.avi');
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
                  : Image.network(url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: Color(0x11000000))),
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
    final details = widget.request;
    final items = widget.request.upholsteryCleaning.items;
    final specialNotes = widget.request.customerSpecialNotes;
    final effectiveRequestId = widget.request.id;
    final canChat = (widget.request.requestStatus == RequestStatus.confirmed ||
            widget.request.requestStatus == RequestStatus.inProgress) &&
        ((effectiveRequestId ?? '').isNotEmpty);
    return BlocConsumer<RequestsActionBloc, RequestsActionState>(
      listener: (ctx, state) {
        if (state is OfferSubmitted) {
          context.goNamed('deepCleaningSuccess');
        } else if (state is RequestsActionFailed) {
          ctx.showErrorToast();
        }
      },
      builder: (ctx, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              if (n.direction != ScrollDirection.idle) {
                FocusScope.of(context).unfocus();
              }
              return false;
            },
            child: Scaffold(
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
                    const SizedBox(height: 32),
                    _title(context.l10n.job_details),
                    if (items != null || items?.isNotEmpty == true)
                      ...items!.map((it) {
                        final typeTitle = _titleForType(it.type);
                        final sizeTitle = it.size?.title ?? '-';
                        final materialTitle = it.material?.title ?? '-';
                        final conditionTitle = it.condition?.title ?? '-';
                        final qty = it.quantity ?? 0;
                        final mediaUrls = (it.mediaUrls ?? [])
                            .where(_isValidUrl)
                            .toList(growable: false);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CleaningItemSummaryCard(
                            icon: _iconForTitle(typeTitle),
                            title: qty > 0 ? '$typeTitle x$qty' : typeTitle,
                            size: sizeTitle,
                            material: materialTitle,
                            condition: conditionTitle,
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
                                          onTap: () => openMediaCarousel(
                                              context, mediaUrls,
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
                    const SizedBox(height: 32),
                    _title(context.l10n.address),
                    Text(details.upholsteryCleaning.fullAddress,
                        style: Theme.of(context).textTheme.bodyLarge),
                    if (specialNotes != null) ...[
                      const SizedBox(height: 32),
                      _title(context.l10n.request_card_notes),
                      Text(
                        specialNotes,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextField(
                      minLines: 4,
                      maxLines: 8,
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: context.l10n.enter_note,
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTimelineHours,
                      onChanged: (v) =>
                          setState(() => _selectedTimelineHours = v),
                      decoration: InputDecoration(
                        labelText: context.l10n.enter_timeline,
                        prefixIcon: const Icon(Icons.access_time_outlined),
                      ),
                      items: const [
                        '2',
                        '5',
                        '8',
                        '12',
                        '24+',
                      ].map((hrs) {
                        final label = '$hrs ${context.l10n.hour}';
                        return DropdownMenuItem<String>(
                          value: hrs,
                          child: Text(label),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      textInputAction: TextInputAction.done,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          setState(() => _bidAmount = double.tryParse(v)),
                      decoration: InputDecoration(
                        labelText: context.l10n.enter_bid,
                        prefixIcon: Icon(Icons.gavel_rounded),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                          onPressed: _bidAmount == null ||
                                  _selectedTimelineHours == null
                              ? null
                              : () {
                                  context.read<RequestsActionBloc>().add(
                                        SubmitUpholsteryOffer(
                                          _composeNotes(),
                                          double.parse(_amountController.text),
                                          widget.request.id ?? '',
                                          _selectedTimelineHours!,
                                        ),
                                      );
                                },
                          child: Text(context.l10n.submit_bid),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _titleForType(CleaningItemType? type) =>
      type?.title ?? type?.titleEn ?? type?.titleAr ?? 'Item';

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('sofa') ||
        t.contains('صوفا') ||
        t.contains('couch') ||
        t.contains('كنب')) {
      return Icons.chair_outlined;
    }
    if (t.contains('armchair') || t.contains('كرسي')) {
      return Icons.chair_alt_outlined;
    }
    if (t.contains('mattress') || t.contains('مرتبة')) {
      return Icons.bed_outlined;
    }
    if (t.contains('rug') || t.contains('سجاد')) {
      return Icons.layers_outlined;
    }
    if (t.contains('carpet') || t.contains('سجاد')) {
      return Icons.stairs_outlined;
    }
    if (t.contains('curtain') || t.contains('ستارة')) {
      return Icons.window_outlined;
    }
    return Icons.cleaning_services_outlined;
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      );

  String _composeNotes() => _descriptionController.text.trim();
}
