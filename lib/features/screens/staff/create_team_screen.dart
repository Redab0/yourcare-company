import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/staff/create_team_model.dart';
import 'package:cleaning_service_driver/data/models/staff/team_model.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_action_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_actions_state.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_event.dart';
import 'package:cleaning_service_driver/features/bloc/staff/staff_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Reusable screen for creating or editing a team.
class CreateEditTeamScreen extends StatefulWidget {
  final TeamModel? team;
  const CreateEditTeamScreen({Key? key, this.team}) : super(key: key);

  @override
  State<CreateEditTeamScreen> createState() => _CreateEditTeamScreenState();
}

class _CreateEditTeamScreenState extends State<CreateEditTeamScreen> {
  late final bool isEdit;
  final TextEditingController _teamNameController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  String _businessId = '';

  @override
  void initState() {
    super.initState();
    isEdit = widget.team != null;
    // fetch available users
    context.read<StaffBloc>().add(FetchFirstPageStaff());
    if (isEdit) {
      // prefill fields
      _teamNameController.text = widget.team!.name!;
      _businessId = widget.team!.business!.id;
      _selectedUserIds.addAll(
        widget.team!.users.map((m) => m.id ?? ""),
      );
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final model = CreateTeamModel(
      _teamNameController.text.trim(),
      _businessId,
      _selectedUserIds.toList(),
    );
    if (isEdit) {
      context.read<StaffActionBloc>().add(
            UpdateTeamEvent(model, widget.team!.id!),
          );
    } else {
      context.read<StaffActionBloc>().add(
            CreateTeamEvent(model),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? context.l10n.edit_team : context.l10n.create_team),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: MultiBlocListener(
        listeners: [
          // staff list errors
          BlocListener<StaffBloc, StaffState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              }
            },
          ),
          // create/update team responses
          BlocListener<StaffActionBloc, StaffActionState>(
            listener: (context, state) {
              if (state is TeamCreatedState && !isEdit) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Team created successfully')),
                );
                Navigator.of(context).pop();
              }
              if (state is TeamUpdatedState && isEdit) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Team updated successfully')),
                );
                context.goNamed("teamsListScreen");
              }
              if (state is StaffActionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team name input
              TextField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.team_name,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Users selection
              Text(context.l10n.select_team_members,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<StaffBloc, StaffState>(
                  builder: (context, state) {
                    if (state.isLoading && state.all.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // set businessId from first user if not editing
                    if (!isEdit && state.all.isNotEmpty) {
                      _businessId = state.all.first.businessId ?? '';
                    }
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.all.map((user) {
                          final selected = _selectedUserIds.contains(user.id);
                          return ChoiceChip(
                            avatar: (user.image != null &&
                                    user.image!.isNotEmpty)
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(user.image!),
                                    radius: 12,
                                  )
                                : const CircleAvatar(
                                    radius: 12,
                                    child: Icon(Icons.person, size: 16),
                                  ),
                            label: Text(user.username ?? ''),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              if (selected) {
                                _selectedUserIds.remove(user.id);
                              } else {
                                _selectedUserIds.add(user.id!);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              // Submit button
              ElevatedButton(
                onPressed: _teamNameController.text.trim().isEmpty ||
                        _selectedUserIds.isEmpty
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    isEdit
                        ? context.l10n.save_changes
                        : context.l10n.create_team,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
