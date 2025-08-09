import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    context.read<JobBloc>().add(LoadJobsEvent());

    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      final cur = _scrollCtrl.position.pixels;
      if (cur >= max - 200) {
        context.read<JobBloc>().add(FetchNextPageRequests());
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: context.l10n.confirmed),
            Tab(text: context.l10n.inprogress),
            Tab(text: context.l10n.completed),
            Tab(text: context.l10n.cancelled),
          ],
        ),
      ),
      body: BlocConsumer<JobBloc, JobState>(
        listener: (BuildContext context, JobState state) {},
        builder: (ctx, state) {
          if (state is JobError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          final all = state.all;
          final deep = all.whereType<DeepCleaningHistory>().toList();
          final house = all.whereType<HouseKeepingHistory>().toList();
          final pending = all
              .where((job) => job.requestStatus == RequestStatus.pending)
              .toList();
          final inProgress = all
              .where((job) => job.requestStatus == RequestStatus.inProgress)
              .toList();
          final completed = all
              .where((job) => job.requestStatus == RequestStatus.completed)
              .toList();
          final cancelled = all
              .where((job) => job.requestStatus == RequestStatus.cancelled)
              .toList();
          final confirmed = all
              .where((job) => job.requestStatus == RequestStatus.confirmed)
              .toList();

          final items = all;
          final hasMore = state.hasMore;
          final itemCount = hasMore ? items.length + 1 : items.length;

          return TabBarView(
            controller: _tabs,
            children: [
              _buildPaginatedList(confirmed, state),
              _buildPaginatedList(inProgress, state),
              _buildPaginatedList(completed, state),
              _buildPaginatedList(cancelled, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaginatedList(
    List<CleaningRequest> items,
    JobState state,
  ) {
    if (items.isEmpty) {
      return const Center(child: Text('No requests found.'));
    }

    // show an extra slot when more pages exist
    final count = state.hasMore ? items.length + 1 : items.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
            !state.isLoading &&
            state.hasMore) {
          context.read<JobBloc>().add(FetchNextPageRequests());
        }
        return false;
      },
      child: ListView.builder(
        itemCount: count,
        itemBuilder: (ctx, idx) {
          if (idx < items.length) {
            final req = items[idx];
            return req.type!.toLowerCase().contains("deep")
                ? InkWell(
                    onTap: () =>
                        context.goNamed('deepCleaningJobDetails', extra: req),
                    child: JobTile(
                      request: req as DeepCleaningHistory,
                    ),
                  )
                : InkWell(
                    onTap: () =>
                        context.goNamed('houseKeepingJobDetails', extra: req),
                    child: JobTile(
                      request: req as HouseKeepingHistory,
                    ),
                  );
          } else {
            // loading indicator at bottom
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
