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
