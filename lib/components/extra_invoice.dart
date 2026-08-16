import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

T resolveExtraInvoiceResult<T extends CleaningRequest>({
  required T currentRequest,
  required AddExtraFeesRequest submittedRequest,
  CleaningRequest? updatedRequest,
}) {
  final serverRequest = updatedRequest is T ? updatedRequest : null;
  final baseRequest = serverRequest ?? currentRequest;
  return baseRequest.copyWithExtraInvoice(
    extraFees: serverRequest?.extraFees ?? submittedRequest.extraFees,
    extraFeesDescription: serverRequest?.extraFeesDescription ??
        submittedRequest.extraFeesDescription,
    awaitingExtraPayment: true,
    extraPaymentUrl: serverRequest?.extraPaymentUrl,
  ) as T;
}

Future<AddExtraFeesRequest?> showExtraInvoiceDialog(
  BuildContext context,
) {
  return showDialog<AddExtraFeesRequest>(
    context: context,
    builder: (_) => const _ExtraInvoiceDialog(),
  );
}

class ExtraInvoiceActionButton extends StatelessWidget {
  final CleaningRequest request;
  final VoidCallback onPressed;

  const ExtraInvoiceActionButton({
    super.key,
    required this.request,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!request.canCreateExtraInvoice) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: request.awaitingExtraPayment ? null : onPressed,
        icon: const Icon(Icons.receipt_long_outlined),
        label: Text(
          request.awaitingExtraPayment
              ? context.l10n.extra_invoice_payment_pending
              : context.l10n.create_extra_invoice,
        ),
      ),
    );
  }
}

class ExtraInvoiceStatusCard extends StatelessWidget {
  final CleaningRequest request;

  const ExtraInvoiceStatusCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    if (!request.hasExtraInvoice) return const SizedBox.shrink();
    final pending = request.awaitingExtraPayment;
    final accent = pending ? Colors.orange.shade800 : Colors.green.shade800;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: pending
          ? Colors.orange.withValues(alpha: 0.1)
          : Colors.green.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pending
                      ? Icons.hourglass_top_rounded
                      : Icons.receipt_long_outlined,
                  color: accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pending
                        ? context.l10n.extra_invoice_payment_pending
                        : context.l10n.extra_invoice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                if (request.extraFees != null)
                  Text(
                    RequestFmt.price(request.extraFees),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
              ],
            ),
            if (request.extraFeesDescription?.isNotEmpty ?? false) ...[
              const SizedBox(height: 10),
              Text(
                request.extraFeesDescription!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (pending) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.extra_invoice_payment_pending_hint,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExtraInvoiceDialog extends StatefulWidget {
  const _ExtraInvoiceDialog();

  @override
  State<_ExtraInvoiceDialog> createState() => _ExtraInvoiceDialogState();
}

class _ExtraInvoiceDialogState extends State<_ExtraInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      AddExtraFeesRequest(
        extraFees: double.parse(_amountController.text.trim()),
        extraFeesDescription: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.create_extra_invoice),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.extra_invoice_customer_payment_hint,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.extra_invoice_amount,
                    suffixText: context.l10n.kwd,
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return context.l10n.extra_invoice_amount_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 250,
                  decoration: InputDecoration(
                    labelText: context.l10n.extra_invoice_reason,
                    hintText: context.l10n.extra_invoice_reason_hint,
                    prefixIcon: const Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.extra_invoice_reason_required;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.general_cancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send_outlined),
          label: Text(context.l10n.create_extra_invoice),
        ),
      ],
    );
  }
}
