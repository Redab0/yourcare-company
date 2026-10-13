import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class LaundryItemImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const LaundryItemImage({super.key, this.imageUrl, this.size = 56});
  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imageUrl ?? '');
    final valid = uri != null &&
        uri.hasAuthority &&
        ['http', 'https'].contains(uri.scheme);
    final fallback = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.local_laundry_service_outlined,
            color: AppTheme.primary));
    return ExcludeSemantics(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: valid
                ? Image.network(imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => fallback)
                : fallback));
  }
}
