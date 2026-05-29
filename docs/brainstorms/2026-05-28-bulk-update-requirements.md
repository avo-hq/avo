---
date: 2026-05-28
topic: bulk-update
---

# Bulk Update

## Problem Frame

Avo admin users frequently need to apply the same change to many records — e.g., move 50 tickets to `stage = success`, reassign 200 customers to a new account manager. Today the only built-in path is to write a custom `Avo::BaseAction` per use case, which is heavy ceremony for "edit a few fields on the selected records" and pushes routine operational work onto developers.

This brainstorm proposes a first-class, opt-in **bulk update** flow: select records on the index page, click a button, fill a side slide-out with the resource's editable fields, edit only the fields you want to change, hit submit, and Avo writes the edited values to each authorized record on a best-effort basis.

Affected: end-users of any Avo-built admin panel; Avo gem developers who maintain those panels.

## User Flow

```
Index page                   Slide-out                          Submit
┌──────────────────┐        ┌─────────────────────────────┐
│ [✓] Ticket #1    │        │ Bulk update — 47 picks      │
│ [✓] Ticket #2    │        │                             │
│ [ ] Ticket #3    │        │ ⚠ Updating 44 of 47.        │
│ ...              │        │   3 records excluded.       │      ┌─────────────┐
│                  │  ───▶  │                             │ ──▶  │ Best-effort:│
│ ┌──────────────┐ │        │ Stage:    [________]        │      │ each record │
│ │ Bulk update  │ │        │   ▸ All 44 share            │      │ updated     │
│ └──────────────┘ │        │     stage = success         │      │ independently.│
│  (appears at N≥2)│        │                             │      │ Failures    │
│                  │        │ Priority: [high       ]     │      │ collected   │
│                  │        │   ▸ 4 different values      │      │ and shown.  │
│                  │        │                             │      └─────────────┘
│                  │        │ ── Change Summary ──        │
│                  │        │ Changing: Priority → high   │
│                  │        │ Across 44 records           │
│                  │        │                             │
│                  │        │ [ Submit ]                  │
└──────────────────┘        └─────────────────────────────┘
```

## Requirements

**Activation & Configuration**

- R1. Bulk update is **opt-in per resource** via a `self.bulk_update = { enabled: true, ... }` DSL on the `Avo::Resource` subclass.
- R2. When enabled and **at least two rows are selected** on the index page, a **"Bulk update"** button appears in the existing index toolbar (alongside Actions). The button is hidden at N < 2; users with one record selected use the existing row-edit affordance instead.
- R3. The DSL accepts both `fields:` (allowlist) and `except:` (denylist) options to control which resource fields appear in the slide-out. Both may be combined; `fields:` narrows the universe, `except:` further removes from it.
- R4. With no allow/deny list provided, all editable fields on the resource appear **except** field types or instances that don't bulk-edit safely:
  - File / upload fields
  - `has_many`, `has_many through`, `has_and_belongs_to_many`
  - `has_one` when configured with `nested:` (submits nested attributes)
  - `KeyValue` (whole-JSON replace is destructive)
  - `Password` fields
  - Any field with `field.updatable == false`, or any field with `hide_on :edit` / `hide_on :forms`
  Developers can opt risky fields back in by listing them in `fields:`, accepting the cost.

**Slide-out UX**

- R5. Clicking "Bulk update" opens a **side slide-out** (new UI shell, distinct from Avo's existing centered `Avo::ModalComponent`).
- R6. Form inputs are **never prefilled**. Each field renders blank, regardless of whether the selected records share a value.
- R7. Below each field, render a **status notice** describing the current state of that field across the **authorized** subset of selected records:
  - When all N share the same value: `All N records have <field> = <value>`.
  - When values differ and there are few distinct values (suggested threshold: up to 5 distinct values; planning to confirm): `<N> different values: <v1>, <v2>, <v3>`.
  - When values differ and there are more distinct values than the threshold: `<N> different values` (count-only, no sample list).
- R8. Above the Submit button, render an **inline change summary** that updates live as the user edits: `Changing: <field1> → <value1>, <field2> → <value2>. Across N records.` The change summary is the single user-facing surface for "what will be written" — there is no per-field "will be written" badge.
- R9. The change summary is enabled by default and **dev-disable-able** via a flag in the DSL.

**Write Semantics**

- R10. Use **dirty-tracking** to decide what to write: each field component tracks whether the user has actually changed its value (focus alone doesn't count). Only changed fields are submitted; on the server, only submitted fields are written to each record. Untouched fields are left alone — every selected record keeps its existing value for those fields. (This replaces an earlier "presence rule" design that didn't survive contact with Avo's full field set — `cast_nullable`, checkboxes that always submit, multi-select, select-with-blank-option all made "blank means skip" ambiguous. Dirty-tracking is field-type-agnostic.)
- R11. Writes are **best-effort by default**: each authorized record is updated independently. Per-record validation/callback failures are collected and reported after submit (`Updated 48 of 50. Failed: <record A: reason>, <record B: reason>.`). The slide-out's dirty form state is preserved so the user can correct and resubmit without retyping. Devs needing transactional all-or-nothing semantics opt in via the R12 override.
- R12. Resources may **override the default write strategy** by defining a `handle_bulk_update(records:, attributes:, current_user:)` method (exact signature TBD in planning) on the resource. This is the escape hatch for transactional batches, validate-first, partial-commit, custom audit, etc. Devs taking the override are responsible for re-implementing any guarantees the default provides (per-record `update?` re-check at write time, dirty-field honoring, audit gem integration). The framework-level audit event in R18 fires regardless, providing a minimum audit floor.

**Authorization & Request Integrity**

- R13. On clicking "Bulk update", the server filters the selected records to the subset the user is authorized to update (per the resource's existing `update?` policy). The slide-out opens with a banner: `Updating <K> of <N> selected records. <N-K> records were excluded (you don't have permission to edit them).` The notice is **count-only** — record IDs/titles are not listed (prevents existence-leak of records the user couldn't otherwise read). The submit endpoint **re-runs `update?` per record at write time** (defense-in-depth against tampered IDs and against authz drift between open and submit); records that fail the re-check at write time are reported in the per-record failure list under R11.
- R17. The submit endpoint enforces a **server-side permitted-params allowlist** derived from the same DSL configuration (`fields:` + `except:` + auto-exclusions in R4). Keys outside the allowlist in the POSTed payload are dropped silently — defense against tampered clients adding `role`, `password_digest`, `account_id`, or auto-excluded fields. The "select all matching filter" path additionally re-applies `policy_scope` to the decrypted query so records outside the current user's visible scope can't be reached through query replay.

**Audit**

- R18. A **framework-level audit event** fires per bulk-update submission, capturing: actor (`current_user` identifier), resource, list of record IDs that were updated, list that failed (with reasons), and the set of attributes the user attempted to write. This event fires **regardless of whether `handle_bulk_update` (R12) is overridden** — providing an audit floor even when devs replace the default write strategy. (Surface mechanism — `ActiveSupport::Notifications`, structured logger entry, or both — deferred to planning.)

**Scale (sync-only in v1)**

- R14. v1 is **synchronous-only**. Each submission runs inside the request and the user sees the result immediately.
- R15. Submissions are capped at a **hard upper bound on record count** (default TBD; suggested ~500). Above the cap, the slide-out shows a clear error ("Too many records selected; bulk update supports up to 500 records per submission") and the user must narrow their selection. Async/queued dispatch is **deferred to v1.1** — real usage data will drive whether and how it ships.

## Success Criteria

- A developer can enable bulk update on a typical resource in **one line of DSL** with no custom code.
- An admin user can select 47 tickets, change `stage` to `success` and `priority` to `high`, and complete the workflow in well under a minute without any developer involvement.
- A user attempting to bulk-update records they don't have permission on **sees the authorized subset** in the slide-out with a clear count of excluded records — they are not blocked from proceeding.
- A user whose batch contains a small number of failing records (validation, callbacks) gets a **per-record failure list**, retains their form state, and can retry against the failing subset without retyping.
- Developers can opt out of any auto-included risky field type and override write semantics on resources with non-standard requirements (transactional batches, custom audit, etc.) via R12.
- A tampered request that POSTs disallowed fields or unauthorized record IDs cannot escape the server-side allowlist (R17) or the per-record `update?` re-check (R13).
- Every bulk-update submission produces a framework-level audit event (R18), even when R12 is overridden.

## Scope Boundaries

- **No bulk-clearing a field to NULL** in v1. Dirty-tracking has no way to express "set this to NULL" without an explicit Clear affordance; that affordance is deferred to v1.x.
- **No bulk-update at N=1**: the button is hidden when fewer than two rows are selected. Single-record edits use the existing edit page.
- **No queued / async dispatch** in v1 (deferred to v1.1). v1 is sync-only with a hard record-count cap; the "select all matching filter" 5,000-record case is out of scope until usage data justifies the async build.
- **No bulk-update of `has_many`, `has_many through`, `has_and_belongs_to_many`, or nested `has_one` associations** by default (auto-excluded in R4).
- **No multi-resource bulk update** (mixing record types in one slide-out).
- **No dedicated bulk-update history/diff view** as a separate feature. Existing audit gems (e.g., `paper_trail`) capture per-record diffs via the default `update!` path; the framework audit event (R18) provides a per-submission floor.
- **No undo / revert** in v1.
- **No saved bulk-update presets** in v1.
- **No dry-run / preview-before-submit** in v1.
- **No keyboard shortcut bindings** in v1 (custom shortcuts only — keyboard *accessibility* including focus management, Esc, tab order is still expected).
- **No `bulk_update?` policy method** assumed in v1; v1 reuses per-record `update?`. May be revisited in planning.

## Key Decisions

- **Opt-in per resource via DSL hash.** Matches Avo's existing pattern (devs explicitly enable powerful features) and avoids surprise behavior on resources with unique-key fields or hidden constraints.
- **No prefill + notice under field.** Avoids the "did I just re-write all N records to the same value?" ambiguity. Notices give context without the form lying about state.
- **Dirty-tracking instead of presence rule.** The original "blank = skip" rule broke across Avo's field types (`cast_nullable`, checkboxes that always submit, multi-select, select-with-blank). Dirty-tracking is field-type-agnostic: only fields the user actually changed are written. Cost: no bulk-clearing without an explicit Clear affordance, which is deferred.
- **Best-effort writes by default, transactional via override.** Matches admin-tool conventions (Retool, Django admin, Forest Admin). One stale record can't block 49 others. Devs needing atomicity opt in via R12.
- **Filter authorized subset + count-only notice (R13).** The earlier block-and-list-IDs design was hostile at scale and leaked record existence. Filter-and-notice scales to "select all matching filter" gracefully. Submit re-check provides defense-in-depth.
- **Server-side allowlist + per-record authz re-check.** Client state (selected IDs, field set) is never trusted at the submit boundary. R17 + R13 second clause together close the obvious tampering vectors.
- **Framework-level audit event regardless of override (R18).** Even when devs replace the default with R12, there is always a record of who bulk-updated what.
- **Sync-only with a hard cap in v1; async deferred to v1.1.** Sync removes ~30% of v1 surface (Active Job, threshold config, completion notification surface, TOCTOU/idempotency, ActionCable infra add). Real usage data drives whether and how async ships.
- **Inline summary in the slide-out, no second confirmation modal.** Avoids confirmation fatigue while still surfacing blast radius before submit. The summary is the user-facing surface for dirty-tracking — no per-field badges needed.

## Dependencies / Assumptions

- Avo's existing **selected-records Stimulus state** (`item_selector_controller.js`, `item_select_all_controller.js`) carries the IDs that bulk update reads on click.
- Avo's existing **field edit components** render inside `Avo::BaseAction` forms today *with* an underlying `@record` and a forced `:new` view to suppress prefill. Bulk update needs a **new view-inquirer state** (e.g., `view.bulk_edit?`) so that per-field prefill (`should_fill_with_default_value?`, Boolean `checked`, FK `id_input_foreign_key`) can branch off cleanly. This is more than a thin reuse of the existing Action rendering path — planning must design it explicitly.
- The index toolbar Stimulus wiring (`item_select_all_controller#updateLinks`) must be extended to rewrite the bulk-update URL with `resource_ids` / `avo_index_query` / `avo_selected_all` parallel to how it does for Actions today.
- **Dirty-tracking infrastructure** (per-field "user changed this value" detection) will be needed across all field-edit components. Likely a small Stimulus controller plus a per-component contract for emitting reliable change events. The bulk-update form listens and submits only dirty keys.
- A new **slide-out (side panel) UI shell** is required; Avo today has only the centered `Avo::ModalComponent`. Whether to extend that component or build a new one is a planning decision. Either way the shell must support: X-button close, Esc close, click-outside dismiss (with confirm-if-dirty), focus trap, initial focus on first field, body-scroll lock, `aria-describedby` linking R7 notices to their fields, and a live region for the R8 summary.

## Outstanding Questions

### Deferred to Planning

- [Affects R7] [User decision, deferable] Sample-listing threshold: above how many distinct values do we drop the sample list and show count-only? Suggested 5; planning to confirm against realistic field cardinality. Same question for sample length on long-text fields (truncate vs fall back to count-only).
- [Affects R5] [Technical] Does the slide-out component extend `Avo::ModalComponent` (mirroring its lifecycle + Stimulus pattern with a right-anchored layout) or stand up as a new `Avo::SlideOverComponent`? See Dependencies for the a11y / lifecycle floor either choice must hit.
- [Affects R10] [Technical] Dirty-tracking implementation strategy — Stimulus controller per field component with a shared "changed" event the bulk-update form listens for. Must work consistently across text, select, boolean, multi-select, belongs_to (search), date, money, JSON. Field components may need small additions to emit reliable signals.
- [Affects R11] [Technical] Failure-reporting UI shape inside the slide-out: inline list above Submit, replace the form with a result panel, or a "retry failed records" affordance? Planning to design once the v1 success/error wire-up is in flight.
- [Affects R12] [Technical] Exact signature of `handle_bulk_update`. Recommend a `class_attribute`/lambda pattern (sibling to `find_record_method`) so devs override via DSL rather than method redefinition, avoiding name-collision with user-defined resource methods.
- [Affects R13] [Technical] Should a separate `bulk_update?` policy method exist on resource policies (so an admin can block a user from using bulk update at all, independent of per-record `update?`)?
- [Affects R15] [User decision, deferable] Default value for the sync hard cap (suggested ~500). Planning to confirm against typical Rails request timeout and per-record write latency (callbacks, audit gems).
- [Affects R18] [Technical] Audit event surfacing — `ActiveSupport::Notifications`, structured logger entry, or both? Should it be configurable?
- [Affects R10] [User decision, deferable] Explicit per-field "Clear" affordance (enables NULL writes). Out of scope for v1 unless planning surfaces a strong reason to include it.

## Next Steps

→ `/ce:plan` for structured implementation planning.
