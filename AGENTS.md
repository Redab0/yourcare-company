# Business App Agent Handoff

Updated: 2026-08-22

This is the operational handoff for Codex agents working on the YourCare business/company Flutter app. Read it before editing. The older `README.md` contains generic and potentially stale demo-mode information; source code, tests, this file, and the live API contract are authoritative.

## Repository

- App: YourCare business/company app
- Package: `cleaning_service_driver`
- Version: `2.0.1+1`
- Path: `/Users/bshaqra/IdeaProjects/cleaning/driver/cleaning_service_driver`
- Git branch: `develop`
- Remote: `git@github.com:Redab0/yourcare-company.git`
- Customer app: `/Users/bshaqra/IdeaProjects/cleaning/customer/cleaning_service`
- Corporate/admin portal: `/Users/bshaqra/StudioProjects/yourcare_corporate`

## Non-Negotiable Working Rules

- The working tree has substantial intentional uncommitted work. Run `git status --short` first.
- Never reset, revert, clean, overwrite, or discard existing changes unless the user explicitly requests it.
- If unrelated files change unexpectedly while working, stop and ask the user how to proceed.
- Preserve existing architecture and visual language. Use `AppTheme`; do not introduce page-local color constants when a theme token belongs in the theme.
- Use the app's rotating-logo loader for page/API loading. Do not add a native `CircularProgressIndicator` where the branded loader is expected.
- Keep Arabic and English localization in sync. Do not hardcode user-facing strings.
- Do not commit API keys, Firebase files, credentials, tokens, or other secrets.
- Verify mutable backend contracts against live Swagger before implementing API changes.
- Do not send API request bodies as raw `Map<String, dynamic>` or other generic `Map` payloads. Create explicit request-body model classes and generate serialization with `retrofit_generator`/`json_serializable`, matching the rest of the app.
- Do not assume old embedded car-wash pricing contracts are still valid.
- Do not add a second API request when already-loaded/cached data is available.

## Current Working Tree

At handoff, the tree is intentionally dirty across Android/iOS project settings, car-wash package models/repository/UI, all request-detail screens, company availability, maps/share, localization, pubspec, and tests.

Important new untracked source files at handoff:

- `lib/core/utils/share_utils.dart`
- `lib/data/models/schedule/hourly_availability_schedule.dart`

Important currently modified areas:

- `lib/features/screens/schedule/employee_availability_screen.dart`
- `lib/features/bloc/schedule/employee_availability_bloc.dart`
- `lib/features/bloc/schedule/employee_availability_state.dart`
- `lib/data/models/car_wash/car_wash_models.dart`
- `lib/data/repositories/car_wash/car_wash_repository.dart`
- `lib/features/screens/car_wash/car_wash_pricing_screen.dart`
- `lib/features/screens/jobs/*_job_details_screen.dart`
- `lib/components/open_map_action.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- generated localization files and related tests

This list is a snapshot, not permission to modify or remove anything. Re-run `git status --short` for the actual state.

## Stack And Structure

- Flutter/Dart SDK constraint: `^3.6.1`
- State: `flutter_bloc`, `equatable`
- Navigation: `go_router`
- DI: `get_it`
- Network: `dio`, `retrofit`, `json_serializable`
- Persistence: `flutter_secure_storage`, `shared_preferences`
- Localization: Flutter gen-l10n, source ARB files in `lib/l10n`
- Font: bundled `Zain`
- Onboarding: `showcaseview: ^5.1.0`

Primary entry points:

| Concern | File |
| --- | --- |
| App startup | `lib/main.dart` |
| Dependency registration | `lib/core/di/dependency_injection.dart` |
| Router | `lib/core/router/router.dart` |
| API/Dio configuration | `lib/core/api/api_client.dart` |
| Main navigation | `lib/features/screens/home/main_layout.dart` |
| Home service policy | `lib/features/screens/home/business_home_service.dart` |
| Theme | `lib/core/themes` |
| API services | `lib/data/services` |
| Repositories | `lib/data/repositories` and legacy `lib/data/repos` |
| Screens | `lib/features/screens` |
| BLoCs/Cubits | `lib/features/bloc` |
| Localization source | `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` |

## Environment And Commands

Current API selection in `lib/core/api/api_client.dart`:

- Development: `https://dev-be-cleaning.yourcarehere.com/api`
- Production constant: `https://be-cleaning.yourcarehere.com/api`
- Current `baseUrl`: development
- Business requests include `channel: MANAGER`
- Locale is sent using `Accept-Language`

Live API documentation:

- `https://dev-be-cleaning.yourcarehere.com/api/#/`

Common commands:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Run generators after changing Retrofit declarations or JSON-serializable models. API request bodies should use dedicated model classes, not generic `Map` bodies. Edit ARB files first, then run `flutter gen-l10n`; do not hand-maintain generated localization Dart unless the existing workflow requires it.

## Product Service Model

Backend service discriminators are case-sensitive:

| Service | API value | Booking behavior | Business setup |
| --- | --- | --- | --- |
| Deep cleaning | `deepCleaning` | Quote/bid based | Auto-bid and deep-cleaning requests |
| Housekeeping | `houseCleaning` | Direct company booking | Pricing/config and hourly availability |
| Furniture cleaning | `upholsteryCleaning` | Direct company booking, not bids | Furniture pricing/config and hourly availability support |
| Car wash | `carWash` | Direct company/package booking | Packages, vehicle assignment, area fees, hourly availability |

Do not make furniture cleaning bid-based. Deep cleaning remains the bid-based flow.

## Startup, Profile Cache, And Navigation

- Bottom navigation must remain two items only: Dashboard and Profile.
- `MainLayout` preloads `/business/my-business` through `CompanyProfileCubit` when the app launches.
- Chat/conversation bootstrap runs in the background and must not block the visible loading state.
- Company Profile must consume the cached profile and must not call `/business/my-business` again when the cached value exists.
- `CompanyProfileCubit.preload(force: false)` is the cache-aware path.
- Profile updates must call `setProfile` so home visibility updates without a redundant fetch.

## Home Service Visibility

`CompanyProvidedService` contains:

- `deepCleaning`
- `houseCleaning`
- `upholsteryCleaning`
- `carWash`

`BusinessHomeService` combines the company profile's `services` list with permissions. Preserve these rules:

| Home item | Required company service |
| --- | --- |
| New requests / cleaning requests | `deepCleaning` |
| Auto bidding | `deepCleaning` |
| Housekeeping configuration | `houseCleaning` |
| Furniture configuration | `upholsteryCleaning` |
| Car-wash configuration | `carWash` |
| Upcoming jobs | Any known provided service |

If a company has only housekeeping, car-wash and furniture configuration entries must not appear. The New Requests entry is a deep-cleaning feature and must be hidden without deep cleaning.

Furniture configuration uses `assets/images/ic_furniture_config.png`.

## Showcase Onboarding

- Core helper: `lib/features/onboarding/business_showcase.dart`
- The setup tour must highlight only home entries already visible from the service/permission policy.
- Inner setup journeys also contain showcase steps.
- While a showcase is running, user interaction and back navigation are intentionally blocked using `BusinessShowcaseInteractionLock`, `AbsorbPointer`, and `PopScope` behavior.
- Preserve the help/replay affordance.
- New service setup entry points should be added to the same visibility policy and tour policy, not hardcoded separately.

## Shared Hourly Availability

Housekeeping and car wash now use the shared hourly availability screen:

- UI: `lib/features/screens/schedule/employee_availability_screen.dart`
- Mapper: `lib/data/models/schedule/hourly_availability_schedule.dart`
- BLoC: `lib/features/bloc/schedule/employee_availability_bloc.dart`
- Models: `lib/data/models/schedule/cleaner_availability.dart`

Supported service values include `houseCleaning`, `carWash`, and `upholsteryCleaning`. Deep cleaning is intentionally excluded.

API contract:

```text
GET    /company/cleaner-availability?serviceType={serviceType}
POST   /company/cleaner-availability
PATCH  /company/cleaner-availability/{id}
DELETE /company/cleaner-availability/{id}
```

Create body:

```json
{
  "dayOfWeek": 4,
  "startHour": 8,
  "endHour": 17,
  "totalCleaners": 5,
  "serviceType": "houseCleaning"
}
```

Critical contract detail:

- GET must include `serviceType` as a query parameter.
- POST must include `serviceType` in the body.
- PATCH of an existing slot must omit `serviceType`.

Current UI behavior:

- Seven selectable day chips.
- Twenty-four compact one-line hourly rows per day.
- Each row contains the hour, enabled switch, and worker-count field.
- The day summary uses one compact toggle that enables or disables the entire day.
- Disabling a day keeps a local backup; re-enabling before saving restores its previous hours and worker counts.
- Enabling an empty day enables all hourly rows.
- A compact copy/apply card opens a multi-day selector.
- Copying applies the selected day independently to the chosen target days.
- The screen keeps a local dirty draft and saves explicitly.
- Only dirty days are replaced.
- The mapper expands API ranges into hourly cells and compresses adjacent enabled cells with equal worker counts back into API ranges.

Do not return to a separate house/car-wash availability implementation. The latest requested design is the compact single-toggle day summary.

## Car-Wash Package Configuration

Relevant API surface:

```text
GET    /business-categories/car-wash
GET    /business/my-business/car-wash-packages
POST   /business/my-business/car-wash-packages
PATCH  /business/my-business/car-wash-packages/{packageId}
DELETE /business/my-business/car-wash-packages/{packageId}
PATCH  /business/my-business/car-wash-pricing
POST   /business/my-business/car-wash-area-fees
DELETE /business/my-business/car-wash-area-fees/{areaId}
```

Vehicle types come from the business-categories response. Show the localized vehicle name beside every package price field.

Create/update package shape:

```json
{
  "titleEn": "Exterior Wash",
  "titleAr": "Localized title",
  "descriptionEn": "Full exterior wash and dry",
  "descriptionAr": "Localized description",
  "pricing": [
    {
      "vehicleTypeId": "vehicle-id",
      "price": 0
    }
  ],
  "discountPercentage": 10,
  "duration": 30,
  "workingHours": [
    {
      "dayOfWeek": 0,
      "startTime": "09:00",
      "endTime": "21:00"
    }
  ]
}
```

Rules:

- A package has shared content and working hours but separate prices per vehicle type.
- Vehicle price `0` is valid and must not fail validation.
- Package working-hour selection uses dropdowns like company availability, not a clock picker.
- Display the resolved/mapped price returned on package objects.

Vehicle-package assignment body:

```json
{
  "pricing": [
    {
      "vehicleTypeId": "vehicle-id",
      "packages": [
        {
          "packageId": "package-id"
        }
      ]
    }
  ]
}
```

Do not send `price` in `/business/my-business/car-wash-pricing`; assignment sends package IDs only.

## Furniture Configuration

Relevant APIs include:

```text
GET   /business-categories/active
GET   /business/my-business/upholstery-packages
PATCH /business/my-business/upholstery-pricing
```

Preserve the current UX:

- Furniture config is a single page, not a page embedded inside another page.
- Use `assets/images/ic_furniture_config.png`.
- Use only the branded rotating-logo loader; do not stack two loaders.
- All item sections start collapsed.
- Expanding an item is separate from activating/enabling it.
- A company can set prices for each item size.

The direct furniture customer journey currently hides schedule selection. Business furniture request details should not present date/time as a customer-selected appointment while that policy is disabled.

## Requests And Request Details

Company list endpoint:

```text
GET /company/requests
```

Generic request actions live in `lib/data/services/jobs/jobs_service.dart`.

Generic extra invoice endpoint:

```text
PATCH /requests/{id}/extra-fees
```

Use it for every request type. The action should appear only when a request is `confirmed` or `inProgress`. Do not restore type-specific extra-fee endpoints.

Request-detail requirements:

- Show special notes for all service types when present.
- Car-wash details show localized vehicle type and package title from each `CarWash.vehicles` item.
- Do not replace returned package/vehicle values with fixed labels.
- Car-wash details may include package description, duration, mapped price, delivery fee, and extra fees.
- Total displayed price must use the top-level request total where appropriate; do not silently show only `CarWash.totalPrice` when top-level extra fees make the request total larger.
- Customer address and map location are currently restored in business request details.
- Shared request text should include the Google Maps URL when coordinates are valid.

## Maps And Sharing

- Map action: `lib/components/open_map_action.dart`
- iOS-safe share helper: `lib/core/utils/share_utils.dart`
- Use `shareTextFrom(context, text)` so `share_plus` receives a non-null `sharePositionOrigin`, which is required for iPad/iOS popovers.
- `OpenMapAction.googleMapsLink` rejects null, non-finite, out-of-range, and `(0, 0)` coordinates.
- Use `https://www.google.com/maps/search/?api=1&query=lat,lng` in shared request text.
- Do not build/run on the user's connected iPad unless explicitly requested; the user tests iOS sharing themselves.

## Back Navigation

Inner journeys must always expose a working back button. Prefer the shared `BusinessBackButton` with an appropriate fallback route. The user previously found that a back button disappeared after navigating config -> pricing -> back, so do not rely solely on an imperative navigator stack being present.

## UI And Localization Conventions

- Use `AppTheme` and existing components.
- Use bundled assets for release-critical custom icons; unsupported runtime glyphs can become gray squares in signed builds.
- Respect phone, foldable, and tablet widths. Prefer constraints/layout calculations over per-asset hardcoded offsets.
- Keep text readable and avoid undersized labels.
- Use direction-aware icons such as `Icons.arrow_forward_ios` only with explicit RTL handling or use directional back components.
- The standard page loader is `AppIconSpinner` from `lib/components/loading_overlay.dart`.
- Source localization changes go into both ARB files.

## Verification

Minimum validation after relevant changes:

```bash
dart format <changed-dart-files>
flutter gen-l10n
flutter analyze
flutter test
```

For focused availability work:

```bash
flutter test test/data/models/schedule/cleaner_availability_test.dart
flutter analyze lib/features/screens/schedule/employee_availability_screen.dart lib/data/models/schedule/hourly_availability_schedule.dart lib/features/bloc/schedule/employee_availability_bloc.dart
```

At the last availability checkpoint, the focused analyzer was clean and the schedule tests passed. A prior full test run passed 62 tests. Full analysis has existing informational/warning debt, so distinguish pre-existing diagnostics from regressions and report both accurately.

## Cross-App Coordination

When a backend request/response model changes, inspect all three clients where relevant:

| Client | Path |
| --- | --- |
| Business app | `/Users/bshaqra/IdeaProjects/cleaning/driver/cleaning_service_driver` |
| Customer app | `/Users/bshaqra/IdeaProjects/cleaning/customer/cleaning_service` |
| Corporate/admin | `/Users/bshaqra/StudioProjects/yourcare_corporate` |

Do not copy implementation blindly. Preserve each app's role, authorization channel, route structure, and UI components.

## Recommended First Steps For The Next Agent

1. Read this file and the user's latest request.
2. Run `git status --short` and inspect diffs in every file you need to touch.
3. Trace the existing model -> service -> repository/use case -> BLoC -> screen flow before editing.
4. Check live Swagger for any API request involving current backend work.
5. Reuse existing theme, localization, branded loader, back button, and showcase helpers.
6. Format and run focused tests/analyzer first, then broader checks when feasible.
7. Summarize changed files, behavioral result, and any unrun validation without hiding pre-existing warnings.
