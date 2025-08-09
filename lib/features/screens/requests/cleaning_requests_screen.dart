import 'dart:async';

import 'package:cleaning_service_driver/components/cleaning_job_card.dart';
import 'package:cleaning_service_driver/components/deep_cleaning_request_card.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/deep_cleaning_history.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_event.dart';
import 'package:cleaning_service_driver/features/bloc/requests/requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _scrollCtrl = ScrollController();
  late Timer _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
            onPressed: () =>
                context.read<RequestsBloc>().add(FetchFirstPageRequests()),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: context.l10n.requests_all_requests),
            Tab(text: context.l10n.requests_deep_cleaning),
            Tab(text: context.l10n.requests_house_keeping),
          ],
        ),
      ),
      body: BlocConsumer<RequestsBloc, RequestsState>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          if (state is RequestsFailed) {
            return Center(child: Text('Error: ${state.message}'));
          }

          final all = state.all;
          final deep = all.whereType<DeepCleaningHistory>().toList();
          final house = all.whereType<HouseKeepingHistory>().toList();

          final items = all;
          final hasMore = state.hasMore;
          final itemCount = hasMore ? items.length + 1 : items.length;

          return TabBarView(
            controller: _tabs,
            children: [
              _buildPaginatedList(all, state),
              _buildPaginatedList(deep, state),
              _buildPaginatedList(house, state),
            ],
          );
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPaginatedList(
    List<CleaningRequest> items,
    RequestsState state,
  ) {
    if (items.isEmpty) {
      return Center(child: Text(context.l10n.requests_no_requests));
    }

    // show an extra slot when more pages exist
    final count = state.hasMore ? items.length + 1 : items.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
            !state.isLoading &&
            state.hasMore) {
          context.read<RequestsBloc>().add(FetchNextPageRequests());
        }
        return false;
      },
      child: ListView.builder(
        itemCount: count,
        itemBuilder: (ctx, idx) {
          if (idx < items.length) {
            final req = items[idx];
            return req.type?.toLowerCase() == 'deepcleaning'
                ? InkWell(
                    onTap: () => context.goNamed('deepCleaning', extra: req),
                    child: DeepCleaningRequestCard(
                      request: req as DeepCleaningHistory,
                      onSubmitBid: () {
                        context.goNamed('deepCleaning', extra: req);
                      },
                    ),
                  )
                : InkWell(
                    onTap: () {
                      context.goNamed('houseKeeping', extra: req);
                    },
                    child: CleaningJobCard(
                      request: req as HouseKeepingHistory,
                      onAccept: () {
                        // context
                        //     .read<RequestsBloc>()
                        //     .add(ObtainHouseKeepingRequest(req.id));
                        context.goNamed('houseKeeping', extra: req);
                      },
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
