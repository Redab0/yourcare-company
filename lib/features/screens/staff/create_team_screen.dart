import 'package:cleaning_service_driver/components/business_back_button.dart';
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
  const CreateEditTeamScreen({super.key, this.team});

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
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(isEdit ? context.l10n.edit_team : context.l10n.create_team),
        leading: const BusinessBackButton(
          fallbackRouteName: 'staff-main-screen',
        ),
        elevation: 1,
      ),
      body: MultiBlocListener(
        listeners: [
          // staff list errors
          BlocListener<StaffBloc, StaffState>(
            listener: (context, state) {
              if (state.error != null) {
                context.showErrorToast();
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
                context.showErrorToast();
              }
            },
          ),
        ],
        child: LayoutBuilder(builder: (ctx, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final maxWidth = isWide ? 1100.0 : double.infinity;
          final crossAxisCount = isWide ? 3 : 1;
          final childAspect = isWide ? 2.4 : 3.4;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
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
                    Text(context.l10n.select_team_members,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BlocBuilder<StaffBloc, StaffState>(
                        builder: (context, state) {
                          if (state.isLoading && state.all.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          if (!isEdit && state.all.isNotEmpty) {
                            _businessId = state.all.first.businessId ?? '';
                          }
                          final users = state.all;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: childAspect,
                            ),
                            itemCount: users.length,
                            itemBuilder: (_, i) {
                              final user = users[i];
                              final selected =
                                  _selectedUserIds.contains(user.id);
                              return InkWell(
                                onTap: () => setState(() {
                                  if (selected) {
                                    _selectedUserIds.remove(user.id);
                                  } else {
                                    _selectedUserIds.add(user.id!);
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: selected
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade300,
                                        width: selected ? 2 : 1),
                                    color: selected
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.06)
                                        : Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            (user.image?.isNotEmpty ?? false)
                                                ? NetworkImage(user.image!)
                                                : null,
                                        child: (user.image?.isNotEmpty ?? false)
                                            ? null
                                            : const Icon(Icons.person),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(user.username ?? '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            if ((user.email ?? '').isNotEmpty)
                                              Text(user.email ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .grey.shade700)),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        selected
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: selected
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
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
        }),
      ),
    );
  }
}
