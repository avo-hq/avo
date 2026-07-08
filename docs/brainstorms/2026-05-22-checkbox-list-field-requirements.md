---
date: 2026-05-22
topic: checkbox-list-field
---

# Checkbox List Field

## Problem Frame

Avo's existing multi-select story (`select_field` with `multiple: true`) hides options behind a dropdown and a click-to-add loop. For short option sets — roughly 5–20 items — that adds friction with no upside: the user already knows the full list and just wants to tick what applies. Above ~20 options without a search affordance, a flat scrollable list becomes worse UX than the dropdown it replaces; those sets wait for the typeahead iteration that lives on top of this same field.

We want a new field type that lays the options out vertically as a scrollable checkbox list, so the user can see and pick directly. The submitted value is an array of IDs, identical in shape to what `addon_ids=` and similar association setters already expect.

The visual target is the rich item row used by the Pro global-search results (avatar / title / description, with room for a badge), but the first iteration ships only the bare minimum — ID + title — and grows from there.

## Requirements

**Field shape and API**
- R1. New field type registered as `checkbox_list`, usable as `field :addon_ids, as: :checkbox_list`.
- R2. The field accepts a required `options:` kwarg taking an Array or a Proc/callable, evaluated via `Avo::ExecutionContext` (the same pattern `select_field` uses). The block must return an array of hashes with explicit keys: `[{ id: 1, title: "Foo" }, ...]`. The result is memoized per form render so the block is invoked at most once per request, even when the form re-renders for validation errors.
- R3. In iteration 1, only `id` and `title` keys are read. Extra keys (e.g. `avatar_url`, `description`, `badge`) may be included now without error — they are ignored until a later iteration consumes them. Callers who write only `{ id:, title: }` today should not need to rewrite their block when richer keys ship.
- R4. The block can query the DB, hit an API, or build a static list — the field has no knowledge of where the data came from. **The block must be cheap and side-effect-free, because the same block will be re-run on the iteration-2 Show view with the stored IDs filtered.** Developers writing expensive blocks should add their own caching outside the field.

**Edit / New rendering**
- R5. Each row is a `<label>` wrapping a native `<input type="checkbox">` and the row content. Clicking anywhere in the row toggles the checkbox via native label semantics — no Stimulus controller is involved in selection. The list lives inside a `<fieldset>` with a `<legend>` carrying the field's name so screen-reader users hear the group label, and keyboard tab order is the natural document order.
- R6. The list has a fixed default visible height that shows roughly 6 typical-height rows; if there are more options than fit, the container scrolls vertically. No configuration knob in iteration 1. Long titles wrap onto a second line — row height grows accordingly, which means very-tall rows reduce the visible-row count below 6. That is acceptable for v1.
- R9. The display order on screen is the order the block returns. The field does not sort.
- R12. Edge data states are handled explicitly:
    - Empty options array → render an empty-state message ("No options available" or similar) inside the container.
    - Single option → render one row at its natural height; the container does not pad to fill 6 rows.
    - Long titles → wrap onto a second line; row grows; no truncation.

**Edit / New behaviour (data flow)**
- R7. On submit, the field posts an array of the selected IDs as strings under `field_name[]`, matching how Rails form params for collection setters look. Avo persistence is the caller's responsibility — pointing the field at `addon_ids` on a `has_many through:` is the canonical use case, but a JSON/serialized array column works the same way.
- R8. The currently stored array of IDs is reflected as pre-checked rows when the form renders. On validation failure, the field re-renders from submitted params (not the stored value) so the user does not lose their in-progress selection.
- R10. Deselecting every option must submit an empty array, not omit the param. This requires a hidden empty-array marker in the form output (as `f.collection_check_boxes` produces by default), a `to_permitted_param` override declaring the param as an array (matching the pattern in `lib/avo/fields/select_field.rb:85-87` and `lib/avo/fields/boolean_group_field.rb:20-22`), and a `fill_field` step that rejects the blank sentinel before assignment (matching `select_field.rb:89-95`). Without this, deselect-all silently leaves stale associations or raises `ActiveRecord::RecordNotFound` from inside the association setter.
- R11. ID comparisons — both for pre-checking on render and for submission round-trip — normalize both sides to string before checking membership. This covers the common case of integer IDs from `addon_ids` vs string IDs from form params, plus UUIDs and other string IDs without special-casing.
- R13. Stored IDs that are not present in the current options array (because an option was removed, filtered, or feature-flagged off) are preserved through round-trip via hidden inputs. The user sees no row for them, but submitting the form does not silently strip them. They cannot be deselected without re-adding them to the options array — that is acceptable; the alternative (silent data loss) is worse.

## Success Criteria

- A developer can swap a `select_field` + `multiple: true` declaration for `checkbox_list` and an `options:` block returning hashes, point it at `addon_ids`, and the form round-trips correctly on Edit/New: pre-checks the stored IDs, submits the new set (including the deselect-all case), and persists through the existing association setter. The replacement is complete only for resources whose Show/Index/Filter surfaces do not need to display this field; iteration 2 fills those in.
- For up to 20 options the UI stays usable on a standard form layout — the scroll container is obvious, the row tap target is large enough for touch (≥44px), keyboard tab order is sensible, and the `<fieldset>`/`<legend>` is announced by screen readers.
- The field's API and component layout leave a clear path to add avatar / description / badge keys in a follow-up without breaking existing callers, and the iteration-2 Show view can be implemented purely by re-running the options block.

## Scope Boundaries

- Iteration 1 ships edit/new rendering only. No show, index, filter, or action-form support.
- Iteration 1 displays only the item title. Avatar, description, and badge are deferred to iteration 2.
- No typeahead, no server-side search, no infinite scroll, no "load more". These belong to a later iteration that adds a search/typeahead mode on top of the same field.
- No direct reuse of Pro's `GlobalSearch::Resources::ItemComponent` in v1 — v1 ships a parallel OSS component (`Avo::Fields::CheckboxListField::ItemComponent`) whose prop names mirror Pro's exactly (`title`, `description`, `image_url`, `image_format`, etc.). The two are intentionally maintained as twins for v1; iteration 2 extracts the shared shape down to an OSS-level component and has Pro consume it from OSS.
- Field always operates in multi-select mode. Single-select via radio is a separate field type, not a mode flag on this one.
- No "Select all" / "Clear all" affordances in iteration 1.
- The field does not validate that submitted IDs exist in the options set. The array is passed through; the model decides.

## Key Decisions

- **Field name: `checkbox_list`.** Describes what the user sees. Pairs cleanly with `select_field` without colliding with it.
- **Options shape: array of hashes with explicit keys, not records or tuples.** Forces the developer to map their data once. Makes the API uniform whether the source is the DB or an API. Extends cleanly to extra keys (`avatar_url`, `description`, `badge`) without rewriting callers.
- **Options block contract is "cheap + side-effect-free + ID-stable".** Iteration 2's Show view will call the same block and filter to the stored IDs. Pinning the contract now means v1 callers don't need to migrate when Show lands.
- **Per-request memoization is in scope for v1.** Cheap to add now, load-bearing to add retroactively if a developer's block ends up hitting an API.
- **Persistence stays the caller's job, but deselect-all is the field's responsibility.** The field submits an array of strings. Pointing it at `addon_ids` lets Rails do the work; pointing it at a JSON column also works. The field never inspects the model, but it does own the hidden-empty-array marker so that "deselect everything" is a real operation rather than a no-op.
- **A11y is native, no Stimulus for selection.** Rows are `<label>`-wrapped, the group is a `<fieldset>` with a `<legend>`, tab order is native. No JS row-click delegation — that pattern fights native label semantics and adds a custom keyboard model without buying anything visual.
- **Edit/New only in iteration 1, Show retrieval contract pinned now.** Show isn't built, but the API is designed against the eventual Show implementation. No deferred architecture question for iteration 2 to resolve.
- **OSS twin component in v1, extraction in v2.** v1's component intentionally mirrors Pro's `GlobalSearch::Resources::ItemComponent` shape. Iteration 2 extracts the shared shape to OSS and removes the duplication. The current dual maintenance is intentional and time-bounded.

## Dependencies / Assumptions

- The visual style (row layout, checkbox placement, scroll container) follows the BEMCSS conventions in `agents.md`, with Tailwind v4 `@apply` rules in the project's component stylesheet (under `app/assets/stylesheets/css/components/`).
- Existing field cousins (`select_field`, `boolean_group_field`, `tags_field`) provide the reference patterns for `to_permitted_param`, `fill_field`, and the form-render-from-params behavior the new field needs.
- The CSS approach for "roughly 6 rows then scroll" is left to implementation; a fixed `max-height` in rem is the expected default given title-only rows in v1.

## Outstanding Questions

### Resolve Before Planning

_None — the brainstorm is complete enough to plan against._

### Deferred to Planning

- [Affects R6][Technical] What CSS technique gives the "approximately 6 rows then scroll" target most robustly — a fixed `max-height` in `rem` (cheap, works fine for title-only v1), or a measure-and-set Stimulus controller (over-engineering for v1, may be needed when v2 rows become avatar-sized)?
- [Affects R3][Needs research] Confirm during implementation that the iteration-2 avatar/description/badge keys can mirror Pro `GlobalSearch::Resources::ItemComponent` prop names (`image_url`, `image_format`, `description`) exactly — a quick read of the Pro component during planning is enough.
- [Affects R13][Technical] When rendering hidden inputs for orphan stored IDs (R13), confirm the form's CSRF/strong-param plumbing accepts them as part of the same `field_name[]` array without special handling.

## Next Steps

→ `/ce:plan` for structured implementation planning
