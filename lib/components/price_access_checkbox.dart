import 'package:flutter/material.dart';
import '../core/access/price_widgets.dart';
import '../core/utils/context_extensions.dart';

class PriceAccessCheckbox extends StatelessWidget {
  const PriceAccessCheckbox(
      {super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    if (!context.canManagePriceAccess) return const SizedBox.shrink();
    return CheckboxListTile(
      key: const ValueKey('staff-can-see-prices'),
      title: Text(context.l10n.canSeePrices),
      subtitle: Text(context.l10n.canSeePricesDescription),
      value: value,
      onChanged: (value) {
        if (PriceAccessScope.of(context).canManage) onChanged(value == true);
      },
    );
  }
}
