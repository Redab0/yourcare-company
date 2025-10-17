import 'package:cleaning_service_driver/components/user_profile_card.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(FetchFirstPageStaff());

    _scrollCtrl.addListener(() {
      final max = _scrollCtrl.position.maxScrollExtent;
      final cur = _scrollCtrl.position.pixels;
      if (cur >= max - 200) {
        context.read<StaffBloc>().add(FetchNextPageStaff());
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: Text(context.l10n.staff_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<StaffBloc, StaffState>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          if (state is StaffFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }

          final itemCount = state.all.length + (state.hasMore ? 1 : 0);
          return Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 16),
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: itemCount,
              itemBuilder: (ctx, idx) {
                if (idx < state.all.length) {
                  final user = state.all[idx];
                  return InkWell(
                    onTap: () =>
                        context.goNamed('userDetailsScreen', extra: user),
                    child: UserProfileCard(user: user),
                  );
                } else {
                  // bottom loader
                  return SizedBox.shrink();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
