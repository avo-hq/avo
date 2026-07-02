---
title: "feat: self.table_view row_options resource API"
type: feat
status: completed
date: 2026-05-05
origin: docs/brainstorms/2026-05-04-resource-table-view-row-options-requirements.md
---

# feat: `self.table_view` `row_options` resource API

## Overview

Add a resource-level API — `self.table_view = { row_options: { ... } }` — that lets users declaratively set HTML attributes on `<tr>` elements rendered by `Avo::Index::TableRowComponent`, with optional per-record blocks evaluated through `Avo::ExecutionContext`. Targets the main index table and `has_many` association tables (same component). Extensions to grid/kanban surfaces are explicitly out of scope.

## Problem Frame

Today, users who want to vary row appearance by record state (highlight LLM messages vs user messages, dim soft-deleted rows, tint by status) must override the `Avo::Index::TableRowComponent` partial or fight Avo's component layer. There is no first-class declarative path. This plan adds one, with a merge contract that preserves Avo's existing row behaviors (selection, click-to-view, drag-to-reorder, hover) (see origin: `docs/brainstorms/2026-05-04-resource-table-view-row-options-requirements.md`).

## Requirements Trace

Carried forward from the origin requirements doc with stable IDs preserved.

- **R1** — `self.table_view = { row_options: { ... } }` lives on `Avo::Resources::Base` as a `class_attribute`; namespace designed to grow.
- **R2** — Supported HTML keys: `class`, `data`, `style`, `title`, `aria-*` (with allowlist), and other passthrough attributes. `id`, `role`, `aria-selected`, and event handlers are **rejected**.
- **R3** — Applies wherever `Avo::Index::TableRowComponent` renders (index + `has_many` association tables).
- **R4** — `row_options` may be a Hash or a block returning a Hash; per-value blocks supported.
- **R5** — Blocks evaluated via `Avo::ExecutionContext`; documented locals: `record`, `resource`, `view` (derived as `@reflection.present? ? :has_many : :index`).
- **R6** — Blocks evaluate inside the `<tr>` ERB template (after the `cache_table_rows` boundary).
- **R7** — User `class` appended to Avo's via `class_names`; user wins at equal CSS specificity.
- **R8** — User `data` deep-merged with Avo's, with two precedence carve-outs:
  - `data-controller` and `data-action` are **token-concatenated** (Stimulus token-list semantics).
  - All other reserved keys are **Avo-wins**, with a development-mode warning when user attempts to set them.
- **R9** — User `id` is rejected (`ArgumentError` in dev/test, log + ignore in production).
- **R10** — Other HTML attributes pass through to `content_tag :tr` and are HTML-escaped by Rails.
- **R11** — Block return-type contract: `nil`/`false` omits attribute; `String`/`Symbol` coerced; `Array<String>` and `Hash<String, Boolean>` valid only for `class:` (routed through `class_names`); other return types raise `ArgumentError` in dev/test, in production fall back to Avo defaults and report via `Rails.error`.

## Scope Boundaries

- **No `cell_options`** in this iteration. When added, cell options will live on the **field DSL** (not under `self.table_view`) with cell-wins-over-row precedence for `class`/`style`/`data` overlap. Documented as a future-compat decision so consumers know what to expect.
- **No grid/kanban equivalents.** `self.grid_view = { ... }` already exists as the future home for grid card options.
- **No predefined "row state" presets** (`:highlighted`, `:warning`).
- **No automatic Tailwind safelist help** — user owns `tailwind.config.js`; the docs page provides a copy-paste safelist recipe.
- **Resources only** — no per-controller or per-action overrides.
- **No new component prop on `TableRowComponent`** — `view` is derived from `@reflection.present?` inside the component.

## Context & Research

### Relevant Code and Patterns

| Concern | Path | Notes |
|---|---|---|
| Resource DSL home | `lib/avo/resources/base.rb` | `class_attribute :grid_view` (line 70) is the closest precedent — declared without a default to avoid the `class_attribute` Hash-default inheritance footgun |
| Block-evaluation precedent | `lib/avo/resources/base.rb:259-262` (`fetch_search`) and `app/components/avo/index/grid_item_component.rb:14-17` (grid card) | Both pass `record:` and `resource:` to `Avo::ExecutionContext.new(target:, ...).handle` |
| Component to modify | `app/components/avo/index/table_row_component.rb` and `.html.erb` | Renders `<tr>` for both `:index` and `:has_many` |
| View derivation precedent | `app/components/avo/views/resource_index_component.rb` (lines 18, 23, 38, 61, 101, 112, 166, 182) and `app/components/avo/resource_component.rb` (lines 15, 21, 47, 60, 326) | The `@reflection.present?` ternary is widely used for has_many vs index branching. (Note: brainstorm cited `ResourceControlsComponent` as the precedent — that component actually takes an explicit `view_type` prop. The right reference is `ResourceIndexComponent` / `ResourceComponent`.) |
| Cache boundary | `app/components/avo/view_types/table_component.rb` (`cache_table_rows`, lines 38-53) | Wraps **construction** of `TableRowComponent` instances, not ERB rendering. Per-row block evaluation must happen inside the ERB template (`content_tag :tr, ...`) so each render re-evaluates regardless of `cache_resources_on_index_view` |
| `class_names` helper | Rails-native `ActionView::Helpers::TagHelper#class_names` / `token_list` | Already used at `table_row_component.html.erb:5`. Accepts `String`, `Array<String>`, `Hash<String, Boolean>` mixed — R7's input forms come for free |
| Reserved data keys (always set) | `table_row_component.html.erb:6-16`, `app/helpers/avo/resources_helper.rb:40-46` (`item_selector_data_attributes`) | `index`, `component_name`, `resource_name`, `record_id`, `controller`, `resource_id` |
| Reserved data keys (click-to-view) | `table_row_component.html.erb:11-14` | `visit_path`, `action` (action is a space-separated token list) |
| Reserved data keys (drag-reorder) | `avo-pro/lib/avo/pro/concerns/can_reorder_items.rb:24-38` | `reorder_target` (only this key on `<tr>`; the reorder controller itself sits on `<tbody>`) |
| Dark mode | `app/assets/stylesheets/css/variables.css` | Avo flips CSS custom properties under `.dark`. Components use semantic utilities (`bg-primary`, `bg-secondary`, `text-content-secondary`). User-supplied classes use Tailwind `dark:` modifiers since they're outside the semantic system |
| Test fixtures for row component | `spec/dummy/app/components/avo/for_test/table_row_component.rb`, `spec/features/avo/resource_custom_components_spec.rb:49-58` | Custom-component override path; useful as a feature-spec template |
| AGENTS.md / CLAUDE.md | `gems/avo/AGENTS.md`, `gems/CLAUDE.md` | Tailwind v4, Hotwire, prop_initializer; "smart code, not too smart" favors a small concern module over a metaclass DSL |

### Institutional Learnings

- **Frozen-defaults + merge reader pattern** — `docs/solutions/best-practices/configurable-keyboard-shortcuts-avo.md`. Establishes the in-house pattern for namespaced hash configs in Avo (`HOTKEYS_DEFAULTS = {...}.freeze` + writer + merging reader). The shape applies to `table_view` even though that learning is configuration-level rather than resource-level.
- **No prior art** for: Stimulus token-list merging, `Avo::ExecutionContext` footguns, ViewComponent + Turbo Stream broadcast row-update context, Tailwind v4 safelist for user-supplied classes, HTML-attribute denylists in Rails apps, ARIA on `<tr>`/table semantic guidance, cache boundary issues with `cache_resources_on_index_view`. Treat these as fresh territory; capture solution-level decisions afterward in `docs/solutions/`.

### External References

External research was not run — repo patterns are dense (multiple `class_attribute` precedents, ExecutionContext call sites, the existing `<tr>` template) and the brainstorm already established the API shape. Standard Rails `class_names` / `token_list` semantics are sufficient for class and Stimulus token merging.

## Key Technical Decisions

- **Backing storage: `class_attribute :table_view` (no default).** Mirrors `self.grid_view` (`lib/avo/resources/base.rb:70`). Avoids the Rails `class_attribute` Hash-default inheritance bug where subclass mutations leak into the parent's default. Reader normalizes `nil → {}` at the use site.
- **Block evaluation site: ERB template, not `before_render`.** `cache_table_rows` wraps component construction. Evaluating inside the `content_tag :tr, ...` block in `.html.erb` ensures per-render evaluation regardless of `cache_resources_on_index_view`, so user-context-dependent blocks stay correct across users (see origin R6).
- **`view` derivation: inside `TableRowComponent`, no new prop.** `def view; @reflection.present? ? :has_many : :index; end`. Re-uses the `@reflection.present?` branching pattern already used throughout `ResourceIndexComponent` / `ResourceComponent`.
- **Merge contract:**

| Key | Strategy |
|---|---|
| `class` | `class_names(avo_classes, user_classes)` — Rails-native, user wins at equal CSS specificity |
| `data-controller`, `data-action` | **Token-concat** — split on whitespace, union tokens preserving Avo's, re-join. Reuses Rails `token_list` |
| Other reserved data keys (`index`, `component_name`, `resource_name`, `record_id`, `resource_id`, `visit_path`, `reorder_target`) | **Avo-wins.** User attempts trigger `Rails.logger.warn` (or `Avo.error_manager.warn` if available) in development; silently dropped in production |
| Non-reserved data keys | Last-wins (user wins) — matches the existing splat-merge behavior in `table_row_component.html.erb` |
| `id` (top-level attribute) | **Rejected.** `ArgumentError` listing supported keys in development/test; `Rails.error.report` + ignore in production |
| `role`, `aria-selected` | **Rejected.** Same dev-raise / prod-log policy as `id` (semantic table integrity, Avo-owned selection state) |
| `onclick` and other `on*` event handlers | **Rejected** (denylist). Raise in dev/test, log in production |
| `tabindex`, `contenteditable`, `draggable` | **Rejected** (denylist). Same policy |
| Other HTML attributes (`style`, `title`, `aria-label`, `aria-describedby`, etc.) | Pass-through. HTML-escaped by `content_tag` |

- **Block return-type contract:**
  - `nil` / `false` → attribute is omitted entirely (do-not-set semantics).
  - `String` / `Symbol` → `to_s`.
  - `Array<String>` / `Hash<String, Boolean>` → valid only for `class:`, routed through `class_names`. Returning these for other keys raises.
  - Anything else → `ArgumentError` in dev/test; in production, the row falls back to Avo defaults and the exception is reported via `Rails.error.report` (or `Avo.error_manager` if available).
- **Where the merge logic lives: a small module, not inline in the component.** New `Avo::Concerns::TableRowOptionsMerger` (or similar; final name TBD during implementation) under `lib/avo/concerns/`. Pure Ruby, fully testable in isolation. Rationale: merge logic is non-trivial (token-concat, denylist enforcement, return-type coercion), and inlining it makes `TableRowComponent` harder to scan. Mirrors the `lib/avo/concerns/` pattern already used by `RowControlsConfiguration`.
- **Performance instrumentation:** `ActiveSupport::Notifications.instrument("avo.row_options.evaluate", resource:, view:, record_id:)` wraps each row evaluation, allowing users to profile slow blocks via `Rails.logger.subscribe`.
- **Dual block forms preserved.** Top-level `row_options: -> { {...} }` AND per-value `class: -> { ... }` both supported, matching origin R4. The merger handles both transparently — top-level block evaluated first; the resulting hash's per-value blocks evaluated next.

## Open Questions

### Resolved During Planning

- **`class` input forms (origin OQ for R7).** Rails-native `class_names` accepts `String`, `Array<String>`, `Hash<String, Boolean>` mixed. All three forms ship for free.
- **`data` merge collision strategy (origin OQ for R8).** Token-concat for `controller`/`action`; Avo-wins on the rest of the reserved list with dev-mode warning; last-wins for non-reserved keys (matches the existing splat-merge in `table_row_component.html.erb`).
- **`view` derivation (origin OQ for R3).** Derived inside `TableRowComponent` from `@reflection.present?`. No new component prop required.
- **`class_attribute` backing pattern (origin OQ for R1).** `class_attribute :table_view` with no default; reader normalizes `nil → {}`. Matches `self.grid_view`.
- **Hash-with-blocks pattern survey (origin OQ for R4).** `self.search` (lines 58, 251-262) and `self.grid_view` (line 70 + `grid_item_component.rb:14-17`) are the canonical precedents. Mirror their shape — store hash on `class_attribute`, evaluate via `Avo::ExecutionContext` at use site.
- **Dangerous-attribute denylist (review P1 D3).** `id`, `role`, `aria-selected`, `on*` event handlers, `tabindex`, `contenteditable`, `draggable`. Dev/test raise; production log + ignore. Documented in user-facing docs.
- **ARIA policy (review P1 D4).** `role` denied (implicit `row` is canonical for `<tr>` inside `<table>`); `aria-selected` denied (Avo-owned). `aria-label`, `aria-describedby`, and other ARIA attributes pass through.
- **Hover / focus / selected state co-existence (review P1 D1).** Documented as user responsibility. Recommended pattern: use semitransparent backgrounds (e.g., `bg-blue-50/60`) so Avo's hover/selected overlays remain visible, OR use Tailwind's `hover:` and `aria-selected:` modifiers in user classes. The docs page includes a working example.
- **Dark mode (review P1 D2).** Documented as user responsibility. Recommended pattern: pair every light-mode utility with a `dark:` variant (e.g., `bg-blue-50 dark:bg-blue-950/40`), or use Avo's semantic CSS variables (`var(--color-foreground)`, etc.) in inline `style:` attributes.
- **Cell-level forward-compat (review P1 product-lens).** Explicitly out of scope for this iteration. When `cell_options` ships, it will live on the **field DSL** (not under `self.table_view`) and override row-level `class`/`style` for the cell when both are present. This is documented in Scope Boundaries so consumers know what to expect.
- **Tailwind safelist (review P1 P6).** Promoted to a docs deliverable in Unit 6. The docs page includes a copy-paste `safelist:` snippet for `tailwind.config.js`.
- **Migration path for monkey-patchers (review P2 P5).** `row_options` runs in the stock `TableRowComponent` render path. Users who override the entire component bypass the API; documented in the migration section of the docs page with guidance on how to remove the override.

### Deferred to Implementation

- **Turbo Stream broadcast `view:` accuracy.** The `@reflection.present?` derivation only works if the broadcast re-render carries the same reflection context. Confirm during implementation by triggering a record-update broadcast inside an association panel and asserting `view: :has_many` resolves correctly. If broadcasts default to `:index` regardless, document the limitation rather than reshaping the API.
- **Polymorphic and `has_one`-as-table edge cases.** Confirm during implementation that `@reflection.present?` resolves to `true` for `has_many :through`, polymorphic `has_many`, and any `has_one` rendering through `TableRowComponent`. If a distinct symbol is needed (e.g., `:has_one`), introduce it then; otherwise the binary derivation is sufficient.
- **Exact location and final name of the merger module** — `Avo::Concerns::TableRowOptionsMerger` vs. `Avo::TableRow::OptionsMerger` vs. inline private methods. Decide once the merge code is drafted; favor whatever scans cleanest in `TableRowComponent`.
- **`Rails.error` vs `Avo.error_manager` for production reporting** — pick whichever existing primitive Avo already uses for non-fatal errors; consistency over novelty.
- **Whether the instrumentation hook should be active by default** or gated behind a config flag if it shows up as noise in production logs. Default-on is preferred; revisit if profiling shows overhead.
- **Whether `aria-selected` needs to be **emitted by Avo** based on selection state** (not just denied to users). Out of scope here unless implementation reveals a11y testing flagging this. Track separately if needed.

## High-Level Technical Design

> *This illustrates the intended approach and is directional guidance for review, not implementation specification. The implementing agent should treat it as context, not code to reproduce.*

```
┌──────────────────────────────────────────────────────────────────────┐
│ Avo::Resources::Message                                              │
│   self.table_view = { row_options: { class: -> { ... }, data: ... }} │
│         │                                                            │
└─────────┼────────────────────────────────────────────────────────────┘
          │ class_attribute storage on Resources::Base
          ▼
┌──────────────────────────────────────────────────────────────────────┐
│ Avo::Index::TableRowComponent                                        │
│   def view = @reflection.present? ? :has_many : :index               │
│                                                                      │
│   def merged_tr_attributes                                           │
│     Avo::Concerns::TableRowOptionsMerger.call(                       │
│       avo_attributes: { id:, class:, data: },                        │
│       user_options: @resource.class.table_view,                      │
│       record: @resource.record, resource: @resource, view: view      │
│     )                                                                │
│   end                                                                │
└──────────────────────────────────────────────────────────────────────┘
          │ called inline in .html.erb (after cache boundary)
          ▼
┌──────────────────────────────────────────────────────────────────────┐
│ Avo::Concerns::TableRowOptionsMerger.call                            │
│  1. Resolve top-level block: instance_exec via ExecutionContext      │
│  2. For each key, resolve per-value block (same path)                │
│  3. Validate return types per R11; raise/log on mismatch             │
│  4. Enforce denylist: id, role, aria-selected, on*, tabindex,        │
│     contenteditable, draggable -> raise in dev, log in prod          │
│  5. Class merge: class_names(avo_class, user_class)                  │
│  6. Data merge:                                                      │
│       a. Token-concat: controller, action (Rails token_list)         │
│       b. Avo-wins on reserved keys; warn if user set them in dev     │
│       c. Last-wins for non-reserved keys                             │
│  7. Pass-through for other HTML attributes                           │
│  8. Wrap in ActiveSupport::Notifications.instrument                  │
│     "avo.row_options.evaluate"                                       │
└──────────────────────────────────────────────────────────────────────┘
          │
          ▼
       content_tag :tr, **merged_attributes do ... end
```

## Implementation Units

- [ ] **Unit 1: Add `class_attribute :table_view` to `Resources::Base`**

**Goal:** Establish the resource-level configuration storage and the read path.

**Requirements:** R1, R2, R4

**Dependencies:** None.

**Files:**
- Modify: `lib/avo/resources/base.rb`
- Test: `spec/lib/avo/resources/base_spec.rb` *(create if missing — confirm during implementation)*

**Approach:**
- Add `class_attribute :table_view` near the other view config (next to `class_attribute :grid_view` at line 70). No `default:` value — assign `nil`-by-default so subclasses don't share a mutable Hash.
- Add a small reader on the resource that normalizes `nil → {}` and returns the raw hash. Name TBD during implementation (`table_view_options`, `resolved_table_view`, etc.); pick the name that scans cleanest.
- The reader returns the **raw** hash. Block resolution happens in the merger, not here. This keeps the resource simple and the merger fully testable.

**Patterns to follow:**
- `class_attribute :grid_view` declaration (`lib/avo/resources/base.rb:70`).
- `fetch_search` reader pattern (`lib/avo/resources/base.rb:259-262`) — class-level method that returns a normalized value.

**Test scenarios:**
- Happy path: `self.table_view = { row_options: { class: "my-class" } }` on a resource subclass returns the hash from the reader.
- Edge case: When unset, the reader returns `{}`, not `nil`.
- Edge case: Setting `self.table_view = nil` on a subclass returns `{}` from the reader.
- Edge case: Subclass inheritance — `Parent.table_view = { row_options: { class: "a" } }`; `Child < Parent` reads the same value; `Child.table_view = { row_options: { class: "b" } }` does NOT mutate `Parent.table_view`. Confirms `class_attribute` semantics with `nil` default avoid the inheritance footgun.

**Verification:**
- `Avo::Resources::Base.table_view` reads as `nil` (or via reader as `{}`).
- A subclass can assign `self.table_view` and read it back without affecting siblings.

---

- [ ] **Unit 2: Build the row attribute merger module**

**Goal:** Pure Ruby module that takes Avo's stock `<tr>` attributes plus the resource's `row_options` and returns the merged attribute hash, applying every rule in the merge contract.

**Requirements:** R5, R6, R7, R8, R9, R10, R11

**Dependencies:** Unit 1 (consumes `table_view`).

**Execution note:** Test-first. The merge contract has many cases (token-concat, denylist, return-type coercion, dev/prod error policy, class_names input forms). Drive each case from a failing spec before implementing.

**Files:**
- Create: `lib/avo/concerns/table_row_options_merger.rb` *(final name TBD during implementation)*
- Test: `spec/lib/avo/concerns/table_row_options_merger_spec.rb`

**Approach:**
- Single entry point (e.g., `.call`) accepting kwargs: `avo_attributes:`, `user_options:`, `record:`, `resource:`, `view:`. Returns a Hash suitable for `content_tag :tr, **result do ... end`.
- Steps in order (see High-Level Technical Design):
  1. Resolve top-level block in `user_options` if `responds_to?(:call)` — evaluate via `Avo::ExecutionContext.new(target: user_options, record:, resource:, view:).handle`.
  2. For each key in the resolved hash, if value `responds_to?(:call)`, evaluate it through ExecutionContext with the same locals.
  3. Validate per-value return types (R11). For non-`class:` keys, allow `nil`/`false`/`String`/`Symbol`. For `class:`, additionally allow `Array<String>` and `Hash<String, Boolean>`. Otherwise raise `ArgumentError` in dev/test, fall back to Avo defaults + report via `Rails.error.report` in production.
  4. Apply denylist before merging: `id`, `role`, `aria-selected`, any `on*` event handler, `tabindex`, `contenteditable`, `draggable`. Same dev/prod policy.
  5. Merge `class`: `class_names(avo_attributes[:class], user_value)`.
  6. Merge `data`:
     - For `controller` and `action`, use Rails `token_list(avo_value, user_value)` to dedupe and concatenate Stimulus tokens.
     - For other reserved keys (`index`, `component_name`, `resource_name`, `record_id`, `resource_id`, `visit_path`, `reorder_target`), Avo-wins. Emit `Rails.logger.warn` (or `Avo.error_manager.warn` if available) in development when user attempts to set one.
     - For non-reserved keys, last-wins (user value).
  7. Pass through other HTML keys unmodified.
  8. Wrap the entire evaluation in `ActiveSupport::Notifications.instrument("avo.row_options.evaluate", resource:, view:, record_id:)`.
- The reserved-key list is a frozen constant on the module so tests and downstream code can reference it.

**Patterns to follow:**
- `Avo::ExecutionContext.new(target:, **kwargs).handle` — call shape established at `lib/avo/resources/base.rb:261` and `app/components/avo/index/grid_item_component.rb:14-17`.
- Rails `class_names` / `token_list` (`ActionView::Helpers::TagHelper`) — already used at `table_row_component.html.erb:5`.
- `lib/avo/concerns/row_controls_configuration.rb` — small concern module with frozen constants and a clear public surface.

**Technical design:** *(directional sketch only — see High-Level Technical Design above for the full pipeline)*

```
TableRowOptionsMerger.call(avo_attributes:, user_options:, record:, resource:, view:)
  resolved = resolve_top_level(user_options, record:, resource:, view:)  # may be {}
  resolved = resolve_per_value(resolved, record:, resource:, view:)
  resolved = enforce_denylist!(resolved, env: Rails.env)
  merge_class(avo_attributes, resolved)
  merge_data(avo_attributes, resolved)  # token_list for controller/action, Avo-wins for reserved, last-wins otherwise
  passthrough_other(avo_attributes, resolved)
```

**Test scenarios:**
- *Happy path — class merge:* user `class: "highlight"` results in `<tr class="table-row group z-21 highlight">`.
- *Happy path — class as Array:* user `class: ["a", "b"]` → `class_names` joins them.
- *Happy path — class as Hash:* user `class: { "active" => true, "disabled" => false }` → only `"active"` applied.
- *Happy path — top-level block:* `row_options: -> { { class: record.role } }` evaluates with record in scope.
- *Happy path — per-value block:* `class: -> { record.role == "agent" ? "x" : "y" }` evaluates with record in scope.
- *Happy path — `view` local:* block uses `view == :has_many ? "compact" : "roomy"` and resolves correctly when called with `view: :has_many`.
- *Happy path — non-reserved data:* user `data: { test_id: "row" }` → merged into `<tr>` data.
- *Happy path — passthrough:* user `title: "hello"` lands on `<tr title="hello">`.
- *Edge case — nil/false return:* per-value block returning `nil` or `false` causes the attribute to be omitted (not rendered as `class=""`).
- *Edge case — empty `row_options`:* `{}` returns Avo's defaults unchanged.
- *Edge case — `table_view` unset on resource:* merger called with `user_options: nil` returns Avo's defaults.
- *Edge case — top-level block returning nil:* treated as empty hash.
- *Error path — token concat for `data-action`:* user `data: { action: "click->mything#do" }` produces a single string concatenating Avo's existing actions plus the user's tokens, with no duplicates.
- *Error path — token concat for `data-controller`:* user `data: { controller: "my-controller" }` results in `data-controller="item-selector table-row my-controller"` (or equivalent), preserving Avo's controllers.
- *Error path — Avo-wins reserved key:* user `data: { record_id: "spoof" }` → final `data-record-id` is Avo's value; in development, `Rails.logger.warn` records the attempted override.
- *Error path — id rejected (dev):* user `id: "my-row"` raises `ArgumentError` listing supported keys when `Rails.env.development?` or `.test?`.
- *Error path — id rejected (prod):* same input under `Rails.env.production?` reports via `Rails.error.report`, falls back to Avo's defaults, does not raise.
- *Error path — role rejected:* user `role: "button"` raises (dev) / logs (prod). Same for `aria-selected`.
- *Error path — onclick rejected:* user `onclick: "alert(1)"` raises (dev) / logs (prod).
- *Error path — tabindex rejected:* user `tabindex: 0` raises (dev) / logs (prod). Same for `contenteditable`, `draggable`.
- *Error path — invalid return type:* per-value block returning a Hash for `title:` (not `class:`) raises in dev, falls back in prod.
- *Error path — block raises:* per-value block raising `NoMethodError` reports via `Rails.error.report`, falls back to Avo defaults for that row, does not bubble up to the user.
- *Integration — instrumentation:* a `notifications.instrument` subscriber sees `"avo.row_options.evaluate"` events with `resource`, `view`, `record_id` in the payload.

**Verification:**
- All scenarios above pass.
- The merger is fully testable without booting the dummy app (pure Ruby).
- Reserved-key constant is a frozen Array/Set on the module and matches the canonical list documented in `Key Technical Decisions`.

---

- [ ] **Unit 3: Wire the merger into `TableRowComponent`**

**Goal:** Make `TableRowComponent` derive `view`, call the merger, and apply the merged attributes to `<tr>` at render time (after the cache boundary).

**Requirements:** R3, R5, R6

**Dependencies:** Unit 1, Unit 2.

**Files:**
- Modify: `app/components/avo/index/table_row_component.rb`
- Modify: `app/components/avo/index/table_row_component.html.erb`
- Test: `spec/components/avo/index/table_row_component_spec.rb` (create — no spec exists today)

**Approach:**
- In `.rb`: add `def view; @reflection.present? ? :has_many : :index; end` (private or public — TBD during implementation; lean toward private with a public wrapper if the component already exposes locals).
- Add a method `merged_tr_attributes` (or similar) that:
  - Reads the resource's `table_view`.
  - Builds Avo's stock attribute hash (id, class, data — same as today's template).
  - Calls the merger module with both.
  - Returns the merged hash.
- In `.html.erb`: replace the inline `content_tag :tr, id: ..., class: ..., data: { ... }` with `content_tag :tr, **merged_tr_attributes do`. The contents of the block (cells, controls, selector) are unchanged.
- Confirm the `id` is still emitted by Avo (`"#{self.class.to_s.underscore}_#{@resource.record_param}"`) — hosted in the merger's "Avo attributes" input, not in user options.

**Patterns to follow:**
- The existing template structure (`table_row_component.html.erb:3-17`).
- `@reflection.present?` branching used throughout `app/components/avo/views/resource_index_component.rb`.

**Test scenarios:**
- *Happy path — index render:* a resource with no `table_view` renders identically to today (selection, click-to-view, drag-reorder data attributes intact, id present).
- *Happy path — `row_options` set:* resource with `self.table_view = { row_options: { class: "x" } }` renders `<tr>` with `class="table-row group z-21 x"`.
- *Happy path — view local:* a resource using `view == :has_many ? "panel" : "main"` in a block renders `"panel"` when the row is in an association panel.
- *Edge case — has_many panel:* component instantiated with a non-nil `@reflection` returns `:has_many` from `view` and the block sees that value.
- *Edge case — cache boundary:* with `cache_resources_on_index_view` enabled, two consecutive renders for two different `current_user` values both invoke the per-value block. Confirms blocks evaluate after the cache boundary at render time.
- *Integration — selection still works:* clicking the row selector still emits the right Stimulus action even when `row_options` adds custom data attributes.
- *Integration — click-to-view still works:* row click navigates to show page when `click_row_to_view_record` is true and user `row_options` includes a `data: { test_id: "row" }`.

**Verification:**
- Existing `spec/system/avo/group_1/hotkey_spec.rb` and association specs continue to pass (no regressions in row id, selection, click-to-view, keyboard nav).
- The new component spec passes for all scenarios above.

---

- [ ] **Unit 4: Component-level specs for `TableRowComponent` row_options behavior**

**Goal:** Add focused `type: :component` coverage exercising the row options end-to-end from the component's perspective (without booting the full dummy app stack).

**Requirements:** R3, R5, R6, R7, R8, R9, R10, R11

**Dependencies:** Unit 3.

**Files:**
- Create: `spec/components/avo/index/table_row_component_spec.rb`

**Approach:**
- Use `type: :component` and instantiate `Avo::Index::TableRowComponent` directly. Mock `@header_fields` (existing precedent in `spec/dummy/app/components/avo/for_test/table_row_component.rb` shows the workaround).
- One context per merge case (class, data deep-merge, token-concat, denylist).
- Use `render_inline` and assert on resulting HTML via `page.find("tr")` or by parsing the rendered output.

**Patterns to follow:**
- `spec/components/avo/views/resource_index_component_spec.rb` — the only existing component-level spec under `spec/components/avo/views/`.

**Test scenarios:**
- Mirrors the merger's scenarios (Unit 2) but at the component layer: the rendered `<tr>` carries the expected `class`, `data`, and other attributes.
- *Happy path:* resource with `row_options: { class: -> { record.role } }` renders the role string in the class.
- *Integration:* token-concat for `data-action` is observable in the rendered HTML — i.e., the `<tr data-action>` string contains both Avo's tokens AND the user's.
- *Integration:* `view` local resolves to `:has_many` when `@reflection` is set; `:index` otherwise.
- *Error path:* component instantiated with a resource whose `row_options[:id]` is set raises in test environment.
- *Edge case:* resource without `self.table_view` renders identically to a resource with `self.table_view = { row_options: {} }`.

**Verification:**
- `bundle exec rspec spec/components/avo/index/table_row_component_spec.rb` passes.

---

- [ ] **Unit 5: End-to-end feature spec**

**Goal:** A Capybara-driven feature spec proving the full path works from a resource declaration through to the rendered admin page, in both index and has_many contexts.

**Requirements:** R3, R5, R7, R8

**Dependencies:** Unit 3.

**Files:**
- Create: `spec/features/avo/resource_table_view_row_options_spec.rb`
- Possibly modify: `spec/dummy/app/avo/resources/` (add a small `table_view`-using resource fixture if no existing dummy resource fits the test). Confirm during implementation.

**Approach:**
- Visit the index path of a resource that sets `self.table_view = { row_options: { class: -> { record.<some_attr> ... } } }`. Assert via Capybara that the expected class is present on a specific row's `<tr>`.
- Visit a parent show page that renders a `has_many` association table. Assert that the same resource's `row_options` apply, and that `view: :has_many` branching works (different class than on the index).
- Confirm click-to-view still navigates correctly, and that bulk-select still toggles the row selector — these are smoke checks; full coverage already exists in the broader spec suite.
- Use the existing `User` or `Post` resource as the fixture if its model has enough attributes to drive a meaningful conditional class. Otherwise add a minimal new fixture resource (e.g., `Avo::Resources::TableRowOptionsTest`) with a single `class: -> { record.id.even? ? "even" : "odd" }` condition.

**Patterns to follow:**
- `spec/features/avo/resource_custom_components_spec.rb` — feature spec with a custom component override.
- Existing system specs under `spec/system/avo/group_1/`.

**Test scenarios:**
- *Happy path — index:* index page renders with the conditional class on the right rows.
- *Happy path — has_many:* parent show page includes the association table with the same conditional class applied. If the resource branches on `view`, the has_many class differs from the index class.
- *Integration — click-to-view preserved:* clicking a row navigates to the show page even with `row_options` setting custom `data-test-id`.
- *Integration — selection preserved:* checking the row selector still toggles selection state.
- *Edge case — empty resultset:* visiting the index with no records does not raise (no rows means merger is never called).

**Verification:**
- New feature spec passes.
- No regressions in existing system specs (`spec/system/avo/group_1/hotkey_spec.rb`, has_many specs, custom components spec).

---

- [ ] **Unit 6: User-facing documentation**

**Goal:** Ship a docs page under `docs/4.0/` covering the API, examples, Tailwind safelist guidance, dark mode and hover/selection patterns, performance guidance, and the denylist policy.

**Requirements:** R1, R2, R5, R6, R7, R8, R9, R11

**Dependencies:** Unit 3 (so the docs reflect what shipped).

**Files:**
- Create: `/Users/adrian/work/avocado/docs/docs/4.0/resource-table-view.md` *(or wherever the 4.0 docs section lives — confirm by checking `docs/.vitepress/config.js` during implementation)*
- Modify: `/Users/adrian/work/avocado/docs/docs/.vitepress/config.js` to register the page in the 4.0 sidebar.

**Approach:**
- Follow the docs convention from `gems/CLAUDE.md`'s Writing Docs section (frontmatter, structure, code block formatting).
- Sections, in order:
  1. Title + overview (1-2 sentences).
  2. **Requirements:** version of Avo this lands in.
  3. **Configuration:** `self.table_view = { row_options: { ... } }` shape, accepted keys, accepted value types (static, block).
  4. **ExecutionContext locals:** `record`, `resource`, `view`.
  5. **Examples:** at least three. (a) LLM/user message highlighting (the motivating case), (b) soft-deleted/dimmed rows, (c) status tints (e.g., `record.status == "archived"`). All examples use Tailwind utilities with `dark:` variants.
  6. **Hover and selection co-existence:** the recommended pattern (semitransparent backgrounds OR `hover:` modifiers).
  7. **Dark mode:** users own `dark:` modifiers; alternative is using semantic CSS variables in `style:`.
  8. **Tailwind safelist recipe:** a copy-paste `safelist:` snippet for `tailwind.config.js`.
  9. **Performance:** preload associations referenced from blocks via `self.includes`. Mention the `avo.row_options.evaluate` instrumentation hook for profiling.
  10. **Reserved keys / denylist:** explain which keys are rejected (`id`, `role`, `aria-selected`, `on*`, `tabindex`, `contenteditable`, `draggable`) and why. List Avo-owned reserved data keys so users know what not to set.
  11. **Migration from partial overrides:** point users who previously overrode `Avo::Index::TableRowComponent` toward `row_options` and tell them how to remove the override.
  12. **Limitations:** no cell-level options yet (link to future doc); no grid/kanban analog yet; `<tr>` styling has known interactions with `<td>` backgrounds — link to the example that handles this.

**Patterns to follow:**
- Docs conventions from `gems/CLAUDE.md` (frontmatter with `outline: [2,3]`, professional but conversational tone, language-tagged code blocks, `:::info` / `:::warning` callouts where useful).
- Sibling pages: `docs/4.0/kanban-boards.md`, `docs/4.0/audit-logging/index.md`.

**Test expectation:** none — documentation page; verify via `npx vitepress build docs` and a manual preview in `npx vitepress dev docs` that the page renders, the sidebar entry works, and all anchor links resolve.

**Verification:**
- `npx vitepress build docs` exits without errors.
- Manual preview at `npx vitepress dev docs --port 3011` shows the page in the sidebar, with all anchors resolving and code blocks formatted correctly.
- All three usage examples copy-paste into a fresh resource and produce the expected visual result against the dummy app.

## System-Wide Impact

- **Interaction graph:**
  - `Avo::Resources::Base` gains a new `class_attribute` — read by `TableRowComponent` and (potentially) future grid/kanban analogs.
  - `TableRowComponent` is the only consumer in this iteration. No other component reads `table_view`.
  - The merger module is invoked once per row, per render. It calls `Avo::ExecutionContext` per block, which resolves `current_user`, `params`, `request`, and `view_context` from `Avo::Current`.
- **Error propagation:**
  - Block raises in dev/test → propagates out of merger as `ArgumentError` (or original exception for runtime errors), surfaced to the developer immediately.
  - Block raises in production → caught in merger, reported via `Rails.error.report`, the row falls back to Avo's default `<tr>` attributes (no class/data customizations applied for that row only). No request-level failure.
  - Denylist violation in dev/test → `ArgumentError` listing supported keys.
  - Denylist violation in production → `Rails.error.report` + silent ignore.
- **State lifecycle risks:**
  - **Cache:** `cache_table_rows` wraps construction; per-row blocks evaluate at render time. Confirmed safe by placing the merger call inside the ERB template.
  - **Turbo Stream broadcasts:** an open question deferred to implementation — confirm that broadcast re-renders carry the right `@reflection` so `view:` resolves correctly.
  - **Subclass inheritance:** `class_attribute` with `default: nil` avoids the Hash-default leak. Subclass mutation (`Child.table_view = ...`) replaces, not merges with, the parent's value.
- **API surface parity:**
  - This API does not yet apply to `Avo::Index::GridItemComponent` (grid view) or any kanban-card component. `self.grid_view` is the future home for analogous grid options.
  - This API does not apply to fields/cells. When `cell_options` ships, it will live on the field DSL.
- **Integration coverage:** Cross-layer scenarios (component + helper + resource + Stimulus) covered by the feature spec in Unit 5. Component-isolation cases covered by Unit 4.
- **Unchanged invariants:**
  - `<tr id="...">` always set by Avo, never by the user.
  - All existing reserved data attributes (`index`, `component_name`, `resource_name`, `record_id`, `controller`, `resource_id`, `visit_path`, `action`, `reorder_target`) remain functional; user options never break them.
  - Selection, click-to-view, drag-to-reorder, keyboard navigation continue to work.
  - `Avo::Index::TableRowComponent`'s render path (cache boundary, header fields, cells, controls) is unchanged outside the `<tr>` attribute construction.

## Risks & Dependencies

| Risk | Mitigation |
|---|---|
| Token-concat for `data-controller` / `data-action` introduces duplicate tokens or breaks Stimulus identifiers | Use Rails `token_list`, which dedupes. Cover with explicit specs in Unit 2 (see test scenarios for token-concat). |
| User block raises in production and crashes the index page | In production, catch and report via `Rails.error.report`; fall back to Avo defaults for that row. No request-level failure. |
| Per-row block evaluation creates N+1 queries on large tables | Document `self.includes` preload requirement in Unit 6. Add `ActiveSupport::Notifications.instrument("avo.row_options.evaluate", ...)` so users can profile. |
| Turbo Stream broadcast re-renders default to `:index` even inside a has_many panel | Deferred to implementation; if confirmed, document the limitation in Unit 6 rather than reshaping the API. |
| Users adopt the API expecting cell-level granularity, get only row-level | Multiple examples in Unit 6 docs lean into row-only use cases (soft-deleted, status tints). Bubble-style chat highlighting is explicitly noted as needing future cell_options. |
| `class_attribute` Hash-default footgun | Use `default: nil`, normalize in reader. Test scenario in Unit 1 confirms subclass independence. |
| Denylist becomes incomplete over time as Avo adds new behaviors | Reserved-key constant lives in the merger module. Document the canonical list in Unit 6 and reference it from the merger source so it stays in sync. |
| ARIA `role` rejection breaks accessibility for users with valid `role` use cases | The implicit `<tr>` role of `row` inside `<table>` is canonical for screen readers. If a user has a legitimate need to override it, they should override the entire component (existing path). Document this in the migration / limitations section. |
| `aria-selected` collides with Avo-owned selection state | Reject `aria-selected` from user options. If Avo doesn't yet emit `aria-selected` based on its own selection state, that's a separate a11y improvement tracked outside this plan. |

## Documentation / Operational Notes

- Unit 6 covers all user-facing documentation.
- After shipping, capture a `docs/solutions/best-practices/` doc with the lessons learned around Stimulus token-list merging, ExecutionContext for per-row blocks, and the cache-boundary timing — institutional learnings noted these as fresh territory.
- No migrations, feature flags, or staged rollout. The API is additive: existing resources without `self.table_view` are unaffected.
- No monitoring changes required; the instrumentation hook is opt-in (subscribers attach if they want).

## Sources & References

- **Origin document:** [docs/brainstorms/2026-05-04-resource-table-view-row-options-requirements.md](../brainstorms/2026-05-04-resource-table-view-row-options-requirements.md)
- **Resource DSL home:** `lib/avo/resources/base.rb` (`class_attribute :grid_view` precedent at line 70; `fetch_search` reader at line 261)
- **ExecutionContext:** `lib/avo/execution_context.rb` (`Avo::Current` defaults, `delegate_missing_to :@view_context`)
- **Component to modify:** `app/components/avo/index/table_row_component.rb` and `.html.erb`
- **Cache boundary:** `app/components/avo/view_types/table_component.rb` (`cache_table_rows`, lines 38-53)
- **Reserved data keys:** `app/helpers/avo/resources_helper.rb:40-46` (`item_selector_data_attributes`); `avo-pro/lib/avo/pro/concerns/can_reorder_items.rb:24-38` (drag-reorder)
- **View derivation precedent:** `app/components/avo/views/resource_index_component.rb` (`@reflection.present?` branching)
- **Class merging:** Rails `ActionView::Helpers::TagHelper#class_names` / `token_list` (Rails 6.1+)
- **Test fixtures:** `spec/dummy/app/components/avo/for_test/table_row_component.rb`; `spec/features/avo/resource_custom_components_spec.rb`
- **Dark mode pattern:** `app/assets/stylesheets/css/variables.css` (`.dark` overrides)
- **Institutional learning:** `docs/solutions/best-practices/configurable-keyboard-shortcuts-avo.md` (frozen-defaults + merge reader pattern)
