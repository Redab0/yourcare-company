# Documents Center (DEV)

Owners and managers open Documents Center from Home. It shows documents shared
with all businesses and documents assigned to their own business. Companies can
read/download only; admin uploads, edits metadata and removes documents.

API: GET `/company/documents` and GET `/company/documents/:id/download`.
Downloads require authentication and return file bytes, not a public URL.
Documents are PDF, PNG or JPEG, up to 10 MiB. English and Arabic are supported.

Local browser preview uses real DEV login and the actual Documents Center screen:

```sh
flutter build web --release --no-wasm-dry-run --pwa-strategy=none \
  --target lib/main_documents_preview.dart
python3 -m http.server 7372 --bind 127.0.0.1 --directory build/web
```

Open http://127.0.0.1:7372 and sign in with a DEV business owner/manager.
The separate preview entry point intentionally skips mobile Firebase/push
bootstrap. It must not be used as a production mobile entry point. Mobile
`lib/main.dart` is unchanged. No mobile app-store build was deployed.

Verification: 273 tests pass with `flutter test --concurrency=1`; documents
coverage includes role visibility, authenticated binary downloads, stale-result
handling, retry/empty states and English/Arabic 320/1100px layouts. One existing
laundry deadline test failed under concurrent load, then passed alone and in
the full serial run. Targeted documents analysis and preview web build pass.

Generator note: the existing `auto_bid_categories_service.g.dart` has a manual
Map decoding fix that the installed Retrofit generator cannot reproduce.
Review unrelated generated output after full code generation; preserve that fix.
