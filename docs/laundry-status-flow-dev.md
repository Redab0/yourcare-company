# Laundry order flow on DEV

Company laundry now uses this flow:

| Booking | Before payment | After payment | Company action |
| --- | --- | --- | --- |
| Bag request | Pick up bag → price/send invoice → Awaiting payment | Confirmed | Complete order |
| Priced cart | Awaiting payment | Confirmed | Complete order |

A new bag request can be priced immediately. Accept pickup and Mark as picked up are no longer prerequisites. The existing invoice editor, minimum charge, draft revision, send confirmation and retained input on API failures remain in place.

## Status compatibility and safeguards

- The API status after payment is `confirmed`. Completion uses the existing typed `PATCH /requests/laundry/{id}/status` body `{ "status": "completed" }`.
- The company can complete only when both `paymentStatus` and the invoice status are `paid`. Missing invoices, unpaid/sent/draft invoices, refunds and unknown statuses cannot unlock completion.
- Existing paid `pending_pickup`, `pickup_accepted`, `picked_up`, `invoice_sent`, `paid`, `in_progress`, `ready_for_delivery`, `out_for_delivery` and `delivered` orders display Confirmed. A missing invoice is tolerated for legacy display only; it does not unlock completion.
- Unpaid legacy bag orders in `pickup_accepted` or `picked_up` can still be priced. Sent/paid invoices remain locked.
- A shared request status of Completed or Cancelled overrides a contradictory laundry snapshot for display and all actions. The raw laundry detail and serialization remain unchanged.
- Existing cancellation eligibility remains: paid orders with paid invoices can be cancelled before completion; unpaid raw `pending_pickup` and `pickup_accepted` can be cancelled. Unpaid `picked_up` and `invoice_sent` do not gain cancellation.
- Active laundry stays in the first shared jobs tab, including unpaid bag requests and invoices. Laundry no longer enters In progress. The shared In progress tab remains available for housekeeping and other services.
- Order labels use Pick up bag, Awaiting payment, Confirmed and Completed in English and Arabic. Payment and invoice labels still report Paid, Sent, Draft and Refunded separately.

The provider has no laundry timeline component. Status chips, shared job tiles, share text and action buttons use the same laundry presentation rules. Existing same-day flags, bulk catalog prices/availability, housekeeping status enums/actions and the normal application bootstrap are preserved.

## Validation and builds

Focused tests cover current/legacy payment states, initial bag pricing, mixed laundry/housekeeping tabs, terminal conflicts, completion confirmation/failure/retry, EN/AR layouts, typed requests and bulk-price/availability preservation. Existing invoice/catalog failures outside this status scope are recorded in the external task handoff rather than changed here.

Build from the isolated stage with:

```sh
flutter build web --release --target lib/main_laundry_preview.dart --dart-define=API_ENV=development
flutter build apk --debug --target lib/main.dart --dart-define=API_ENV=development
```

The APK uses the normal Firebase/bootstrap and existing version. Building does not install or launch the app. The local preview uses the existing DEV login/catalog bootstrap; authenticated jobs remain part of the normal application.
