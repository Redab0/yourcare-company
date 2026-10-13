# Bulk laundry prices (DEV)

Owners/managers with laundry pricing edit access open Laundry pricing and choose
**Update multiple prices**. Edit prices and availability across managed products
and company custom items, including size and service prices, then choose **Save
all changes**. Unchanged items are omitted. Search filters the visible rows without
discarding edits. A failed save keeps the draft; leaving with edits asks whether
to discard them.

API: PATCH `/business/my-business/laundry-catalog/prices` with one typed body:
`{items: [{productId: "managed-product-id", price: 2.5, active: false},
{itemId: "custom-item-id", sizes: [{sizeId: "size-id", price: 3}], active: true}]}`.
`active` is optional and must be a boolean. A status-only row can contain just
`productId`/`itemId` and `active`; omitted availability keeps the current value.
The app sends availability only when the switch differs from the loaded value.
Nested service availability stays unchanged. Admin-disabled products cannot be
newly enabled. Failed combined saves keep both price and availability drafts.
The server saves all changes atomically and returns the updated catalog rows.
Prices use KWD, from 0.001 to 10,000 with at most three decimal places.
The maximum is 200 changed items per save.

Standalone browser preview uses real DEV authentication and the actual catalog:

```sh
flutter build web --release --no-wasm-dry-run --pwa-strategy=none \
  --target lib/main_laundry_preview.dart
python3 -m http.server 7373 --bind 127.0.0.1 --directory build/web
```

Open http://127.0.0.1:7373 and sign in with a DEV owner/manager account.
The preview skips mobile Firebase/push bootstrap; mobile `lib/main.dart` remains
the normal entry point. The separate Documents Center preview is still available.
