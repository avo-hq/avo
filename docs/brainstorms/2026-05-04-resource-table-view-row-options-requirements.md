---
date: 2026-05-04
topic: resource-table-view-row-options
---

# Resource `self.table_view` API with `row_options`

## Problem Frame

Avo resources have no first-class way to vary a row's HTML attributes per record. Users who want to visually differentiate rows (e.g., highlight LLM messages vs. user messages on an index of a conversation log) currently have to override the row partial or fight Avo's component layer. The most common use case is conditional CSS classes on the row's `<tr>`, but `data`, `style`, and ARIA attributes are equally valid asks.

This brainstorm defines a resource-level API — `self.table_view = { row_options: { ... } }` — that lets users declaratively set row HTML attributes, optionally evaluated per record, while keeping Avo's own row behavior (selection, click-to-view, drag-to-reorder) intact.

## Requirements

**API Surface**

- R1. Resources expose `self.table_view = { row_options: { ... } }` on `Avo::Resources::Base`. The `table_view` hash is designed to grow over time (future keys: header options, striping, etc.); only `row_options` ships in this iteration.
- R2. `row_options` accepts standard HTML-attribute keys: `class`, `data`, `style`, `title`, `role`, `aria-*`, and any other passthrough HTML attribute. `id` is **not** a supported key.
- R3. `row_options` applies wherever `Avo::Index::TableRowComponent` renders — both the main index table and `has_many` association tables on parent show pages.

**Block Evaluation**

- R4. The value of `row_options` may be either a Hash or a block returning a Hash. Within the Hash, each individual value may also be a static value or a block. Both forms compose: a top-level block can return a Hash whose values are themselves blocks (although this is unusual).
- R5. Blocks are evaluated through `Avo::ExecutionContext`. Documented locals: `record`, `resource`, and `view` (derived as `@reflection.present? ? :has_many : :index`, matching the existing `Avo::Index::ResourceControlsComponent` pattern — no new component prop is needed). Standard `ExecutionContext` defaults (`current_user`, `params`, `request`, view helpers via `delegate_missing_to :@view_context`) remain available as a side effect, consistent with other Avo blocks.
- R6. Blocks are evaluated inside the `<tr>` template, after the cache boundary in `Avo::ViewTypes::TableComponent#cache_table_rows`, so each render re-evaluates regardless of `cache_resources_on_index_view`. Users are responsible for keeping blocks cheap; Avo will not memoize. Documentation MUST cover preloading associations referenced from blocks via `self.includes`. A development-mode `ActiveSupport::Notifications.instrument("avo.row_options.evaluate", ...)` hook is provided for profiling.
- R11. Block return-type contract:
  - `nil` or `false` → omit the attribute entirely.
  - `String` or `Symbol` → coerced via `to_s`.
  - `Array<String>` or `Hash<String, Boolean>` → valid only for `class:`, routed through `class_names`.
  - Any other return type → raises `ArgumentError` in development/test; in production the row falls back to Avo's default attributes and the exception is reported via the Rails error reporter.

**Merge Contract with Avo's Row Attributes**

`Avo::Index::TableRowComponent` already sets `id`, `class`, and `data` on `<tr>` (see `app/components/avo/index/table_row_component.html.erb`). User-provided `row_options` are merged with these:

| Attribute | Merge Behavior | Notes |
|---|---|---|
| `class` | Append | User's classes are appended to Avo's (`table-row group z-21`, optional `cursor-pointer`). User wins at equal CSS specificity. |
| `data` | Deep-merge | User's data hash is deep-merged with Avo's. Token-list keys (`controller`, `action`) and reserved-key precedence are open design questions — see Outstanding Questions. |
| `id` | **Rejected** | Avo's row id is canonical. Raises `ArgumentError` in development/test; logs via Rails error reporter and ignores in production. |
| anything else | Pass-through | `style`, `title`, `role`, `aria-*`, etc. — values are HTML-escaped by `content_tag`. |

- R7. User-provided `class` is merged into Avo's existing class list, never replaces it. User classes are appended after Avo's, so they win at equal CSS specificity. Avo does not actively suppress its own utility classes (notably `cursor-pointer`); users who need to override Tailwind utilities should use more specific selectors or `!` modifiers.
- R8. User-provided `data` is deep-merged into Avo's existing data attributes. Avo's reserved data keys (`action`, `controller`, `visit_path`, `record_id`, `index`, `component_name`, `resource_name`, item-selector keys, drag-reorder keys) must remain functional after merge. The exact merge strategy for token-list keys (`action`, `controller`) and the precedence rule for the rest are open questions resolved during planning (see Outstanding Questions).
- R9. User-provided `id` is rejected. In development/test, raise `ArgumentError` listing the supported keys. In production, log a warning via the Rails error reporter and ignore. Documented behavior; not silent.
- R10. Other HTML attributes pass through to `content_tag :tr`. Values are HTML-escaped by `content_tag` (standard Rails behavior).

## Example Usage

```ruby
class Avo::Resources::Message < Avo::BaseResource
  self.table_view = {
    row_options: {
      class: -> {
        record.role == "agent" ? "bg-blue-50 dark:bg-blue-950/40 hover:bg-blue-100 dark:hover:bg-blue-900/40" : ""
      },
      data: { test_id: "message-row" },
      title: -> { "Message from #{record.role}" }
    }
  }
end
```

Branching on render context (`view: :index` vs. `:has_many`):

```ruby
class: -> { view == :index && record.role == "agent" ? "bg-blue-50 dark:bg-blue-950/40" : "" }
```

Equivalent top-level block form (single evaluation context for many keys):

```ruby
self.table_view = {
  row_options: -> {
    {
      class: record.role == "agent" ? "bg-blue-50 dark:bg-blue-950/40" : "",
      data: { test_id: "message-row", role: record.role },
      title: "Message from #{record.role}"
    }
  }
}
```

## Success Criteria

- A resource can conditionally highlight rows based on record state in 5–10 lines of resource configuration, with no partial overrides.
- The motivating use case — messages index where `record.role == "agent"` rows are visually distinct — works end-to-end.
- Existing row behavior (selection checkbox, click-to-view, drag-to-reorder, hover) keeps working with `row_options` set on a resource.
- The same API works in `has_many` association tables without additional configuration; `view:` lets users branch behavior between `:index` and `:has_many` if they want to.
- `self.table_view = { ... }` can later gain sibling keys (`header_options`, etc.) and parallel APIs (`self.grid_view`, `self.kanban_view`) without renaming or relocating `row_options`.

## Scope Boundaries

- **No `cell_options`** (per-field `<td>` overrides). Cell-level highlighting is a real want with its own design questions (precedence vs. row-level, where it lives in the field DSL); separate iteration.
- **No grid or kanban equivalents.** `self.grid_view = { ... }` already exists as the future home for grid-card options; kanban gets its own when the time comes.
- **`id` is not a supported key.** Avo owns row identification.
- **No predefined "row state" presets** (`:highlighted`, `:warning`, etc.). Users supply their own classes.
- **No automatic Tailwind safelist help.** Custom row classes must be in the user's `tailwind.config.js` content paths or safelist; documented, not magicked.
- **Resources only, in this iteration.** No per-controller or per-action overrides.

## Key Decisions

- **Namespace under `self.table_view = { ... }`** rather than top-level `self.row_options`. Why: parallels existing `self.grid_view`, gives a consistent mental model per view type, and leaves room for sibling table-level options.
- **Both top-level and per-value block forms supported.** Why: per-value blocks match the user's natural intuition (`class:` is the most common dynamic key); top-level blocks let users avoid repeating evaluation context when several keys depend on the same record state.
- **Merge over replace for `class` and `data`.** Why: replacement silently breaks selection, click-to-view, and drag-to-reorder — too easy a foot-gun for a feature that's mostly used for cosmetic tweaks.
- **`id` unsupported with explicit rejection.** Why: row id is consumed by tests, Stimulus targets, and request scoping. Allowing override is a structural risk; silent drop is a debugging foot-gun. Loud rejection in development gives users immediate feedback.
- **ExecutionContext exposes `record`, `resource`, `view`.** Why: covers the known use cases (highlight by record state, branch on `:index` vs `:has_many`) without dragging in `params`, `current_user`, etc. as documented locals — though they remain reachable via the standard `ExecutionContext` delegation. Easy to extend later without breaking change.

## Dependencies / Assumptions

- `Avo::ExecutionContext` is already the standard block-evaluation primitive in Avo and supports arbitrary kwargs. The `record` and `resource` locals require no new infrastructure; `view` is derived inside `TableRowComponent` from `@reflection.present?` (matches the existing `ResourceControlsComponent` precedent), so no new component prop is needed.
- `Avo::Index::TableRowComponent` is the single render path for both index and `has_many` association tables. Confirmed by inspection of `app/components/avo/index/table_row_component.html.erb`.
- Avo's `class_names` helper (Rails 6.1+ `ActionView::Helpers::TagHelper#class_names` / `token_list`) is reused for combining class strings, arrays, and hashes.
- When backed by `class_attribute`, `self.table_view` should use `default: nil` (not `default: {}`) to avoid the Rails `class_attribute` Hash-default footgun where subclass mutation leaks into the parent's default. A reader normalizes `nil` to `{}` at the use site.

## Outstanding Questions

### Design Decisions (Deferred to Planning)

- [Affects R7][Technical] What forms does `class` accept on input — `String`, `Array<String>`, `Hash<String, Boolean>`? Reusing Avo's existing `class_names` helper makes all three free.
- [Affects R8][Technical] Data merge strategy. Default deep-merge is last-wins (user wins), which would break Avo's reserved keys. Specifically:
  - `data-action` and `data-controller` are space-separated token lists (Stimulus convention). Last-wins replaces Avo's tokens entirely, breaking click-to-view, keyboard activation, hover preload, and selection. **Token-concat is required** for these two keys.
  - All other reserved keys (`visit_path`, `record_id`, `index`, `component_name`, `resource_name`, item-selector keys, drag-reorder keys) — choose between (a) Avo-wins with development-mode warning, or (b) namespace user data under a sub-key.

### Dependency Verification (Confirm Before Implementation)

- [Affects R3][Technical] Does the `view:` derivation (`@reflection.present? ? :has_many : :index`) cover all `TableRowComponent` render paths — `has_many`, `has_and_belongs_to_many`, `has_many :through`, polymorphic, `has_one`-as-table? Confirm during planning whether the simple boolean derivation is correct, or whether distinct symbols are needed.
- [Affects R3][Technical] When `TableRowComponent` re-renders via a Turbo Stream broadcast (record update, action result, drag-reorder), does the broadcast carry enough context to set `view:` correctly, or does it default to `:index` regardless? Confirm and document.
- [Affects R1][Technical] Should `self.table_view` be backed by a `class_attribute` on `Avo::Resources::Base` (like `self.grid_view`), or by a dedicated reader/writer that normalizes the hash? Decide based on how the value is consumed downstream and the `default: nil` strategy noted in Dependencies.
- [Affects R4][Needs research] Survey existing resource-level configs (`self.search`, `self.filters`, `self.actions`, `self.includes`) for the canonical "Hash with maybe-block values" pattern before locking the implementation. Document the chosen pattern.

## Next Steps

→ `/ce:plan` for structured implementation planning
