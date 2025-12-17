import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
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
            Tab(
                child: Text(context.l10n.confirmed,
                    style: TextStyle(color: AppTheme.cream))),
            Tab(
                child: Text(context.l10n.inprogress,
                    style: TextStyle(color: AppTheme.cream))),
            Tab(
                child: Text(context.l10n.completed,
                    style: TextStyle(color: AppTheme.cream))),
            Tab(
                child: Text(context.l10n.cancelled,
                    style: TextStyle(color: AppTheme.cream))),
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
            final type = req.type?.toLowerCase() ?? '';
            if (type.contains('deep')) {
              return InkWell(
                onTap: () =>
                    context.goNamed('deepCleaningJobDetails', extra: req),
                child: JobTile(request: req as DeepCleaningHistory),
              );
            } else if (type.contains('upholstery')) {
              return InkWell(
                onTap: () =>
                    context.goNamed('upholsteryCleaningJobDetails', extra: req),
                child: JobTile(request: req as UpholsteryCleaningHistory),
              );
            } else {
              return InkWell(
                onTap: () =>
                    context.goNamed('houseKeepingJobDetails', extra: req),
                child: JobTile(request: req as HouseKeepingHistory),
              );
            }
          } else {
            // loading indicator at bottom
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
