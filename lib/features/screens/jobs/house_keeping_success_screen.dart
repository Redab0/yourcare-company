// lib/screens/requests/house_keeping_success_screen.dart
import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/requests/house_keeping_history.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HouseKeepingJobSuccessScreen extends StatelessWidget {
  const HouseKeepingJobSuccessScreen({super.key, required this.request});
  final HouseKeepingHistory request;

  @override
  Widget build(BuildContext context) {
    final d = request.detail;

    return Scaffold(
      appBar: AppBar(
        leading:
            const BusinessBackButton(fallbackRouteName: 'jobs-main-screen'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 120, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                context.l10n.job_accepted,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/jobs'),
                  child: Text(context.l10n.navigate_back_to_requests),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(k, style: const TextStyle(fontSize: 16))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
