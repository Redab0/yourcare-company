import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/features/bloc/laundry/laundry_cubit.dart';
import 'package:flutter/material.dart';

class LaundryCatalogLoadNotice extends StatelessWidget {
  final bool loading;
  final LaundryCatalogFailure? failure;
  final VoidCallback onRetry;
  const LaundryCatalogLoadNotice(
      {super.key, this.loading = false, this.failure, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    if (!loading && failure == null) return const SizedBox.shrink();
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (loading) ...[
                    const Center(
                        child: AppIconSpinner(
                            assetPath: 'assets/images/ic_yourcare.png',
                            size: 48)),
                    const SizedBox(height: 8),
                    Text(context.l10n.laundry_catalog_loading,
                        textAlign: TextAlign.center),
                  ] else ...[
                    Text(failure == LaundryCatalogFailure.timeout
                        ? context.l10n.laundry_catalog_load_timeout
                        : context.l10n.laundry_catalog_load_error),
                    Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                            key: const ValueKey('laundry-catalog-retry'),
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh),
                            label: Text(context.l10n.retry))),
                  ],
                ])));
  }
}
