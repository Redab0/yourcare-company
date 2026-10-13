import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_bloc.dart';
import 'package:cleaning_service_driver/features/bloc/jobs/job_actions_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestDetailsRefreshButton extends StatelessWidget {
  final String? requestId;

  const RequestDetailsRefreshButton({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: context.l10n.refresh_request_details,
        icon: const Icon(Icons.refresh),
        onPressed: requestId?.isNotEmpty == true
            ? () =>
                context.read<JobActionsBloc>().add(RefreshJobEvent(requestId!))
            : null,
      );
}
