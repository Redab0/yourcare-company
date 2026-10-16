# Provider security-fixes handoff

Date: 2026-10-16 (Asia/Kuwait). Repository: `/Users/bshaqra/IdeaProjects/cleaning/driver/cleaning_service_driver`. Branch: `security-fixes`, from live/develop `28049e27ea6b373c65210c2c4cb12873811b447e`. No commits, pushes, production requests, deployment, store upload or physical-device runs.

Canonical scope/contract: [shared brief](/Users/bshaqra/IdeaProjects/you-care-backend/docs/features/security-fixes/brief.md), [shared API contract](/Users/bshaqra/IdeaProjects/you-care-backend/docs/features/security-fixes/api-contract.md). See [input/transport inventory](input-inventory.md) for all 65 text widget/shared-wrapper call sites in 23 files, selectors, every typed service family and remaining semantic gaps.

## Result

- Every shared-Dio body/query and multipart field is recursively validated before reading/attaching credentials. Collections, depth, node count, individual/aggregate text, keys, primitive types and finite numbers are bounded. Multipart duplicates remain distinct and share aggregate budgets; arbitrary file streams are not read twice. Conservative normalization preserves Arabic, punctuation, multiline notes and HTML-looking plain text; credentials remain byte-exact, including JSON-escaped characters.
- Verified field rules cover Kuwait phones, email/URLs, staff username/role/endpoint-specific password policies, prices versus percentages, coordinates, schedule ranges, laundry catalog/settings/prices/quantities/invoice lists/revisions/actions. Raw numeric drafts are checked before save in auto-bid, housekeeping, car wash, upholstery and offers. Invalid auto-bid/housekeeping text survives blur/rebuild and blocks save without replacing it with zero; no NaN sentinel is used. Five widget regressions cover bad/negative/nonfinite/excess-decimal input, blur/rebuild, blocked save and subsequent explicit zero. Optional clearing values, omitted worker credentials, category removal, zero car-wash prices and KWD discounts above 100 remain valid where supported.
- Exact configured HTTPS API origin and `/api` scope are enforced independently in both request and session interceptors. Original raw paths are validated before URI normalization and recursively decoded to reject traversal/path injection. Authenticated redirects are disabled; standard certificate validation remains intact. Socket origin and native WSS upgrade are restricted; a custom HTTP client prevents credentialed WebSocket redirect following. Incoming documents are capped at 10MiB while streaming before Dio buffers them.
- Profile uploads use local count/size/total safeguards, filename checks, a bounded image signature probe and accurate MIME metadata. These local ceilings do **not** establish deployed backend upload validation. Safe store/contact/map/media link sinks avoid arbitrary schemes and credential-bearing URLs.
- All application-authored console logging is removed. Diagnostics never retain records or execute sinks. Analytics and Crashlytics Flutter dependencies, direct native dependencies, Gradle plugins and symbol-upload hooks are removed, preventing older persisted SDK preferences from enabling startup collection. Firebase push/Remote Config remain. Native defensive disable flags remain in place. This does not promise silence from OS/framework/other third-party internals.
- Android forbids cleartext and cloud/device-transfer backup. iOS removes arbitrary-load ATS allowance and uses `unlocked_this_device` protection for new session records. Silent migration copies legacy credentials into new complete records, preserving the original until durable commit; it does not rewrite the only legacy key in place. Android encrypted storage has `resetOnError:false` to retain credentials on transient native errors.
- Session saves and clearing are serialized; token/user socket reads are atomic. Only confirmed terminal auth codes clear a matching account/token; ordinary expiry renews silently and temporary/unclassified errors retain credentials. Profile preload and external BLoC setters reject stale generations before cache/UI mutation. Socket generations prevent in-flight connects from reopening after logout. Account/user/FCM cache state is cleared while device identity, locale and permission preference remain.
- Manual logout captures its credential, deactivates cached device push registration while the bearer is valid, then calls typed `POST /auth/logout` with cancellation/timeout, and finally clears only that matching local session. Older/offline servers cannot block local cleanup. A token-read failure still attempts generation-matched local cleanup. Auth events are serialized. Notification handlers and tray cleanup are matched to the old account; non-cancellable native FCM token deletion is deliberately omitted to avoid late deletion of a new account's token.

## Contract/rollout

Existing payloads/envelopes/status/payment/time/money semantics are unchanged. The agreed [persistent sign-in contract](/Users/bshaqra/IdeaProjects/you-care-backend/docs/features/security-fixes/session-renewal-contract.md) adds idempotent enrollment, rotating persistent refresh and refresh-proof revocation. Valid legacy bearers remain compatible while updated clients enroll silently; this upgrade has no forced re-login or routine seven-day/idle cutoff. Explicit logout durably tombstones locally before bounded captured-credential push deactivation/revocation. No remote call occurs inside the storage mutex. Offline/unsupported/transient responses retain login except for explicit local logout or confirmed terminal auth. Client validation never establishes server authorization or trustworthy prices/payment state.

## Verification

Fresh local evidence is in `/private/tmp/provider-security-*.log` (not committed). Tests use local fakes; no production API activity occurred.

- Baseline source at committed HEAD, extracted to `/private/tmp/provider-security-baseline` with the same dependency inputs, reproduces **319 passed / 13 failed**. Those failures are existing laundry widget fixtures/layout/timing/DI expectations. Baseline analysis: **68 diagnostics**, no errors.
- Latest focused security/API suite: **47 passed** (including five invalid-draft blur/save widget regressions). DEV API suite with `TELEMETRY_ENABLED=true`: **15 passed**. Final analysis: **61 pre-existing diagnostics, zero errors or added diagnostics** versus baseline68. `git diff --check` passes.
- Final full security source (serial run): **351 passed / the same 13 baseline failures**; focused security/API suites pass. One heavily concurrent native-build run produced an extra catalog-deadline timing failure; that deadline case passed in isolation, with only its three existing catalog-widget failures remaining. This is recorded rather than claimed as a full-suite pass.
- Android debug APK and unsigned iOS app compile successfully. Generated merged Android manifest confirms no cleartext/backups/device transfer; compiled iOS plist confirms ATS and telemetry flags. Lockfiles/native registrants contain no Analytics/Crashlytics. Android dex package inspection contains neither diagnostic SDK; fresh iOS bundle contains no Analytics/Crashlytics/Measurement frameworks and its load commands retain only required Firebase push/config dependencies. Cached iOS debug app bundles produced during this session were recreated to avoid stale embedded frameworks.
- API code was regenerated. A full generator run exposed an existing unrelated raw-Map `Map.fromJson` defect in the auto-bid categories client; its committed generated bytes were restored. Following dependency changes, filtered generation invalidated other generated files; those unchanged committed files were restored. Only auth and notification generated client diffs remain. Future broad regeneration still needs that unrelated generator/schema issue addressed.

## Limits / open checks

- No authenticated DEV end-to-end journey, release signing, device UI smoke, English/Arabic screenshot inspection, production validation or deployment was performed. Native compile/local fakes do not establish an integrated journey pass.
- Optional/unknown fields receive generic type/resource/content safeguards; only verified semantics receive stricter business validation. Local text/upload/download caps are safeguards, not claims about every server DTO or deployed version.
- Offline push deactivation cannot guarantee that the backend or OS stops an already queued notification. Native FCM deletion has no cancellation API and is not started during logout; cached registration is deactivated best effort and local app state/tray cleared. A locked/unavailable platform keystore can still prevent physical credential deletion; cleanup is attempted and errors remain user-visible.
- Existing personal-profile edit/save remains a UI-only mock: the name/phone form validates, but its existing save path sends no update request. It is inventoried explicitly; this security change does not claim profile persistence.
- Provider has no payment WebView or standalone HTTP client. Backend authorization, session revocation/expiry, upload decoding, rate limits and related server findings are coordinator-owned; app checks cannot repair them.
- Existing laundry widget failures remain as reproduced above. No claim of maximum or complete security is made.

## Scope preservation

All original store-CI files were compared with `/private/tmp/yourcare-security-original-ci/business`. Their bytes/version hunks are preserved; the only authorized edits in previously dirty `pubspec.yaml` and `android/app/build.gradle` are diagnostic dependency/plugin/hook removal. No unrelated CI files were staged or committed.

## Changed files

- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/data_extraction_rules.xml`
- `android/settings.gradle`
- `docs/features/security-fixes/input-inventory.md`
- `ios/Podfile`
- `ios/Podfile.lock`
- `ios/Runner/Info.plist`
- `lib/components/contact_actions.dart`
- `lib/components/media_carousel_viewer.dart`
- `lib/core/api/api_client.dart`
- `lib/core/api/session_request_interceptor.dart`
- `lib/core/api/upload_limits.dart`
- `lib/core/diagnostics/app_diagnostics.dart`
- `lib/core/diagnostics/mobile_telemetry.dart`
- `lib/core/security/bounded_response_adapter.dart`
- `lib/core/security/request_security.dart`
- `lib/core/security/request_security_interceptor.dart`
- `lib/core/security/session_state.dart`
- `lib/core/security/socket_transport.dart`
- `lib/core/security/socket_transport_io.dart`
- `lib/core/security/socket_transport_stub.dart`
- `lib/core/storage/secure_storage_service.dart`
- `lib/core/utils/app_update_service.dart`
- `lib/core/utils/push_service.dart`
- `lib/core/validators/validators.dart`
- `lib/data/models/auth/auth_tokens.dart`
- `lib/data/repositories/auth/auth_repository.dart`
- `lib/data/repositories/notifications/notifications_repository.dart`
- `lib/data/repositories/notifications/play_services_check.dart`
- `lib/data/repositories/profile/business/business_profile_repository.dart`
- `lib/data/services/auth/auth_service.dart`
- `lib/data/services/auth/auth_service.g.dart`
- `lib/data/services/notifications/notifications_service.dart`
- `lib/data/services/notifications/notifications_service.g.dart`
- `lib/features/bloc/auth/auth_bloc.dart`
- `lib/features/bloc/profile/business/business_profile_bloc.dart`
- `lib/features/chats/data/chat_socket_service.dart`
- `lib/features/screens/auth/login_screen.dart`
- `lib/features/screens/auto_bid/auto_bid_configuration_screen.dart`
- `lib/features/screens/car_wash/car_wash_pricing_screen.dart`
- `lib/features/screens/home/company_profile_cubit.dart`
- `lib/features/screens/housekeeping/housekeeping_configuration_screen.dart`
- `lib/features/screens/jobs/house_keeping_job_details_screen.dart`
- `lib/features/screens/profile/business_profile_screen.dart`
- `lib/features/screens/profile/user_profile_screen.dart`
- `lib/features/screens/requests/deep_cleaning_requests_screen.dart`
- `lib/features/screens/requests/upholstery_cleaning_requests_screen.dart`
- `lib/features/screens/staff/create_staff_screen.dart`
- `lib/features/screens/staff/staff_details_screen.dart`
- `lib/features/screens/upholstery/upholstery_pricing_screen.dart`
- `lib/main.dart`
- `lib/main_documents_preview.dart`
- `lib/main_laundry_preview.dart`
- `pubspec.lock`
- `pubspec.yaml`
- `test/core/api/firebase_environment_test.dart`
- `test/core/api/session_request_interceptor_test.dart`
- `test/core/api/stack_hardening_test.dart`
- `test/core/api/telemetry_policy_test.dart`
- `test/core/security/logout_test.dart`
- `test/core/security/request_security_test.dart`
- `test/core/security/service_boundary_test.dart`
- `test/core/security/session_cache_test.dart`
- `test/core/security/numeric_draft_test.dart`


## Historical follow-up: fail-closed persistence after `f6d39a9` (superseded by silent renewal below)

This follow-up is prepared separately for coordinator review. No native dependencies or API payloads changed.

`saveSession` now writes a durable `auth_session_pending` marker before changing account keys, removes the previous account's credentials/cache, writes the new user before the new token, and removes the marker only after both writes succeed. A platform-write/commit failure reasserts the marker and attempts rollback. If rollback deletion also fails, guarded token/user/snapshot reads still return signed-out state; the marker survives process interruption/reconstruction. A subsequent complete sign-in or successful local cleanup can remove the pending state. Physical deletion still depends on a functioning platform keystore.

Direct `getUser` reads wait for live serialized operations and retry if their barrier/generation changes. They cannot expose an intermediate user with an old token, and an unresolved optional profile probe does not hold the session mutex. Idle queue operations start in a microtask after publishing their tail, preserving ordering for synchronous callbacks while avoiding stale completed futures from a previous asynchronous zone. The three paired token/user document/DEV route guards use one `sessionSnapshot`. Asynchronous `saveUser` refreshes only update the current committed matching user ID, so a stale response cannot overwrite a newer account's profile.

Eight MethodChannel-level regressions exercise user-write failure, token-persist-then-error combined with rollback-delete failure, failure clearing the commit marker, interrupted-process pending state, direct concurrent reads during a paused write, a stalled optional user read overtaken by a successful sign-in, a stale account profile refresh, and a synchronous `beforeSave` callback queuing a token read behind the full replacement. Affected focused suite: **22 passed**. Final full suite: **359 passed / 13 failed**, with the exact same 13 failure names as the recorded baseline (319 passed / 13 failed), and 8 additional passing tests compared with the reviewed security implementation (351 passed / 13 failed). Final analysis: **61 findings**, the identical diagnostic set to the reviewed security implementation, compared with 68 baseline findings. `git diff --check` passes. No native rebuild was needed for these Dart-only changes.

Evidence: `/private/tmp/provider-security-persistence-focused-final.log`, `/private/tmp/provider-security-persistence-full-final.log`, `/private/tmp/provider-security-persistence-analyze-final.log`. The final full pass includes the microtask queue publication fix and its synchronous callback regression. No further code changes followed this verification.

Follow-up files: `lib/core/storage/secure_storage_service.dart`, `lib/core/router/router.dart`, `lib/main_documents_preview.dart`, `lib/main_laundry_preview.dart`, `test/core/security/session_persistence_test.dart`, and this handoff.


## Persistent sign-in and silent renewal follow-up

Implements the canonical [renewal contract](/Users/bshaqra/IdeaProjects/you-care-backend/docs/features/security-fixes/session-renewal-contract.md). Local source only; no deployment, production calls, store operations, staging or commits by the provider implementer. Prior counts above are historical; new verification is recorded separately below.

- One shared coordinator performs single-flight legacy enrollment/refresh before API and socket use and on startup/foreground resume. Renewed access is proactive within 60 seconds of expiry; refresh credentials have no client inactivity or seven-day cutoff. A persistent operation UUID and exact input credential are committed before sending, retained through network loss/malformed replies/failed native commit, and reused after reconstruction. Temporary 400/403/404/429/5xx, timeouts and unclassified401 preserve committed credentials; unsupported404 uses a five-minute cooldown and other retry failures use 30 seconds.
- Two complete device-only secure records are selected by monotonic persisted revision. Writes target the inactive record, so native DELETE+failed ADD cannot destroy the only current credential/recovery operation. Migration preserves legacy entries until durable replacement. Explicit logout cancels renewal at start, advances account generation, writes a signed-out tombstone before remote work, best-effort scrubs the other slot and deletes legacy keys with accessibility-independent queries. A tombstone prevents fallback even if cleanup fails. Physical keystore failure can still prevent a durable write/erase; it is surfaced without inventing successful persistence.
- Same-account credential rotation preserves account generation, profile/chat caches and push state, while advancing credential revision. Conditional commits validate token/generation/recovery proof, identity, allowed provider role/enabled state, refresh session continuity, JWT syntax and expiry future <=1 hour plus 60 seconds tolerance. Client syntax checks do not verify signatures or establish authority. Password login remains its existing typed envelope and silently enrolls; a delayed login cannot undo logout or replace another account.
- The first synchronous security interceptor pins account generation before later asynchronous gates. Credential preparation and confirmed-expiry retries verify that pin. At most one pre-handler `AUTH_ACCESS_EXPIRED` retry is allowed for recursively reusable JSON; streams and FormData are not automatically replayed. Unknown execution after network/5xx failure is never replayed. Only terminal machine codes clear captured matching account state.
- A separate exact-origin HTTPS Dio transport has no session interceptors, disables redirects, bounds deadlines and streamed responses to1MiB, preserves locale, and requires an adapter provider. The production provider follows the main client's configured adapter, so injected local fakes also cover renewal. Explicit logout uses public refresh-proof family revocation where available, otherwise captured legacy Bearer logout; push deactivation uses the captured old bearer. No native noncancelable FCM deletion is started.
- Socket startup renews first; explicit expiry renews/reconnects with the new bearer and stale callbacks are ignored. Temporary disconnect/auth-unavailable does not clear chats or login. Foreground/startup work does not require online renewal before opening cached signed-in state.

Verification covers native MethodChannel failures (including DELETE+failed ADD), operation recovery/reconstruction, account switching and delayed password login, durable logout races, concurrency, temporary/terminal HTTP errors, proactive/lifecycle/socket behavior, malformed renewal data, exact-origin transport headers and chunked-response limits. The checked-in fixture `test/fixtures/session_renewal_provider.json` contains actual disposable local backend HTTP payloads and credentials signed by a fake fixture key; no production data. Tests use the fixture expiry as their clock reference.

Final verification: focused security/session suite **90 passed**; DEV credential-isolation/telemetry suite **14 passed** with `API_ENV=development` and `TELEMETRY_ENABLED=true`. Full serial suite **406 passed / 13 failed**, with the exact same 13 failure names as the immediately preceding reviewed provider source (**359 passed / 13 failed**) and the original baseline (**319 passed / 13 failed**). This follow-up adds 47 passing tests. Analysis **61 findings**, the identical diagnostic set to the reviewed provider source, with zero added diagnostics/errors (original baseline68). `git diff --check` passes.

Evidence: `/private/tmp/provider-renewal-focused-final.log`, `/private/tmp/provider-renewal-dev-final.log`, `/private/tmp/provider-renewal-full-final.log`, `/private/tmp/provider-renewal-analyze-final.log`. No generated model/service inputs changed, so no generator was required. No native build was run for this Dart-only follow-up; prior native evidence is not presented as a new build. No source changes followed these final checks.


Follow-up changed files (pre-existing CI/version files excluded):

- `docs/features/security-fixes/handoff.md`
- `lib/core/api/api_client.dart`
- `lib/core/api/session_error_interceptor.dart`
- `lib/core/api/session_request_interceptor.dart`
- `lib/core/di/dependency_injection.dart`
- `lib/core/security/request_security_interceptor.dart`
- `lib/core/security/session_credentials.dart`
- `lib/core/security/session_lifecycle.dart`
- `lib/core/security/session_renewal_coordinator.dart`
- `lib/core/security/session_renewal_transport.dart`
- `lib/core/storage/secure_storage_service.dart`
- `lib/data/repositories/auth/auth_repository.dart`
- `lib/data/repositories/notifications/notifications_repository.dart`
- `lib/features/chats/data/chat_socket_service.dart`
- `lib/features/screens/home/home_screen.dart`
- `lib/main.dart`
- `lib/main_documents_preview.dart`
- `lib/main_laundry_preview.dart`
- `test/core/security/logout_test.dart`
- `test/core/security/request_security_test.dart`
- `test/core/security/session_persistence_test.dart`
- `test/core/security/session_renewal_test.dart`
- `test/fixtures/session_renewal_provider.json`
