// lib/features/screens/staff/teams_list_screen.dart

import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TeamsListScreen extends StatefulWidget {
  const TeamsListScreen({super.key});

  @override
  State<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends State<TeamsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(FetchTeams());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.team_label),
        elevation: 1,
      ),
      body: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is StaffFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.genericErrorMessage)),
            );
          }
        },
        builder: (context, state) {
          if (state is TeamsFetched) {
            final teams = state.teamModels;
            if (teams.isEmpty) {
              return Center(child: Text(context.l10n.no_teams_available));
            }
            return LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final maxWidth = isWide ? 1000.0 : double.infinity;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                            team.name!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var member in team.users)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Text(
                                        '${member.email} — ${member.role}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        context.goNamed(
                                          "createEditTeamScreen",
                                          extra: team,
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: Text(context.l10n.edit_team),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            });
          }
          // loading or initial
          return SizedBox.shrink();
        },
      ),
    );
  }
}
