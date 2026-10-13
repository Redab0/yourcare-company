import 'package:cleaning_service_driver/components/business_back_button.dart';
import 'package:cleaning_service_driver/components/loading_overlay.dart';
import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_action_error.dart';
import 'package:cleaning_service_driver/data/models/laundry/laundry_history.dart';
import 'package:cleaning_service_driver/data/repositories/laundry/laundry_repository.dart';
import 'package:flutter/material.dart';

import 'laundry_job_details_screen.dart';

/// Notification entry point where no request was already loaded by a list.
class LaundryOrderLoaderScreen extends StatefulWidget {
  final String requestId;
  const LaundryOrderLoaderScreen({super.key, required this.requestId});
  @override
  State<LaundryOrderLoaderScreen> createState() =>
      _LaundryOrderLoaderScreenState();
}

class _LaundryOrderLoaderScreenState extends State<LaundryOrderLoaderScreen> {
  late Future<LaundryHistory> _request =
      sl<LaundryRepository>().getOrder(widget.requestId);
  @override
  Widget build(BuildContext context) => FutureBuilder<LaundryHistory>(
      future: _request,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LaundryJobDetailsScreen(request: snapshot.data!);
        }
        final message =
            snapshot.hasError ? requestActionErrorMessage(snapshot.error!) : '';
        return Scaffold(
            appBar: AppBar(
                leading: const BusinessBackButton(
                    fallbackRouteName: 'jobs-main-screen'),
                title: Text(context.l10n.laundry_order)),
            body: Center(
                child: snapshot.hasError
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(message.isEmpty
                              ? context.genericErrorMessage
                              : message),
                          const SizedBox(height: 12),
                          FilledButton(
                              onPressed: () => setState(() {
                                    _request = sl<LaundryRepository>()
                                        .getOrder(widget.requestId);
                                  }),
                              child: Text(context.l10n.retry))
                        ]))
                    : const AppIconSpinner(
                        assetPath: 'assets/images/ic_yourcare.png')));
      });
}
