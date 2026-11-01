# Provider release expansion — 28 October 2026

Repository: `/Users/bshaqra/IdeaProjects/cleaning/driver/cleaning_service_driver`, branch `security-fixes`. Initial28 October implementation and subsequent29 October verification. No staging, commits, pushes, production calls or deployment by this owner; later isolated Samsung fixture checks are recorded below.

Canonical decisions remain in the backend checkout:
`/Users/bshaqra/.codex/worktrees/security-fixes-backend/you-care-backend/docs/features/security-fixes/release-expansion-api-contract.md`.
This handoff supplements the earlier security/session reports; their old counts do not describe this release expansion.

## Staff capabilities and price access

- `permission_copy.dart` maps all 69 stable/compatibility keys in the provider catalog to English and Arabic action names and short descriptions. The visible copy avoids technical read/write terms. Existing identifiers, including legacy spellings, remain unchanged.
- `PermissionEditor` changes one selected ID at a time. Partial selections remain partial. Existing unknown IDs absent from the returned catalog remain selected and appear as retained access; the editor does not invent new assignments for them.
- Create and edit use a separate **Can see prices** checkbox. New staff start unchecked. Only a current owner/admin may change it; managers do not see an editable control and omit the field. Staff roles remain manager/worker/driver, preventing creation or promotion of a business owner through this form.
- Staff editing loads the fresh target before displaying an editable form. An unchanged price checkbox is omitted from updates; explicit `false` is serialized rather than dropped. The flag is a strict boolean when present. Local profile edits cannot grant the current actor price access.
- Effective legacy defaults follow the revised29 October acceptance contract: missing flags preserve access for all company staff, including workers; explicit false remains denied, and owners/admins are normally permitted. Unknown/unresolved client authority starts denied. Backend authorization and actor-capped permission delegation remain authoritative.

Primary files: `lib/components/{permission_copy,permission_editor,price_access_checkbox}.dart`, staff create/details screens, `lib/data/models/{auth/login_response,staff/create_user_model,staff/update_user_model}.dart`, both ARBs and generated localization/model files.

## Revocation, renewal and cached data

- `PriceAccess` tracks an account generation and a separate access epoch. A server `pricesHidden:true` response immediately forces denial, including when the cached role still says owner/admin following a role downgrade. This happens synchronously before native storage I/O.
- `PriceAccessInterceptor` recognizes current-user profile responses and outer/nested redaction markers. An edited staff target's `canSeePrices:false` does not change the requesting actor's authority. Reads/writes are bounded; a slow keychain does not delay hiding or make operational redacted responses unusable.
- In-flight responses carry their original access epoch. Account/access changes reject stale responses before publication. A blocked old profile write cannot restore the revoked UI when it finishes. The queued denial is persisted when native storage becomes available; a physical native write failure cannot promise durable persistence, but in-memory access remains denied.
- Complete local credential records add only local denial/recovery snapshots. The renewal API body is unchanged. Pending lost-response recovery remembers the pre-request authorization snapshot, so an old renewal response cannot undo a newer revocation after process restart. Replacement credentials still commit without logging the user out. A later fresh authoritative own-profile response can restore a grant.
- Epoch changes clear company-profile caches and rebuild feature BLoCs containing requests, bids, pricing, reports and staff data. Authentication remains outside this keyed subtree; capability changes do not close an active login/logout handler. Locale and chat-launcher singletons are retained through value providers. Resume refreshes own-profile authority after ensuring the current session.

Primary files: `lib/core/access/*`, API client and first synchronous request interceptor, secure storage, session credentials/coordinator/lifecycle, app providers, router and `main.dart`.

## Monetary surface coverage

`PriceOnly` removes monetary subtrees, and lazy financial route guards prevent construction/fetches through saved links. Redacted/missing values remain nullable; explicit zero remains a valid visible amount when authorized.

| Surface | Restricted behavior |
| --- | --- |
| Housekeeping, deep cleaning, furniture and car-wash request lists/details | Hide totals, underlying option/vehicle/item prices, extra invoices and price actions; retain job/customer/schedule/fulfillment information. |
| New requests, bid composers, auto-bid configuration | Hide monetary offers/composers and deny financial-only configuration routes. |
| Calendar and chat request previews | Hide structured order totals at every preview/detail level. |
| Laundry details/invoices | Preserve items, quantity/weight, operational status and fulfillment; hide unit prices, totals, minimum charge and invoice create/send actions. |
| Laundry settings/catalog | Deny financial catalog/pricing access. Working hours/same-day changes preserve unknown minimum charge without inventing or submitting zero. |
| Housekeeping and car-wash pricing | Deny financial configuration while keeping independent availability reachable. |
| Furniture pricing/availability | Do not fetch/render/save prices when denied; preserve independent availability. |
| Reports, KPI/statistics, documents | Hide home entries and deny financial-only screens and deep links. |
| Share text and nested extra-invoice cards | Omit structured monetary text/subtrees when restricted. |
| Campaign badges/details | Require current price access, `companyCampaignVisible:true` and absence of redaction. No marker means no badge; cached legacy registration-gift fallback is removed. |

Affected models include the common request interface and housekeeping/deep/furniture/car-wash/laundry histories, nested option and vehicle prices, request/business-offer invoices and laundry settings. Company references accept either a bare ID or populated object without inventing company details. Model/Retrofit generators were run rather than patching generated code manually.

An existing nested raw-map AutoBid response generated invalid `Map.fromJson` code. A small typed payload wrapper now preserves the same wire data and makes regeneration reproducible.

This client does not scrub arbitrary human-entered chat text or uploaded documents. Structured response redaction and financial mutation authorization depend on the matching backend release. Host fixtures establish parser/UI behavior; they do not establish a deployed end-to-end authorization pass.

## Verification and fixture provenance

SDK used: `/Users/bshaqra/development/flutter/bin/flutter` and its matching Dart executable. The initial28 October host commands below ran from the provider repository without a device or production API. Later29 October host/device evidence appears separately below.

| Check | Result/evidence |
| --- | --- |
| Focused authority/parser/storage/renewal/widget checks | **77 passed**, `/private/tmp/provider-release-focused-final.txt`. |
| Final complete `flutter test --reporter expanded` | **550 passed, zero failures/skips**, `/private/tmp/provider-release-tests-frozen.txt`. |
| Final `flutter analyze` | **61 existing diagnostics, zero errors and zero new diagnostics** after comparing severity/message/path/rule with the pre-edit baseline. Flutter exits 1 for those existing warnings/lints. Baseline `/private/tmp/provider-release-baseline-analyze.txt`; final `/private/tmp/provider-release-analyze-frozen.txt`. |
| `flutter gen-l10n` | Passed after bilingual source edits. |
| `dart run build_runner build --delete-conflicting-outputs` | Passed; latest generator log `/private/tmp/provider-release-build-runner.txt`. |
| `git diff --check` | Passed. |
| Final `flutter build apk --debug` | **Passed**, 16.2-second Gradle build; `build/app/outputs/flutter-apk/app-debug.apk`. Log `/private/tmp/provider-release-build-apk-frozen.txt`. |

The focused regressions cover strict booleans; legacy defaults; partial/unknown permissions; create/edit serialization; owner versus manager controls; all five service redacted parsers; explicit zero; campaign marker gating; cached-owner role downgrade; late renewal/profile/native writes; persisted lost-response recovery; English/Arabic actual list/detail/widget revocation without logout.

`test/fixtures/release_expansion_backend.json` is a reduced synthetic fixture from the backend owner's **version 2** generated HTTP contract fixture. Allowed/restricted company requests use real CompanyController and global response-policy/Pagination/Translation interceptors, preserving `response.data.data` and locale in `response.data`. Four provider tests use the actual generated `JobsService` against a local Dio adapter and verify the envelope, nullable nested monetary values, marker, eight visit dates, effective staff flags and populated/bare company IDs. Source SHA-256 recorded in the fixture: `27ff56e8d96815d97f5fe3276ef01b0482ff98d291ba264c93a802983e6ee0fa`. Backend repositories/payment/capacity adapters are synthetic; no real customer data or payment calls are used.

### Existing-test triage

No fresh full suite was run before source edits, so the historical thirteen-failure reference is not claimed as a newly measured baseline. The first post-edit run failed because older positive fixtures did not grant access and several Laundry tests used stale controls/expectations. Those tests were corrected against the actual current UI and meaningful assertions retained: same-day cutoff dropdowns, current invoice buttons and duplicate/timeout checks, availability-only toggles preserving prices, the actual bulk-price editor rejecting zero, localized 24-hour dropdown values and malicious legacy discount drafts. No failure was hidden with a skip or warning waiver. The final full suite above is green.

### Physical-device harness handed to the lead

`integration_test/release_expansion_device_test.dart` uses the SDK integration-test dependency and mounts the actual permission editor, price checkbox, request card, full housekeeping detail and campaign badge with synthetic local feature BLoCs. It does not import normal app main or initialize Firebase, production DI or sockets. Unexpected HTTP is blocked before opening a socket. Host versions of all four EN/AR journeys pass.

The harness captures `provider-permissions-en`, `provider-permissions-ar`, `provider-prices-hidden-en` and `provider-prices-hidden-ar` after converting the Flutter surface. The lead owns running it in the separate sanitized Samsung app copy; this provider handoff does **not** claim that device run passed. No installed production account was touched by this owner.

## Preserved work and release dependencies

- Pre-existing housekeeping duration/focus/order, dated availability, furniture pricing/availability and session-confirmation work was retained and is included in the green full suite. Their entire pre-existing diff is not attributed to this task.
- Recorded pre-task hashes still match `.gitignore`, `README.md`, Android Gradle, iOS Xcode project, both existing workflow files, Fastlane files and CI scripts. The existing version remains `3.0.1+1`. The authorized SDK integration-test addition and lockfile dependencies are the only new dependency change.
- No native policy change was needed for this Dart feature. No iOS/native-device rebuild was run by this owner. The debug APK verifies Android compilation, not production API or store-release behavior.
- Rollout must coordinate the updated provider with backend actor-scoped redaction/authorization and fresh computed login/profile/renewal flags. Older strict non-null monetary models cannot be assumed compatible with newly omitted fields. Permission IDs remain stable; no data migration or forced re-login is introduced here.

Code is frozen after the final checks. All provider changes remain unstaged for the lead's scoped review and integration.

## Development readiness follow-up

The lead's environment-isolation changes were inspected without changing application source. The following focused checks explicitly used `--dart-define=API_ENV=development`:

```sh
/Users/bshaqra/development/flutter/bin/flutter test --dart-define=API_ENV=development --reporter expanded test/core/api/firebase_environment_test.dart test/core/api/telemetry_policy_test.dart test/core/api/session_request_interceptor_test.dart test/core/security/session_persistence_test.dart test/core/security/session_confirmation_test.dart test/core/security/session_cache_test.dart
/Users/bshaqra/development/flutter/bin/flutter test --dart-define=API_ENV=development --reporter expanded test/core/api/stack_hardening_test.dart
```

Results: **41/41 plus 8/8 passed (49 total)**. Logs: `/private/tmp/provider-development-readiness-focused.txt` and `/private/tmp/provider-development-stack-tests.txt`. These cover Firebase/RemoteConfig-disabled initialization and notification cleanup, telemetry disabled, exact-origin/cancellation/session request preparation, native persistence/recovery faults, committed-session confirmation, profile cache generations, development API/chat origin, development storage/logout isolation and the visible DEV banner.

An earlier, broader development command also selected `session_renewal_test.dart` and `logout_test.dart`. Their existing setups seed raw production keys (`access_token`/`auth_user`), so the development namespace correctly did not load those fixtures. Five assertions failed before the next fixture waited for a credential that was never seeded; that exploratory run was stopped. It is **not** counted as a passing development suite, and no fixture/source was modified to suppress it. Log: `/private/tmp/provider-development-readiness-tests.txt`. The earlier complete production-default suite remains 550 passing; it is distinct from these development-only checks.

Startup/configuration inventory (paths and names only):

- `lib/main.dart`: `ApiEnvironment.validate()` runs before initialization. With `API_ENV=development`, normal/background Firebase initialization and auto-init calls are skipped. DI, SharedPreferences, native secure storage, orientation and the normal router still initialize.
- `lib/core/api/api_environment.dart`: the required development selector is `API_ENV=development`; no other Dart define is required by current provider startup. It selects the development API, same-origin `/chat`, `development_` storage namespace and Firebase-disabled mode. Invalid environment spelling fails closed; default remains production.
- `lib/core/di/dependency_injection.dart`, `lib/core/utils/app_remote_config.dart` and `lib/data/repositories/notifications/notifications_repository.dart`: development does not obtain `FirebaseMessaging.instance`; RemoteConfig uses local defaults and notification initialization/logout cleanup return before Firebase work.
- `android/app/build.gradle` selects `android/app/src/development/AndroidManifest.xml` for development debug/profile/release variants. The overlay removes `FirebaseInitProvider`. Normal source still declares the Google Services Gradle plugin and `android/app/google-services.json`; the lead's separate sanitized application copy removes that plugin/config and uses `com.yourcarehere.partner.securitytest`. This follow-up did not edit either source or copy.
- Optional native map placeholder: `GOOGLE_MAPS_API_KEY` is read from `android/secrets.properties` or the environment by Gradle, with an empty fallback, then used by `android/app/src/main/AndroidManifest.xml`. iOS has the same build-setting name in `ios/Runner/Info.plist`; `ios/Flutter/{Debug,Release}.xcconfig` optionally includes `Secrets.xcconfig`. Values were not exported.
- There is no provider `AppSecrets`/Places configuration, Maps/Places Dart SDK dependency or in-app `GoogleMap` startup. `lib/components/open_map_action.dart` opens an external Google Maps HTTPS URL, so a map/Places credential is not a current main-startup prerequisite. `ios/Runner/AppDelegate.swift` registers plugins without a map-key initialization call.
- Native SharedPreferences/secure-storage plugin availability and Internet permission remain normal runtime requirements. Production Firebase bundles exist at their standard Android/iOS paths but are not needed for the explicitly Firebase-disabled development Dart path. This does not establish iOS native Firebase-off parity or a physical main-startup pass.

No device, SSH, deployment or network request was performed by this owner. Full normal-main development build/install, backend connectivity and physical-device validation remain with the lead; the earlier isolated widget harness pass is not substituted for those checks.

### Canonical full-main development APK

After the user authorized replacing the installed testing-device applications, the lead requested the actual provider package build. This owner built, but did not install, canonical source with:

```sh
/Users/bshaqra/development/flutter/bin/flutter build apk --debug --dart-define=API_ENV=development --no-pub
```

Result: **passed**, Gradle 25.4 seconds, normal `lib/main.dart` entrypoint. APK badging confirms `com.yourcarehere.partner`, version name `3.0.1`, version code `28`. No separate test application ID or widget-harness target was used.

- Canonical output: `build/app/outputs/flutter-apk/app-debug.apk`.
- Stable private copy for lead installation: `/private/tmp/provider-development-main-debug.apk` (215,393,170 bytes).
- APK SHA-256: `1173c328f3bd158523554ef53611f1a5b938897097ffc951ed0dad0acf2e80fd`.
- Source fingerprint before and after: `2391ea65a9328a8457a91e0acd8dbb08f538e41ad536ddb16b9b765aa1689dc0`; 561 nonsecret compiled input files, including current dirty `lib`, assets, Android source and Gradle/pubspec configuration. Git base remains `a931a4f8ee2f8a39c61537c6c77ff1f4f173a3f0`; the fingerprint identifies the dirty build inputs rather than claiming that base commit alone produced the APK.
- Private signing/key/secrets/Google Services configuration and generated build/tool caches are excluded from the source-fingerprint report and were not edited. No secret values were exported. Private input manifest: `/private/tmp/provider-development-main-source-before.json`; bounded artifact/configuration projection: `/private/tmp/provider-development-main-build-report.json`; build log: `/private/tmp/provider-development-main-build.txt`.
- Merged development manifest inspection confirms Firebase initialization provider absent; messaging auto-init false; Analytics collection deactivated; Crashlytics collection false; cleartext traffic false; backups false. These are manifest facts, not a claim of device runtime validation.

The build did not change the recorded compiled source inputs, so the existing complete 550-test result and 49 focused development checks were retained without repeating them. Only this handoff was updated. Keystore/native private configuration was left untouched; installation, any signature compatibility handling and full-main Samsung validation remain exclusively with the lead. No production server or app-store deployment occurred.

### Explicit IDE development configurations

Normal `main.dart` runs keep the production default. New shared run choices explicitly select development without changing application source or the frozen binaries:

- Provider repository: `.run/YourCare_Business_Dev.run.xml` for Android Studio/IntelliJ and `.vscode/launch.json` for VS Code, named **YourCare Business Dev**.
- Customer repository `/Users/bshaqra/IdeaProjects/cleaning/customer/cleaning_service`: `.run/YourCare_Customer_Dev.run.xml` and `.vscode/launch.json`, named **YourCare Customer Dev**. Customer additionally reads its existing local `android/secrets.properties` using `--dart-define-from-file` for the Dart Maps/Places key; no key value is included in a shared configuration. Existing `--no-start-paused` behavior is retained.
- The attached parent folders `cleaning/driver` and `cleaning/customer` also have `.vscode/launch.json` with the same named development choice and correctly nested project working directory/entrypoint. Existing `.idea/runConfigurations/main_dart.xml` files were left untouched; current Android Studio supports shared `.run` files, so no duplicate legacy configuration was created.

In Android Studio/IntelliJ open the actual Flutter repository, select **YourCare Business Dev** or **YourCare Customer Dev** from the run dropdown, select Samsung and Run. In VS Code open either actual repository or its attached parent, choose the named development configuration in **Run and Debug**, then start debugging. Stop an already running production-default session first; hot reload does not change a compiled Dart define. The new app shows the DEV ribbon. Development backend readiness remains a separate lead-owned rollout gate.

Equivalent local commands, from each actual repository:

```sh
# Provider
/Users/bshaqra/development/flutter/bin/flutter run --dart-define=API_ENV=development
# Customer; existing helper forwards its private local Maps key.
./scripts/run_local.sh --dart-define=API_ENV=development
```

All six new XML/JSON files parse and their entrypoint/working-directory paths resolve. Both repository diff checks pass. No Flutter suite/build was repeated for these noncompiled IDE files, and no application, backend or device was launched by this owner.

## 29 October: company permission choices and menu access

Canonical authority remains the backend `release-expansion-api-contract.md`. The provider applies its exact company-operational permission table locally, including against older unfiltered catalogues. Administrative/unused choices and unrelated service choices are absent; managers choose only eligible capabilities they hold. An authenticated fresh own-user read and matching own-company service context determine choices. Loading, failure/retry and service-context failure states are explicit; failed metadata reads retain generic choices. Account-generation checks prevent publishing or saving another account's context.

The new nonfinancial `CompanyServices` model/service/repository/use case and `CompanyServicesCubit` call GET `/business/my-services`. Home and the editor do not require private profile read access. Only404 or400 with the exact unsupported-route message `Invalid resource ID` falls back to the existing separately authorized fresh `/business/my-business` read;401/403 and other errors never do. No stale user-service claims, fake profile/zero values, selector, private-profile grant or logout fallback is introduced. The private `CompanyProfileCubit` stays unchanged. Context reads have bounded waits, coalesce active loads and reject stale completions by local/account generation. Home reloads after either a loaded or first-pending context is cleared; account replacement cannot reload an old Home, and financial denial remains effective.

The selected set is never intersected with visible choices. Hidden/unknown IDs remain in the actual staff Save event, including when a formerly hidden service becomes eligible after the editor loaded. Hidden administrative titles are replaced by one bilingual retained-access summary. This does not add a catalogue revision or solve the documented legacy GET-to-save ambiguity. Fresh target detail supplies the unchanged price-checkbox baseline rather than a stale list entry; an untouched checkbox still omits the flag from profile updates. `users:read` copy describes company accounts/team members, and shared business permissions describe singular company settings.

Owner menu/submenu fallbacks match explicit backend owner routes. Quote opportunities remain grant-dependent even for owners because RequestsController does not declare an owner bypass; only the actual `available_requests:read` key qualifies. Furniture opportunities retain their supported entry. Jobs no longer requires any currently offered service. Staff/calendar entries use actual staff/team/company-job capabilities rather than unrelated permission-definition grants. Price-denied users still cannot enter financial reports, automatic bidding or documents; operational availability remains accessible. Local missing staff-price flags preserve legacy access, including workers, while explicit denial, unresolved access and forced-denial epochs remain effective. This does not persist server grants.

Implementation paths include new `lib/core/access/company_permission_{policy,context}.dart`, `lib/components/company_permission_panel.dart`, retained-summary editor, staff create/details/main, Home policy/screen, Housekeeping/Car Wash submenus and bilingual source/generated localization. Context plumbing is in `lib/data/models/profile/company_services.dart`, business profile service/generated adapter/repository, `get_company_services_usecase.dart`, `company_services_cubit.dart`, DI, account cleanup and capability-cache invalidation. Existing stable IDs/assignments, private profile guards, authentication/session wire and financial guards are preserved.

Final evidence lives under `/Users/bshaqra/.codex/private/yourcare-legacy-provider-checks-20261029`:

| Check | Actual result |
| --- | --- |
| Before permission/menu changes | Full550 pass;61 pre-existing analyzer diagnostics plus one historical-harness import diagnostic removed here. |
| Focused new context/menu/transport/Laundry checks |65 pass; `provider-new-context-focused-02.log`. Includes fresh/mismatched company, manager caps, hidden IDs in actual Save, narrow400/404 fallback and401/403 rejection. |
| Complete default Flutter suite after context integration | **593 pass**, zero failures/skips; `provider-services-full-final.log`. |
| Analyzer | **59 existing diagnostics, zero errors/zero new**, compared by severity/message/path/rule; `provider-services-analyze-final.log`. Two prior photo-picking async-context diagnostics are now guarded. |
| Generation and whitespace | `flutter gen-l10n`, matching-Dart `build_runner` regeneration and `git diff --check` pass. |
| Physical Samsung SM S908E / R5CT21PNW7R | **28 actual tests pass** (runner30 includes setup/teardown) in separate `com.yourcarehere.compat.permissions`; `provider-permissions-device/fixture-drive-context.log`. |
| Screenshot review | All six EN/AR filtered-editor, price-checkbox and price-hidden job-detail PNGs reviewed; no blocking clipping. Files in `provider-permissions-device/device-evidence-context/`, with `physical-result.json` and `device-response.json`. |
| Full MAIN development APK | Built successfully with `--debug --no-pub --target lib/main.dart --dart-define=API_ENV=development`. See artifact below; **not installed by this owner**. |

Physical checks mount actual editor/submenu/Home/StaffDetails widgets and real typed service/repository parsing against synthetic local adapters. Native HTTP is blocked before a connection, secure storage is mocked and app main/Firebase/production DI/sockets are not initialized. They cover service filtering, partial/unknown retention, owner/manager controls, actual staff Save, loaded and first-pending cache invalidation, late completion, account replacement, financial/campaign denial and transport fallback. All SDK/mock fixtures remain separate from actual current-store binary and live backend authorization checks. No normal partner/client app was replaced, cleared or logged out; only the isolated fixture app was launched, then force-stopped.

Earlier failed evidence is preserved. One parallel full run exposed an inherited10ms revocation-test scheduling assumption; it now waits for the actual denial event without weakening assertions. Another exposed a30ms custom test deadline before nominally immediate Dio setup completed under concurrent compilation. The two timeout tests now inject a1-second test deadline, still asserting cancellation, retry, retained catalogue data and ignored late errors; production deadlines are unchanged. A fake-clock conversion was discarded after it did not advance the mocked Dio chain. Early phone attempts caught synthetic future-error timing/zone boundaries in the harness; failures were corrected without skipping checks or changing application policy.

Full MAIN artifact: `provider-main-dev-final/yourcare-business-dev-permissions.apk`, actual package `com.yourcarehere.partner`,3.0.1/code28,215409379 bytes. APK SHA-256 `c7b3b3b3e0e083fbc46844981eb197e0de9b06ece620c3b3ecf3cee3825f392b`; debug certificate SHA-256 `9a07f05c5ffb20967f21d010a0c9aee51d7bdc8bdc3a427bc8cd2c71e355bc74`. Frozen compiled source input SHA-256 `6d1ec8b74b57f080e4a6047b3c09fe0921000aee9ebf629d5436ebe6ca452651`, unchanged after build. `source-inputs.json`, `artifact.json` and `build.log` are alongside the APK. Existing private native configuration was used in place without exporting values. The lead owns any normal-app installation and all server actions; production remains subject to the separate current-store binary gate.

### Compiled backend context parser supplement

After the runtime/physical freeze, the backend owner exported two actual compiled AppModule HTTP responses with the production response globals and synthetic real JWT/database actors: grantless manager and explicit-price-false grantless manager. Both metadata requests succeed while the same actors' private profile/generic business reads return403. The export is `ops/release-expansion-20261028/backend-company-services-fixtures.json`, source `d41e559`, SHA-256 `525385c0b95f541a4015ec0eb1aa027a36bca055c3a2f2696ed3b6bdf554fa4e`.

`test/fixtures/company_services_backend.dart` retains only the synthetic cases and their provenance. The existing nine service tests now decode both actual envelopes through generated Retrofit and the repository, asserting exact own company/services, no private-profile call and no financial fields. **Nine focused tests pass**, log `provider-actual-context-parser-focused.log`; the two changed test files also pass focused analysis. This adds no runtime change and does not claim the earlier phone APK used this later fixture export. The full593-test run,28 physical tests and MAIN APK remain the frozen runtime evidence; no redundant full/native build or normal-app install followed this test-only supplement.

## MAIN follow-up: staff editor idle-state interaction

The lead's real MAIN development run exposed an interaction regression that the previous generic action-state fixture missed. `StaffDetailsScreen` treated `StaffActionInitial` as loading and absorbed all ListView gestures. The earlier permission-fetch event had incidentally emitted a different state; after permission loading became independent, the genuine action bloc correctly stayed idle/Initial and the form remained blocked. This supersedes the previous runtime freeze/APK for staff-form interactivity.

The minimal fix removes only that Initial-based `AbsorbPointer`/empty Stack. Actual pending actions retain the unchanged global `LoadingController` modal barrier. Add-user has no analogous Initial-state blocker and needs no application change. The existing hidden-ID Save fixture now starts from `StaffActionInitial`; new `staff_initial_interaction_test.dart` constructs a genuine `StaffActionBloc` with synthetic repositories, forbids unmatched transport, performs real drag scrolling and toggles local permission drafts in both EN/AR edit/add forms without saving an account.

Before the fix, the genuine edit cases failed in both languages with scroll offset exactly0 while add-user passed. After the fix, all **five focused tests pass** (`staff-initial-fixed-focused.log`); the complete suite is **597 pass**, zero failures/skips (`staff-scrollfix-full.log`). Analyzer remains **59 existing diagnostics**, zero errors/new diagnostic keys (`staff-scrollfix-analyze.log`). Whitespace check passes. No device action, account mutation or installation was performed by this owner during this follow-up; the lead owns fresh real MAIN verification. The earlier28 physical fixture checks do not establish this corrected initial-state path.

Fresh full MAIN DEV artifact: `/Users/bshaqra/.codex/private/yourcare-legacy-provider-checks-20261029/provider-main-dev-scrollfix/yourcare-business-dev-scrollfix.apk`. SHA-256 `689eaeef911007a11e419c44f3060ba80c885891416350c61501321d49057ea8`,215400576 bytes; actual `com.yourcarehere.partner`,3.0.1/code28, unchanged debug signing certificate, `lib/main.dart`, `API_ENV=development`. Frozen source input SHA-256 `df6a0a2be7ab9bdb0292cee5b93a725b4d47a10cc83243b3f515d0532ed3af39`, unchanged after build. `artifact.json`, `source-inputs.json`, `compiled-change.patch` and `build.log` are alongside it. Compared with the prior MAIN manifest, **only** `lib/features/screens/staff/staff_details_screen.dart` changed among compiled inputs; other application/native/version/configuration source bytes remain identical. No generation, dependency, backend or native-source change was needed.
