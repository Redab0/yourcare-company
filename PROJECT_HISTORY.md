# Provider project history

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


## 7 November 2026 — Customer AI assistant DEV feature branch

Created isolated `codex/customer-ai-assistant` branch for coordinated customer AI
assistant work. Provider application/API behavior: **no change**; existing
catalog, availability, booking and fulfillment/reporting contracts remain in use.
See [repository handoff](docs/features/customer-ai-assistant/handoff.md) for the
canonical backend brief/contract links, scope and validation limits. Original
checkout and unrelated work preserved. Documentation paths/status and
`git diff --check` verified; no Flutter build/test or deployment performed in this
repository. Live DEV AI credentials and integrated journey are tracked centrally.


## 7 November 2026 — Smart Booking Assistant cost revision

The user chose deterministic English/Arabic service guidance and explicit service
choices instead of paid AI calls. Current product naming is Smart Booking Assistant;
no external model or API key is required. The canonical backend brief/contract and
[repository handoff](docs/features/customer-ai-assistant/handoff.md) track this
revision on the existing `codex/customer-ai-assistant` feature branch. Application
behavior/API: **no change** in this repository; existing catalog, availability and
booking/fulfillment/reporting contracts remain authoritative. Documentation paths,
status and `git diff --check` verified. No app build or deployment here; integrated
DEV rollout is tracked by the backend evidence and remains separately verified.

## 7 November 2026 — Smart Booking Assistant DEV activation and API journey

On `codex/customer-ai-assistant`, recorded the lead's DEV activation of guided
backend source `1c83af8` through normal Captain image-only Save. The active
`yourcare:smart-booking-dev-20261107-api` image and digest are recorded in the
[repository handoff](docs/features/customer-ai-assistant/handoff.md); all 33
retained services were unchanged. Provider application code and API-client
contracts: **no change**; no build, UI test or deployment in this repository.

Synthetic DEV order **HK149** passed assistant availability, a **4.000 KWD** server
quote, wallet payment, confirmation and provider visit start/completion, with the
same order visible through customer/provider/admin APIs. The provider detail
read used its Mongo ID; this result does not establish compatibility of the
client's readable-ID refresh path. Read/start retries did
not duplicate financial records; unauthorized customer provider-status access
returned 403 and a skipped transition returned 400. The shared
[booking-flow evidence](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/booking-flow-dev-20261107.md)
records the detailed environment and results rather than another contract here.

Signed-in customer UI checkout remains **unverified**, pending emulator access;
provider/admin UI testing was not run. No paid AI, external payment-gateway
transaction, production change or mobile/store release. Original checkouts and
unrelated work remain preserved. Documentation paths/status and `git diff --check`
verified; Flutter builds/tests were not run for this documentation-only follow-up.

## 7 November 2026 — Provider readable-ID compatibility finding; R2 planned

Read-only review on `codex/customer-ai-assistant` found that provider
`HouseKeepingHistory.id` preserves the backend's readable order ID. The jobs
detail refresh sends that ID unchanged to `/company/requests/{id}`; no separate
Mongo request ID is retained. Independent R1 probes returned customer
`GET /requests/HK149` 200 and provider `GET /company/requests/HK149` 400. Initial
details can render the passed list model, but the Mongo-ID API pass above is
not proof of provider refresh/UI compatibility. Other status endpoints have
separate validation and lookup paths and are not all declared broken.

The existing backend `5514412` controller/`RequestIdDto` fix is in the feature
branch but was absent from the older R1 deployment base. Planned R2 changes
only two compiled backend files for compatible company request-ID validation;
service/auth/payment/ownership behavior and provider application code remain
unchanged. Live R2 activation and readable/Mongo GET results are still pending,
owned by the canonical backend [contract](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/api-contract.md)
and [booking-flow evidence](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/booking-flow-dev-20261107.md).
The [provider handoff](docs/features/customer-ai-assistant/handoff.md) records the
scope and current limits. Documentation-only correction: no provider source,
binary, runtime or UI changes; prior tests were not rerun and no UI pass claimed.


## 7 November 2026 — Verified DEV r2 compatibility and fixture retirement

Documentation-only follow-up on `codex/customer-ai-assistant`. The backend r2
image `eaaab9a8299e` now accepts provider readable and Mongo request IDs using
existing fix `5514412`; public HK149 reads match across roles. The two-file
runtime change preserves service/auth/payment code and 514 original JS files.
Synthetic HK149 remains completed and paid 4.000 KWD with financial state unchanged.
The test company is paused, three test users disabled/old tokens 401; audit records
retained without hard deletion. All 33 retained services / 22 containers unchanged.
Application code and client API declarations: **no change** in this follow-up.
Native UI/gateway tests were not run and production was not changed. The owned
test emulator is stopped with AVD/APK retained; temporary login file removed.
[Canonical live DEV evidence](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/booking-flow-dev-20261107.md)
records source/build/test/deployment references and exact results. Documentation
links, final diffs/status and `git diff --check` were verified; earlier client
tests were not rerun.
