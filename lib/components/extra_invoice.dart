import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/core/utils/request_helpers.dart';
import 'package:cleaning_service_driver/data/models/requests/add_extra_fees_request.dart';
import 'package:cleaning_service_driver/data/models/requests/cleaning_request.dart';
import 'package:cleaning_service_driver/data/models/requests/request_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

T resolveExtraInvoiceResult<T extends CleaningRequest>({
  required T currentRequest,
  required AddExtraFeesRequest submittedRequest,
  CleaningRequest? updatedRequest,
}) {
  final serverRequest = updatedRequest is T ? updatedRequest : null;
  final baseRequest = serverRequest ?? currentRequest;
  final invoices = _mergeCreatedInvoice(
    currentInvoices: currentRequest.invoices,
    serverInvoices: serverRequest?.invoices ?? const [],
    submittedRequest: submittedRequest,
    paymentUrl: serverRequest?.extraPaymentUrl,
  );
  return baseRequest.copyWithExtraInvoice(
    extraFees: serverRequest?.extraFees ?? submittedRequest.extraFees,
    extraFeesDescription: serverRequest?.extraFeesDescription ??
        submittedRequest.extraFeesDescription,
    awaitingExtraPayment: invoices.any((invoice) => !invoice.isPaid),
    extraPaymentUrl: serverRequest?.extraPaymentUrl,
    invoices: invoices,
  ) as T;
}

List<RequestInvoice> _mergeCreatedInvoice({
  required List<RequestInvoice> currentInvoices,
  required List<RequestInvoice> serverInvoices,
  required AddExtraFeesRequest submittedRequest,
  String? paymentUrl,
}) {
  final merged = List<RequestInvoice>.from(currentInvoices);
  var foundNewServerInvoice = false;

  for (final invoice in serverInvoices) {
    final id = invoice.id?.trim();
    final existingIndex = id == null || id.isEmpty
        ? -1
        : merged.indexWhere((existing) => existing.id == id);
    if (existingIndex >= 0) {
      merged[existingIndex] = invoice;
    } else {
      merged.add(invoice);
      foundNewServerInvoice = true;
    }
  }

  if (!foundNewServerInvoice) {
    merged.add(
      RequestInvoice(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        type: 'extra_fees',
        amount: submittedRequest.extraFees,
        status: 'pending',
        paymentUrl: paymentUrl,
        description: submittedRequest.extraFeesDescription,
        createdAt: DateTime.now(),
      ),
    );
  }
  return List.unmodifiable(merged);
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
        onPressed: request.hasPendingExtraInvoicePayment ? null : onPressed,
        icon: const Icon(Icons.receipt_long_outlined),
        label: Text(
          request.hasPendingExtraInvoicePayment
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
    final invoices = request.invoices;
    final pending = request.hasPendingExtraInvoicePayment;
    final successful = request.allExtraInvoicePaymentsSuccessful;
    final amount = invoices.isEmpty
        ? request.extraFees
        : invoices.fold<double>(
            0,
            (total, invoice) => total + invoice.amount,
          );
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
                        : successful
                            ? context.l10n.extra_invoice_payments_successful
                            : context.l10n.extra_invoice,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                if (amount != null && amount > 0)
                  Text(
                    RequestFmt.price(amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
              ],
            ),
            if (invoices.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...List.generate(
                invoices.length,
                (index) => _InvoiceStatusRow(
                  key: ValueKey(
                    'extra-invoice-${invoices[index].id ?? index}',
                  ),
                  invoice: invoices[index],
                  index: index,
                ),
              ),
            ] else if (request.extraFeesDescription?.isNotEmpty ?? false) ...[
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.extra_invoice_total_paid,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Text(
                  RequestFmt.price(request.totalPaidIncludingExtraInvoices),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceStatusRow extends StatelessWidget {
  final RequestInvoice invoice;
  final int index;

  const _InvoiceStatusRow({
    super.key,
    required this.invoice,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final paid = invoice.isPaid;
    final statusColor = paid ? Colors.green.shade800 : Colors.orange.shade800;
    final description = invoice.description?.trim();

    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 0 : 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.l10n.extra_invoice} ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                RequestFmt.price(invoice.amount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          if (description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(description!),
          ],
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                paid ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                paid
                    ? context.l10n.extra_invoice_paid
                    : context.l10n.extra_invoice_pending,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
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
