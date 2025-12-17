import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/requests/cleaning_request.dart';
import '../../data/models/requests/deep_cleaning_history.dart';
import '../../data/models/requests/house_keeping_history.dart';
import '../../data/models/requests/upholstery_cleaning_history.dart';

/// Compact row that shows
///  ─ type (subtitle)
///  ─ bold address
///  ─ Schedule text
///  ─ Thumbnail (first photo if available, otherwise a placeholder asset)
class JobTile extends StatelessWidget {
  const JobTile({
    super.key,
    required this.request,
    this.onTap,
  });

  final CleaningRequest request;
  final VoidCallback? onTap;

  // ───────────────────────── helpers ──────────────────────────

  /// User‑friendly type label.
  String _typeLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (request.type?.toLowerCase()) {
      case 'deepcleaning':
        return l10n.deepCleaning; // ← localized
      case 'housecleaning':
        return l10n.houseKeeping; // ← localized
      case 'upholsterycleaning':
        return l10n.upholstery_cleaning;
      default:
        return request.type ?? l10n.houseKeeping;
    }
  }

  /// Address string (area / street …) depending on concrete request type.
  String get _address {
    if (request is DeepCleaningHistory) {
      return (request as DeepCleaningHistory).detail.address?.area ?? '—';
    }
    if (request is HouseKeepingHistory) {
      return (request as HouseKeepingHistory).detail.address?.area ?? '—';
    }
    if (request is UpholsteryCleaningHistory) {
      return request.customer.addresses?.first.area ?? '—';
    }
    return '—';
  }

  String get _schedule {
    final date = request.scheduledTime;
    return DateFormat('MMM dd, yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(_typeLabel(context),
                          style: theme.textTheme.titleLarge!
                              .copyWith(color: Colors.blueGrey)),
                    ),
                    Chip(
                      label: Text(
                        request.requestStatus.displayText(context),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: _statusColor(request.requestStatus),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "# ${request.id}",
                  style: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _address,
                  style: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _schedule,
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _statusColor(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return Colors.orange;
    case RequestStatus.inProgress:
      return Colors.blue;
    case RequestStatus.completed:
      return Colors.green;
    case RequestStatus.confirmed:
      return Colors.teal;
    case RequestStatus.cancelled:
      return Colors.red;
    default:
      return Colors.grey;
  }
}
