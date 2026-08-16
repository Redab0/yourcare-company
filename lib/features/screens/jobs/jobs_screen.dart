import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/job_tile.dart';
import 'package:cleaning_service_driver/components/shimmer_box.dart';
import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/car_wash_history.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/data/models/requests/upholstery_cleaning_history.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_event.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_state.dart';
import 'package:cleaning_service_driver/features/onboarding/business_showcase.dart';
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
  static const _tourScope = 'business_jobs_journey';
  final _statusesTourKey = GlobalKey(debugLabel: 'jobs-statuses-tour');
  final _jobsListTourKey = GlobalKey(debugLabel: 'jobs-list-tour');
  late TabController _tabs;
  late final BusinessShowcaseTourController _tour;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tour = BusinessShowcaseTourController(scope: _tourScope);
    SecureStorageService().getUser().then((user) {
      final ownerId = businessShowcaseOwnerId(user);
      if (ownerId == null) return;
      _tour.scheduleStartOnce(
        ownerId: ownerId,
        journeyId: 'jobs',
        keys: [_statusesTourKey, _jobsListTourKey],
      );
    });
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
    _tour.dispose();
    _tabs.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BusinessBackButton(fallbackRouteName: 'home'),
        actions: [
          BusinessShowcaseHelpButton(
            onPressed: () => _tour.start([_statusesTourKey, _jobsListTourKey]),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight),
          child: BusinessShowcaseStep(
            showcaseKey: _statusesTourKey,
            scope: _tourScope,
            title: context.l10n.upcoming_jobs,
            description: context.l10n.business_inner_tour_jobs_statuses,
            index: 0,
            itemCount: 2,
            targetPadding: EdgeInsets.zero,
            targetBorderRadius: BorderRadius.zero,
            child: TabBar(
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
        ),
      ),
      body: BusinessShowcaseStep(
        showcaseKey: _jobsListTourKey,
        scope: _tourScope,
        title: context.l10n.upcoming_jobs,
        description: context.l10n.business_inner_tour_jobs_list,
        index: 1,
        itemCount: 2,
        child: BlocConsumer<JobBloc, JobState>(
          listener: (BuildContext context, JobState state) {
            if (state is JobError || state.error != null) {
              context.showErrorToast();
            }
          },
          builder: (ctx, state) {
            if (state is JobError) {
              return Center(child: Text(ctx.genericErrorMessage));
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
      ),
    );
  }

  Widget _buildPaginatedList(
    List<CleaningRequest> items,
    JobState state,
  ) {
    if (items.isEmpty) {
      if (state.isLoading) {
        return _buildJobsShimmer();
      }
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
            if (req is DeepCleaningHistory) {
              return InkWell(
                onTap: () =>
                    context.pushNamed('deepCleaningJobDetails', extra: req),
                child: JobTile(request: req),
              );
            } else if (req is UpholsteryCleaningHistory) {
              return InkWell(
                onTap: () => context.pushNamed(
                  'upholsteryCleaningJobDetails',
                  extra: req,
                ),
                child: JobTile(request: req),
              );
            } else if (req is CarWashHistory) {
              return InkWell(
                onTap: () => context.pushNamed(
                  'carWashJobDetails',
                  extra: req,
                ),
                child: JobTile(request: req),
              );
            } else if (req is HouseKeepingHistory) {
              return InkWell(
                onTap: () =>
                    context.pushNamed('houseKeepingJobDetails', extra: req),
                child: JobTile(request: req),
              );
            }
            return JobTile(request: req);
          } else {
            // loading indicator at bottom
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildJobsShimmer() {
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
                ShimmerBox(height: 14, width: 120),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 200),
                SizedBox(height: 6),
                ShimmerBox(height: 12, width: 160),
              ],
            ),
          ),
        );
      },
    );
  }
}
