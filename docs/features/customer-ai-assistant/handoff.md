# Smart Booking Assistant — provider handoff

2026-11-07; branch `codex/customer-ai-assistant`, baseline `3c57549`.

Canonical brief and contract are maintained in backend `docs/features/customer-ai-assistant/` on the matching feature branch:
[brief](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/brief.md),
[API contract](https://github.com/Redab0/you-care-backend/blob/codex/customer-ai-assistant/docs/features/customer-ai-assistant/api-contract.md).
These links require the feature branch to be pushed; local canonical files are in the backend feature worktree.

No provider application or API changes. The customer assistant reads existing catalog/pricing/availability services and sends customers into the existing booking flows. Provider-managed dated capacity, packages, offers and fulfillment remain authoritative. Guided recommendations neither reserve capacity nor create orders. The user selected deterministic rules and explicit service choices with no paid AI calls; there is no external model/key dependency. No new service discriminator, order/visit/payment state, monetary unit, event or provider permission.

Target is DEV first. No provider binary was built, installed, uploaded or deployed for this documentation-only handoff. Current source supports `API_ENV=development` through `lib/core/api/api_environment.dart`; use it only for separately requested provider verification. Original checkout remains on its original branch without modifications.

Checks: named source paths and canonical documents verified; `git diff --check` and repository status inspected. No Flutter checks required for documentation-only changes. Live customer → backend → provider verification is tracked by the canonical brief and must not be inferred from this handoff.
