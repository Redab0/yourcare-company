import 'package:flutter/material.dart';

class DateTimePickerField extends StatelessWidget {
  final String label;
  final String value; // formatted date string ('' when not chosen)
  final VoidCallback onTap;
  final IconData icon;
  final String? hintText; // ← NEW: placeholder when value is empty

  const DateTimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
    this.hintText, // ← NEW
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value.isEmpty;
    final display = isEmpty ? (hintText ?? '') : value;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  display,
                  style: isEmpty
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor, // placeholder look
                        )
                      : theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
