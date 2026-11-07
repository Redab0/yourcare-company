# Smart Booking Assistant — provider handoff

2026-11-07; branch `codex/customer-ai-assistant`, baseline `3c57549`.

Canonical brief and contract are maintained in backend `docs/features/customer-ai-assistant/` on the matching feature branch:
[brief](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/brief.md),
[API contract](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/api-contract.md).
Local canonical files are in the backend feature worktree; this repository does not maintain another brief or API contract.

No provider application or API-client changes. The customer assistant reads existing catalog/pricing/availability services and sends customers into the existing booking flows. Provider-managed dated capacity, packages, offers and fulfillment remain authoritative. Guided recommendations neither reserve capacity nor create orders. The user selected deterministic rules and explicit service choices with no paid AI calls; there is no external model/key dependency. No new service discriminator, order/visit/payment state, monetary unit, event or provider permission. A backend readable-ID validation correction is planned below; the R1 API result does not establish compatibility of the provider's current detail-refresh path.

Target is DEV first. No provider binary was built, installed, uploaded or deployed for this documentation-only handoff. Current source supports `API_ENV=development` through `lib/core/api/api_environment.dart`; use it only for separately requested provider verification. Original checkout remains on its original branch without modifications.

Checks: named source paths and canonical documents verified; `git diff --check` and repository status inspected. No Flutter checks required for documentation-only changes. The API-level DEV results below do not establish a signed-in provider app journey.

## 7 November 2026 — R1 DEV activation and synthetic API journey

The technical lead activated guided backend source `1c83af836628cd9d6643313ac210169fa007bedb` on DEV through the normal authenticated Captain image-only Save. The initial R1 image was `yourcare:smart-booking-dev-20261107-api`, ID `sha256:2277080d0beee47f2d9153439cfa58eccef7ba540913ee35d8c59e8673f2f6d1`. All 33 retained services were unchanged. Provider application code and binaries were unchanged; this is a backend DEV activation, with no paid AI, external payment-gateway transaction or production change.

The lead's synthetic DEV order **HK149** passed assistant availability → server quote **4.000 KWD** → wallet payment → `confirmed` → provider visit `inProgress` → `completed`. The same order was visible through the customer, provider and admin APIs; the provider detail read used the Mongo request ID. Read/start retries did not duplicate financial records; a customer attempt to change provider status returned 403, and a skipped transition returned 400. Provider-managed availability and the existing visit lifecycle remained authoritative. This Mongo-ID API result does not prove the existing provider UI's readable-ID refresh is compatible with R1.

Detailed shared evidence belongs in the backend's [canonical booking-flow verification](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/booking-flow-dev-20261107.md). These are API-level results using the synthetic DEV order. Signed-in customer UI checkout remains **unverified**, excluded by the 8 November API-only decision; provider/admin UI checks were not run. No provider binary was built, installed, uploaded or deployed for this follow-up. Documentation paths/status and `git diff --check` were checked; Flutter builds/tests were not run because application code is unchanged.

## Historical R1 incompatibility and R2 rollout decision

An independent authenticated probe on R1 returned customer `GET /requests/HK149`
200 but provider `GET /company/requests/HK149` 400. Provider Housekeeping models
read the response's `id` field directly; the backend serializes that field as
the readable order ID. The client has no separate Mongo request-ID fallback.
The jobs list passes this model into the detail screen, which can initially
render from that supplied data. Its refresh button sends the same readable ID
unchanged to `/company/requests/{id}`. Thus the observed 400 affects the actual
detail-refresh contract; a successful manual Mongo-ID read does not establish
provider UI compatibility. Other lifecycle routes have separate validation and
lookup paths, so this finding does not mean every provider action fails.

The existing backend source fix `55144127e9b2fa6632eea63bbea9b9013883b090`
uses `RequestIdDto` for company GET detail, PATCH detail and PATCH assign-team.
It is present on the backend feature branch but absent from R1's older deployed
base. The agreed R2 plan layers only compiled `company.controller.js` and
`request-id.dto.js` onto the verified DEV image. It accepts bounded generated
request IDs as well as Mongo IDs while retaining existing service lookups,
authentication, roles, permissions, company ownership, payment and persisted
state behavior. Other identifiers remain Mongo IDs; visit actions still require
the actual `frequencyDateId`. No provider application edit or binary is needed
for that compatible server correction.

At that earlier checkpoint R2 was planned; the verified r2 section below
supersedes that status. The canonical
[API contract](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/api-contract.md)
and booking-flow record own its activation and subsequent readable/Mongo GET
results. Source checks do not establish those live results or a provider UI
pass. This follow-up edits documentation only; application code and binaries
remain unchanged and no Flutter suites were rerun.

## Verified r2 server correction and fixture retirement

R2 is now active on DEV: `yourcare:smart-booking-dev-20261107-r2-api`, image
`sha256:eaaab9a8299ed2e21430410df2ef74e043eddba54280604c4ffddc528fac4b6b`.
The lead deployed existing source fix `5514412` in exactly the company controller
and RequestIdDto compiled files; 514 original JS files, including services, auth
and payments, remain unchanged. Public TLS provider detail now returns 200 for
both readable `HK149` and its Mongo ID, with the same completed/paid order.
The R1 readable-ID 400 is historical; the installed provider refresh URL now
passes at the API boundary. No provider client change was needed.

The synthetic company is paused and all three synthetic users are disabled; old
bearers return 401. Order/financial/pricing/availability audit records remain,
with no duplicate debit or hard delete. HK149 remains paid 4.000 KWD from the test
wallet, with the same single booking/invoice/settled hold/payment and unchanged
financial fingerprint. All 33 other services / 22 containers and r2 settings/runtime
remain unchanged and healthy. Canonical backend booking-flow evidence owns the
exact commands, hashes and 22:18–22:22 Kuwait results. Native screens, external
gateway and production remain unverified/unchanged as stated above. The isolated
test emulator was shut down; its AVD/APK remain and the ephemeral login file was
removed. This follow-up adds documentation only; no client build or test rerun.

## 8 November 2026 — API-only scope

The user selected “Continue with API testing only.” Native screen/ADB testing is
excluded from this run; no UI permission request remains pending. The canonical
backend booking-flow record retains HK149’s verified API journey and the fresh
HTTP 200 public readiness check. No app/API/configuration/deployment change,
fixture reactivation, new booking or test-suite rerun for this documentation-only
follow-up. Gateway coverage and date/time picker alignment remain open.
