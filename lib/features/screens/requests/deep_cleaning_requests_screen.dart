import 'package:cleaning_service_driver/components/detail_row.dart';
import 'package:cleaning_service_driver/components/media_carousel_viewer.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_action_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_actions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DeepCleaningRequestScreen extends StatefulWidget {
  final DeepCleaningHistory request;
  DeepCleaningRequestScreen({super.key, required this.request});

  @override
  State<DeepCleaningRequestScreen> createState() => _DeepCleaningRequestState();
}

class _DeepCleaningRequestState extends State<DeepCleaningRequestScreen> {
  final _amountController = TextEditingController();
  final _timelineController = TextEditingController();
  final _descriptionController = TextEditingController();
  double? _bidAmount;
  String? _description;
  String? _timeline;
  int? _selectedTimelineDays;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
    _timelineController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
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
    return BlocConsumer<RequestsActionBloc, RequestsActionState>(
      listener: (ctx, state) {
        if (state is OfferSubmitted) {
          context.goNamed('deepCleaningSuccess');
        } else if (state is RequestsActionFailed) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.request_details_label)),
          body: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
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
                              width: 260, height: 160, child: _mediaThumb(url)),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),
                _title(context.l10n.job_details),
                DetailRow(
                    context.l10n.request_card_bedroom, d.bedrooms.toString()),
                const Divider(),
                DetailRow(
                    context.l10n.request_card_bathroom, d.bathrooms.toString()),
                const Divider(),
                DetailRow(
                    context.l10n.request_card_kitchen, d.kitchens.toString()),
                const Divider(),
                DetailRow(context.l10n.request_card_livingroom,
                    d.livingRooms.toString()),
                const SizedBox(height: 32),
                _title(context.l10n.request_card_schedule),
                Text(
                    DateFormat.yMMMd().add_jm().format(
                          d.scheduledTime!,
                        ),
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 32),
                _title(context.l10n.address),
                Text(d.fullAddress,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 32),
                if (d.additionalInformation?.trim().isNotEmpty ?? false) ...[
                  _title(context.l10n.request_card_notes),
                  Text(d.additionalInformation!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.text,
                  onChanged: (v) => setState(() => _description = v),
                  decoration: InputDecoration(
                    labelText: context.l10n.enter_bid,
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedTimelineDays,
                  onChanged: (v) => setState(() => _selectedTimelineDays = v),
                  decoration: InputDecoration(
                    labelText: context.l10n.enter_bid,
                    prefixIcon: const Icon(Icons.access_time_outlined),
                  ),
                  items: const [1, 2, 3, 4, 5, 7]
                      .map(
                        (d) => DropdownMenuItem<int>(
                          value: d,
                          child: Text(context.l10n.days(d)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      setState(() => _bidAmount = double.tryParse(v)),
                  decoration: InputDecoration(
                    labelText: context.l10n.enter_bid,
                    prefixIcon: Icon(Icons.gavel_rounded),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: FilledButton(
              onPressed: _bidAmount == null || _selectedTimelineDays == null
                  ? null
                  : () {
                      context.read<RequestsActionBloc>().add(
                            SubmitOffer(
                              _description ?? "",
                              double.parse(_amountController.text),
                              widget.request.id ?? "",
                              "$_selectedTimelineDays" ?? "",
                            ),
                          );
                    },
              child: Text(context.l10n.submit_bid),
            ),
          ),
        );
      },
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      );
}
