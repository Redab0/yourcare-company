import 'package:flutter/material.dart';
import '../data/models/staff/permission_model.dart';
import '../core/utils/context_extensions.dart';
import 'permission_copy.dart';

/// Every tap changes exactly one ID. Invisible legacy IDs remain in the set.
class PermissionEditor extends StatelessWidget {
  const PermissionEditor(
      {super.key,
      required this.catalog,
      required this.selectedIds,
      required this.onChanged,
      this.existing = const []});
  final List<PermissionModel> catalog;
  final List<PermissionModel> existing;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  @override
  Widget build(BuildContext context) {
    final knownIds = catalog.map((p) => p.id).whereType<String>().toSet();
    return Column(children: [
      for (final permission in catalog)
        if (permission.id != null)
          Card(
              child: CheckboxListTile(
            key: ValueKey('permission-${permission.id}'),
            title: Text(permissionCopy(context, permission.name).title),
            subtitle:
                Text(permissionCopy(context, permission.name).description),
            value: selectedIds.contains(permission.id),
            onChanged: (selected) {
              final next = Set<String>.of(selectedIds);
              if (selected == true) {
                next.add(permission.id!);
              } else {
                next.remove(permission.id);
              }
              onChanged(next);
            },
          )),
      if (selectedIds.difference(knownIds).isNotEmpty)
        ListTile(
          key: const ValueKey('retained-permissions'),
          leading: const Icon(Icons.lock_outline),
          title: Text(context.l10n.permissionRetainedTitle),
          subtitle: Text(context.l10n.permissionRetainedDescription),
        ),
    ]);
  }
}
