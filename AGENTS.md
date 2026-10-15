# YourCare company / service-provider app

## Shared technical-lead workflow

Apply this workflow to each feature. The technical lead owns the shared brief, contract decisions, repository assignments and integrated verification.

| Repository | Root in this workspace | Primary ownership |
| --- | --- | --- |
| Backend | `/Users/bshaqra/IdeaProjects/you-care-backend` | API contracts, authorization, persisted business rules, payments and events. |
| Customer | `/Users/bshaqra/IdeaProjects/cleaning/customer/cleaning_service` | Customer discovery, booking, checkout and tracking. |
| Provider (driver folder) | `/Users/bshaqra/IdeaProjects/cleaning/driver/cleaning_service_driver` | Company pricing, availability, offers, teams and fulfillment. |
| Corporate admin | `/Users/bshaqra/StudioProjects/yourcare_corporate` | Administrative configuration, operations, permissions and reporting. |

These are the actual repository roots; the attached `customer` and `driver` folders are parent directories. Resolve checkout paths when working on another machine.

1. **Read before coordinating.** Before coordinating any cross-project feature, explicitly open and read the root `AGENTS.md` in **all four repositories**, plus applicable nested guidance. Do not substitute an earlier summary for those reads. Inspect each repository's current status and relevant existing diffs; preserve unrelated work.
2. **Maintain one shared brief.** Reuse the feature's existing canonical brief or create `docs/features/<feature-id>/brief.md` in the backend repository. Record the problem, actors, scope/non-goals, acceptance criteria, affected repositories, dependencies, target environment and unresolved decisions. Link the same brief from assignments and handoffs rather than maintaining competing copies.
3. **Maintain one shared API contract.** Reuse the canonical feature contract or create adjacent `api-contract.md` in the backend repository. Specify method/path, authentication/roles/ownership, headers, request and response examples, types, required/optional/null fields, envelopes, errors, pagination and identifiers. Include service discriminators, order/visit/payment transitions, KWD versus fils, Kuwait/UTC semantics, retries/idempotency and events where applicable. Record compatibility with installed clients, rollout order and migration needs. For a feature with no API changes, explicitly identify the existing contract and state that it is unchanged.
4. **Resolve dependencies before implementation.** Compare actual backend controllers/DTOs/guards/serialization and affected client models/services with the shared contract. Distinguish proposed changes from current behavior and deployed availability. Resolve contract mismatches before dependent implementation; keep genuinely unresolved decisions visible. The lead updates the canonical contract and communicates revisions to every affected implementer.
5. **Assign bounded work by repository.** In the brief, give each affected repository an owner, allowed scope/files, deliverables, contract dependencies, acceptance checks and handoff requirements. Mark each unaffected repository `no change` with a reason. Parallelize independent work with non-overlapping file ownership; keep shared-contract decisions with the lead. Each handoff reports changed files, contract impact, checks and open issues.
6. **Verify the integrated journey.** Run the repository checks relevant to the change, then trace the affected journey across customer → backend → provider → admin as applicable, using a confirmed test environment and shared fixture/order identifiers. Check success, authorization failures, validation/errors, retries, payment/status consistency and relevant localization/time/money behavior. Record expected versus actual results, commands, environment and evidence in the brief. Identify checks that were blocked, mocked or not run; local suites alone do not establish an end-to-end pass.
7. **Report by repository.** Report changes, validation results and open issues separately for backend, customer, provider and admin, including explicit `no change` entries. Follow with the integrated-journey result, remaining dependencies and rollout requirements. Do not claim completion of an unverified journey or imply that local changes have been deployed.

## Scope and related projects

This Flutter app (`cleaning_service_driver`) manages company profiles, service pricing and availability, staff/teams, bids, job fulfilment, invoices, documents and reports. It is the provider/business app, including worker workflows, despite the package's driver name.

Related repositories available in this workspace:

| Project | Local checkout | Responsibility and implementation |
| --- | --- | --- |
| Backend | `/Users/bshaqra/IdeaProjects/you-care-backend` | Shared APIs, authorization, booking/pricing, persisted order state and payment processing; NestJS modules/controllers/services, validated DTOs and Mongoose. |
| Customer app | `/Users/bshaqra/IdeaProjects/cleaning/customer/cleaning_service` | Discovery, booking, checkout and order history; Flutter with BLoC, GetIt, GoRouter and Dio/Retrofit. |
| Admin portal | `/Users/bshaqra/StudioProjects/yourcare_corporate` | Platform configuration, companies/users, request administration, refunds and analytics; also Flutter with BLoC/Cubit, repositories/use cases, GetIt, GoRouter and Dio/Retrofit. |

**Cross-project work:** agree on the feature brief, API request/response contract, authorization and order status changes across affected projects **before implementing dependent screens or endpoints**. Compare backend DTOs/controllers and affected clients; verify the target environment's contract. Report mismatches instead of guessing or copying another client's assumptions.

## Structure and conventions

| Location | Purpose |
| --- | --- |
| `lib/main.dart` | Normal Firebase, dependency and app startup. |
| `lib/core/` | API/session handling, DI, routing, storage, themes and shared helpers. |
| `lib/data/models`, `lib/data/services`, `lib/data/repositories` | JSON models, Retrofit APIs and concrete repositories. |
| `lib/domain/usecases` | Operations used by presentation logic. |
| `lib/features/bloc`, `lib/features/screens` | BLoCs/Cubits and feature screens. |
| `lib/components`, `lib/l10n`, `assets/` | Shared UI, bilingual localization and bundled assets. |
| `test/`, `docs/`, `android/`, `ios/`, `web/` | Regression tests, feature notes and platform projects. |

- Follow the existing screen → BLoC/Cubit → use case → repository → service/model flow. This is pragmatic Clean Architecture: use cases import concrete data repositories/models. Laundry has local Cubits calling repositories; chats also uses `lib/features/chats` and legacy `lib/data/repos`. Follow the relevant feature rather than imposing new layers.
- Register dependencies in `lib/core/di/dependency_injection.dart`; preserve GetIt `sl` lifetimes (services/repositories generally lazy singletons, BLoCs generally factories). Shared providers live in `lib/core/providers/app_bloc_provider.dart`.
- Use GoRouter routes in `lib/core/router/router.dart`, existing route names and typed extras. Preserve BLoC event/state, Equatable and `copyWith` patterns.
- Reuse `AppTheme`, `BusinessBackButton`, `LoadingOverlay`/`AppIconSpinner` and existing onboarding helpers. Use `context.l10n`; update both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` and check RTL.
- Keep company-profile caching through `CompanyProfileCubit.preload`/`setProfile`. Extend service/permission visibility in `lib/features/screens/home/business_home_service.dart` and its onboarding policy.

## Setup and commands

Use a Flutter/Dart SDK satisfying the lockfile: `pubspec.yaml` declares Dart `^3.6.1`, but `pubspec.lock` requires Dart `>=3.9.0 <4.0.0` and Flutter `>=3.35.1`. Also provide the target platform toolchain. Android/iOS startup uses Firebase; retain the project's platform configuration and keep credentials out of commits. Android release signing is configured in `android/app/build.gradle`; iOS dependencies are in `ios/Podfile`.

Run from the repository root:

```sh
flutter pub get
flutter run
flutter build apk --debug
flutter analyze
flutter test
```

Confirm the selected device and API environment before running; do not launch on the user's connected iPad unless requested. No custom task scripts were found. Lints come from `analysis_options.yaml` and `flutter_lints`.

After changing JSON models or Retrofit declarations:

```sh
dart run build_runner build --delete-conflicting-outputs
```

After editing ARB localization sources:

```sh
flutter gen-l10n
```

Use `dart format` with the changed Dart file paths. Regenerate generated Dart files instead of editing them manually. The README's older demo-mode claims are not a setup contract for normal authenticated startup.

## Extending services

Trace the closest existing feature through all layers and its tests before adding a service. Preserve API discriminator spelling, typed request bodies, service/permission gates, localized configuration and request-detail routing.

| Reference | API discriminator | Pattern to reuse |
| --- | --- | --- |
| Housekeeping | `houseCleaning` | `lib/data/services/housekeeping`: pricing, area fees and shared availability; recurring visits use their own `frequencyDateId`. |
| Car Wash | `carWash` | `lib/data/services/car_wash`: standalone packages with vehicle-specific prices; vehicle assignments send package IDs without prices. Zero package prices are valid. |
| Furniture Cleaning | `upholsteryCleaning` | `lib/data/services/upholstery`: category/item-size pricing; preserve existing request presentation helpers. |
| Deep Cleaning | `deepCleaning` | `lib/data/services/requests` and `lib/data/services/auto_bid`: offers and auto-bidding; New Requests and auto-bid home entries require this service. |

Shared hourly availability in `lib/data/services/schedule` supports housekeeping, car wash and furniture: GET includes `serviceType` in the query, create includes it in the body, update omits it. Laundry already exists under `lib/data/services/laundry`; preserve its separate invoice/payment/status flow described in `docs/laundry-status-flow-dev.md`.

## API, authentication, payments and status

- Reuse `lib/core/api/api_client.dart` and `lib/core/api/session_request_interceptor.dart`: `channel: MANAGER`, secure-storage Bearer access token, `Accept-Language` and `locale`. Keep bounded credential lookup, cancellation and error handling. Do not assume automatic token refresh exists.
- Check API selection before any network work: the current `ApiClient.baseUrl` selects production. It does not read `API_ENV`; a build define alone does not switch this client's environment.
- `lib/main_documents_preview.dart` and `lib/main_laundry_preview.dart` require the API constant to select development. The preview command in `docs/laundry-status-flow-dev.md` that supplies only `API_ENV=development` does not switch this checkout.
- Use dedicated JSON-serializable request models with Retrofit, not raw map bodies. Follow existing response wrappers and preserve server errors. Keep HTTP logging metadata-only and debug-only.
- Use `lib/data/services/jobs/jobs_service.dart` and server-returned state for order actions. Normal start/completion follows confirmed → inProgress → completed; recurring housekeeping actions target the visit ID and must not fall back to the whole order when it is missing.
- Reuse `lib/core/utils/request_status_enum.dart` and `lib/core/utils/request_helpers.dart` for presentation. Display aliases and unknown values do not establish valid outgoing transitions; confirm accepted values and permissions against backend DTOs before changing status actions.
- Payment success comes from backend payment/invoice state. This app manages/displays invoices; checkout belongs to the customer flow and payment processing to the backend. Extra invoices are available for confirmed/inProgress requests and blocked by an unpaid prior invoice. Reuse total/invoice helpers and three-decimal KWD formatting.
- Laundry completion requires both payment and invoice to be paid; shared terminal order status overrides stale laundry detail state. Do not apply generic job transitions to laundry.
- Use `lib/core/utils/kuwait_schedule.dart`: store appointment instants in UTC and display Kuwait time; legacy offsetless timestamps mean Kuwait wall time. Do not serialize a display projection as a UTC instant.

## Before reporting completion

- Start with `git status --short`; preserve existing user changes and keep the diff scoped.
- For code changes, format changed Dart files, run applicable generators, focused regression tests, then `flutter analyze` and `flutter test`. Build the affected platform when runtime/platform changes warrant it.
- API changes must cover serialization/auth/status behavior; service UI changes must cover visibility, error/loading states and English/Arabic layouts. Existing coverage includes `test/data/services/api_request_body_typing_test.dart`, `test/data/services/request_status_actions_test.dart` and `test/features/screens/jobs/request_details_actions_test.dart`.
- Review `git diff --check` and `git diff`. For documentation-only changes, verify named paths/commands and factual claims; app builds/tests are unnecessary unless behavior changed.
- Report changed files, checks actually run, failures or unrun checks, and unresolved contract questions. Do not present old test counts or unverified deployment behavior as current evidence.
