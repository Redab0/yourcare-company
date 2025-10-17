import 'package:flutter/material.dart';

class MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MediaButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      icon: Icon(icon, color: theme.colorScheme.primary),
      label: Text(label),
      style: theme.outlinedButtonTheme.style,
      onPressed: onTap,
    );
  }
}
