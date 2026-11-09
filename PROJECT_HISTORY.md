# Provider project history

## 9 November 2026 — Prepare Laundry ASAP deployment branch

Prepared `codex/laundry-asap-booking-cutoffs` from `develop` at `3c57549` in an
isolated worktree. Includes only the Laundry snapshot model/generated reads,
ASAP pickup and saved Same Day/Next Day delivery/date presentation in lists,
request summaries, details and share text, synchronized EN/AR outputs and focused
ASAP/legacy tests. Original dirty worktree files are preserved byte-for-byte;
demo banner suppression, private artifacts and unrelated history are excluded.
Versions, native files, default API selection and partner cutoff editor remain
at the base revision.

Fresh checks: full unfiltered build_runner and `flutter gen-l10n --format` passed;
all 13 feature files match the reviewed original source bytes. Full tests:
613 passed; focused ASAP/badge tests: 21 passed; development isolation/banner
checks: 9 passed. Full analyzer: the same 58 existing diagnostics as the reviewed
baseline (22 warnings, 36 info), zero errors and zero added/resolved diagnostics.
Sixteen font-backed EN/AR list/detail previews at 360/800 widths passed visual
review. Formatting and `git diff --check` passed.

This prepares source only: no push, merge, mobile/store publication, version
allocation, live configuration/data change or deployment was performed. Fresh
local tests do not establish a deployed end-to-end pass; backend compatibility
and rollout remain the lead's responsibility. Canonical
[release brief](/Users/bshaqra/IdeaProjects/you-care-backend/docs/features/asap-booking-cutoffs-release/brief.md)
and its contract index record scope, dependencies and rollout order.

## 1 November 2026 — preserve the current development baseline

The repository owner requested backing up current local work to GitHub and merging
`security-fixes` into `develop`, ready for subsequent tasks. This consolidation
preserves the existing work; it does not introduce a new feature or publish an app.
The starting source commit was `a931a4f8ee2f8a39c61537c6c77ff1f4f173a3f0`,
and the freshly fetched `origin/develop` was `28049e2`.

Preserved work includes:

- Security hardening and recoverable silent session renewal, durable confirmation
  after rotation, and account/revocation race handling.
- Server-authoritative price access, redacted financial data, company permission
  choices, service-aware menus, and staff editor interaction fixes.
- Dated Housekeeping/Car Wash availability, Furniture availability and disabled
  pricing groups, recurring visit durations, ordering and visit-level actions.
- Laundry compatibility and operational screens, English/Arabic localization,
  generated JSON/Retrofit/localization outputs, and synthetic contract/widget/device
  fixtures, including the isolated historical provider parser harness.
- Manual/tag-triggered store delivery tooling, its validation tests, and shared
  development IDE configurations. A push to `develop` runs checks; store uploads
  require `store-*` tags or manual workflow dispatch.

Existing detailed history and handoffs remain in
[release expansion](docs/features/security-fixes/release-expansion-20261028-provider.md),
[Laundry status flow](docs/laundry-status-flow-dev.md), and
[store CI/CD](docs/store-cicd.md). The shared consolidation brief and unchanged
contract record are maintained in the backend repository under
[`docs/features/repository-consolidation-20261101/`](https://github.com/Redab0/you-care-backend/tree/production-env/docs/features/repository-consolidation-20261101).

Fresh consolidation checks used Flutter 3.35.4 / Dart 3.9.2, Python 3.11.4,
and the official Ruby 3.3.10 Docker image with a read-only mount of `fastlane/`:

- Complete `flutter test`: 597 passed, no failures or skips.
- Python signing-input suite: 11 passed; Ruby store-version suite: 14 passed,
  37 assertions. The host Ruby 2.6 attempt failed on unsupported `filter_map`;
  the pinned Ruby 3.3.10 run passed without a source workaround.
- `flutter analyze --no-pub`: 58 existing diagnostics, zero errors and zero new
  diagnostics compared with a fresh analysis of the starting commit (61).
  The standard analyzer command exits nonzero for these existing warnings/infos.
  One unnecessary import in a new test was removed during consolidation.
- Full `build_runner` and localization regeneration, scoped Dart formatting and
  `git diff --check` passed.
- `flutter build apk --debug --no-pub` passed using the normal production-default
  entrypoint. No app was installed or uploaded.
- `flutter build ios --simulator --no-pub` passed; no simulator/device was launched.

Known release-tooling limitation: Android `build.gradle` currently hardcodes
`versionCode`/`versionName`, so Fastlane's Flutter version arguments do not yet
control Android output versions. This pre-existing current-work issue is retained
for a separate task; consolidation does not change version numbers or configuration.

Local secrets, signing material, caches and generated build products are excluded
from new commits. Adjacent `agent-office`, `technology-stack` and parent-folder IDE
files are outside this repository and remain untouched. Local checks and synthetic
fixtures do not establish a live end-to-end journey. This work does not deploy the
backend, install mobile apps, or upload to Google Play/TestFlight.

## 1 November 2026 — Additional historical source backups

Older worktree source was saved separately on GitHub without changing those working checkouts or merging it into the current application baseline. These backup branches preserve unfinished/historical work and do not imply current validation or deployment.

- [codex/preserved-provider-offline-20261101](https://github.com/Redab0/yourcare-company/tree/codex/preserved-provider-offline-20261101) — b9f3cfea.
- [codex/preserved-workspace-tools-20261101](https://github.com/Redab0/yourcare-company/tree/codex/preserved-workspace-tools-20261101) — 93aa4b43.

Private credential/account/receipt evidence, local exports, dependency/build products and caches remain local. The canonical [preservation manifest](https://github.com/Redab0/you-care-backend/blob/production-env/docs/features/repository-consolidation-20261101/preservation-manifest.json) records the backup refs and scope. No live deployment or app-store publishing occurred.
